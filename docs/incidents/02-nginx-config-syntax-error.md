# Incident 2: nginx failed to start because of a config syntax error

## Symptom
I restarted nginx and systemctl said the job failed.
From my own computer, a verbose curl to the public IP gave "Connection refused"
after about 20 ms. From the outside it looked exactly like Incident 1.

## Cause
I deleted the semicolon at the end of the root line in the site config.
Without the semicolon, nginx kept reading and took the next line (index index.html)
as more arguments for root. So root got too many arguments and the config was invalid.
Because I used restart, nginx stopped first and then could not start again.

## How I diagnosed it
systemctl status nginx showed the service as "failed". Before starting nginx,
systemd runs the nginx config test (the ExecStartPre line), and that test failed.
The important log line was:

```
[emerg] invalid number of arguments in "root" directive in /etc/nginx/sites-enabled/attackwatch:7
```

The status output cut this line short, so I had to look at the full line
to see the file and line number. The nginx config test shows the same message.

Note: the error points to line 7 (the index line), but my mistake was on line 5
(the root line). The line number shows where nginx noticed the problem,
not always where the mistake is.

## Fix
I put the semicolon back, started nginx and checked that the status was
"active (running)" and that the page loaded from my computer.

## Lesson
- Same symptom as Incident 1, different cause. The answer is always on the server.
- Always test the config before applying it.
- Use reload, not restart, after config changes. With a broken config, reload fails
  but nginx keeps running with the old config, so the site stays up.
  Restart stops nginx first, so a broken config means the site goes down.