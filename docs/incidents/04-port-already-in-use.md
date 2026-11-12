# Incident 4: A second server could not use port 80

## Symptom
While nginx was running, I tried to start Python's simple HTTP server on port 80.
It failed with two different errors, depending on how I ran it:

- Without sudo: `PermissionError: [Errno 13] Permission denied`
- With sudo: `OSError: [Errno 98] Address already in use`

The website itself kept working the whole time, because nginx already had the port.

## Cause
Both errors come from the bind() system call, but from two different checks:

1. Ports below 1024 are privileged ports. Only root can bind to them.
   Without sudo, the kernel stopped me at this first check (errno 13, EACCES).
2. With sudo I passed the first check, but nginx was already listening
   on 0.0.0.0:80. The kernel does not give the same address and port to two
   sockets, so bind() failed with errno 98 (EADDRINUSE).

## How I diagnosed it
I listed the listening sockets with ss, including process names (this needs sudo
to see processes of other users), and looked for port 80:

```
tcp LISTEN 0 511 0.0.0.0:80 0.0.0.0:* users:(("nginx",pid=109610,fd=5),("nginx",pid=109609,fd=5),("nginx",pid=109608,fd=5))
```

Port 80 is held by nginx: the master process and its two workers share the same socket.

## Fix
Nothing was broken on the site. I stopped trying to start the second server.
In real life, if a service cannot start because its port is taken, the steps are:
find who holds the port with ss, then decide whether to stop that program
or move one of the services to a different port.

## Lesson
- "Address already in use" means another program owns that address and port.
  ss with process names shows who it is.
- Ports below 1024 need root. That is why the nginx master runs as root
  (to open port 80), and the workers run as the unprivileged user www-data.
- The dangerous version of this problem is the opposite case: another program
  takes port 80, then nginx is restarted and cannot start, so the site goes down.