# Incident 1: nginx service stopped

## Symptom
From my own computer I tried to reach the server's public IP with a verbose curl.
It could not connect, and it failed after only 28 ms:

```
* Trying <public IP>:80...
* connect to <public IP> port 80 from <my IP> port <port> failed: Connection refused
* Failed to connect to <public IP> port 80 after 28 ms: Couldn't connect to server
* Closing connection
```

28 ms is just the round trip to the server, so the answer came back right away.
This is a refused connection, not a timeout. With a timeout, nothing comes back
and the client waits for seconds before it gives up.

## Cause
I stopped the nginx service with systemctl, so nothing was listening on port 80.
The packet reached the server, but the kernel answered with a reset (RST).

## How I diagnosed it
- systemctl status showed nginx as "inactive (dead)".
- I listed the listening ports with ss. Port 22 was there, port 80 was not.

## Fix
I started nginx again with systemctl. After that, port 80 showed up in ss again
and the page loaded from my computer.

## Lesson
Connection refused means the packet got in, but no program is listening on that
port. The first things to check are the service status and the listening ports.