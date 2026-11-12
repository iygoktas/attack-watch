# Incident 6: Disk usage jumped because of a large file

## Symptom
The root filesystem usage went up from 4% to 9% (about 3 GB more) without
any obvious reason. Nothing broke yet, but on a real server a full disk means
logs cannot be written, services cannot start and package updates fail.

```
Before: /dev/root  63911928  2284904  61610640  4%  /
After:  /dev/root  63911928  5430628  58464916  9%  /
```

At first I thought nothing had changed, because df shows sizes in 1K blocks
and the numbers are hard to read. The Use% column and the human-readable
format make the change obvious.

## Cause
I created a 3 GB file with fallocate inside a new folder, /etc/myTestFlie,
and then acted as if I did not know where it was.

## How I diagnosed it
- df told me THAT the disk was filling up (filesystem level: size, used, free).
- du told me WHERE the space went (folder and file level).

I ran du with sudo on / and limited it to one level of folders, in a
human-readable format. /etc showed 3.1G, which is far too big for a config
folder. Then I ran du one level deeper inside /etc, and /etc/myTestFlie
showed 3.1G. That was the culprit.

The "cannot access /proc/..." errors were harmless: some processes ended while
du was walking through /proc, and /proc does not use disk space anyway.

## Fix
I deleted the file and its folder, carefully, because a typo inside /etc can
break the system. df showed 4% usage again.

## Lesson
- df raises the alarm, du finds the cause.
- Start from / and always go into the biggest folder, one level at a time.
- On a real server there can be thousands of lines, so the du output should be
  sorted by size (with a sort that understands sizes like 2G and 500M) and
  only the top lines shown.