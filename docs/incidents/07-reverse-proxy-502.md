# Incident 7: 502 Bad Gateway from the reverse proxy

## What I set up
A reverse proxy: requests to /api/ go to nginx on port 80, and nginx passes them
to an application listening only on 127.0.0.1:5000. Visitors never talk to the
application directly. Only port 80 is open in the NSG and ufw. Port 5000 is not
open anywhere, because nginx reaches it from inside the server over loopback.

(While writing the config I also made two mistakes: I used reverse_proxy, which
is not an nginx directive (the right one is proxy_pass), and I forgot a semicolon
again. The config test showed the errors one at a time.)

## Symptom
With nothing running on port 5000, a verbose curl from my computer to /api/ got:

```
* Connected to <server IP> port 80
< HTTP/1.1 502 Bad Gateway
< Server: nginx/1.24.0 (Ubuntu)
```

The connection to nginx worked (no refused, no timeout), and nginx itself answered
with 502.

## Cause
nginx was working, but the application behind it (the upstream) was not running.
nginx tried to connect to 127.0.0.1:5000, nobody was listening, so it could not
get an answer to pass on.

## How I diagnosed it
The access log only showed the result (502). The reason was in the error log:

```
connect() failed (111: Connection refused) while connecting to upstream, ... upstream: "http://127.0.0.1:5000/api/"
```

Error 111 is ECONNREFUSED. It is the same thing as Incident 1, but seen from
nginx's side: nginx was the client, and port 5000 refused it.

## Fix
I started Python's simple HTTP server on 127.0.0.1, port 5000, in an empty folder.
The same curl now returned 404 "File not found". The proxy worked: the request
reached the application, and the application had no /api/ folder to serve.

The Server header still said nginx, but the answer came from Python. nginx
replaces the upstream's Server header with its own. The real proof was:
- the body was Python's error page, not nginx's,
- the status line said "File not found" (nginx says "Not Found"),
- Python's own log showed the request, coming from 127.0.0.1 with HTTP/1.0.
  So the application sees nginx as the client, not the real visitor.

## Lesson
- 502 means: nginx works, but the application behind it does not answer.
  Look at the error log and check if the upstream is running and listening.
- Behind a proxy, headers can lie about who answered. Check the body and the
  application's own log.
- The application only listens on 127.0.0.1 and its port is never opened.
  Port 80 is the only way in.