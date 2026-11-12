# Incident 3: 403 Forbidden because nginx could not read the page

## Symptom
When I opened the site, it returned 403 Forbidden instead of the page.
The connection worked and nginx answered, so this was not a network problem.
nginx was running, but it was not allowed to give out the file.

```
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.24.0 (Ubuntu)</center>
</body>
</html>
```

## Cause
I changed the permissions of /var/www/attackwatch/index.html with chmod to 640:
- owner (root): read + write (4+2)
- group (root): read (4)
- others: nothing (0)

nginx's worker processes, the ones that serve files to visitors, run as the user
www-data (the "user" line in /etc/nginx/nginx.conf). www-data is not the owner of
the file and is not in its group, so the "others" permissions apply to it.
With 0 there, www-data could not read the file.

## How I diagnosed it
- From my own computer, curl showed the 403 status code.
- In nginx's error log (/var/log/nginx/error.log) I found this line:

```
[error] open() "/var/www/attackwatch/index.html" failed (13: Permission denied), client: <my IP>, server: _, request: "GET / HTTP/1.1", host: "<server IP>"
```

nginx tried to open the file with the open() system call, and the kernel refused
with error number 13 (EACCES, Permission denied). nginx wrote this error to its
log and turned it into a 403 for the visitor.

## Fix
I changed the permissions back to 644 (owner read + write, group and others read).
The page is public anyway, so everyone may read it, but only the owner can change it.
After that, curl from my computer got the page again with 200.
I did not need to restart nginx: the kernel checks permissions every time a file is
opened, so the change worked right away.

## Lesson
- 403 means nginx works, but it is not allowed to read what it should serve.
- The error log shows the real reason. The status code only shows the result.
- Always check which user the service runs as, and which permission group
  (owner, group or others) that user falls into for the file.