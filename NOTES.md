# NOTES

My learning notebook for the attack-watch project. After every session I write what I did, what I learned and what I will do next.

---

## Part 0: Getting ready (terminal, Git, GitHub)

### What I did
- I checked that ssh and git are installed on my Mac.
- I set my name and email for Git.
- I made an SSH key in the terminal and added it to GitHub. The connection test worked.
- I made a public repo called attack-watch on GitHub and cloned it.
- I set up the folders the project needs (scripts, config/nginx, config/ssh, docs/incidents) and added README.md and NOTES.md.
- I made a .gitignore so private keys, .key files and .env files never get pushed by mistake.
- I made my first commit and pushed it.

### What I learned
I didn't only read about Git. After every step I opened the files inside .git to see what changed. This is what I found:

- **I learned** that HEAD keeps the name of the branch I am on right now.
- **I learned** that a branch is just a small file with one commit hash inside. It only holds the newest commit.
- **I learned** that every commit saves its parent's hash inside itself. I saw this with git cat-file -p. So old commits never get lost, the branch is just a pointer to the last one.
- **I learned** that the same content always gets the same hash.
- **I learned** that origin is just a name for the GitHub repo's address. .git/config keeps the remote name, the URL and the tracking info.
- **I learned** the difference between my local main and origin/main. Local main is my own latest commit. origin/main is the last commit I saw on GitHub, and it is not live, it only updates when I talk to GitHub.
- **I learned** that git status shows what changed since my last commit, so I can see what will go into the next commit and push.
- **I learned** that Git doesn't track empty folders. People put a .gitkeep file inside to get around this.
- **I learned** that HTTPS and SSH are both encrypted. The difference is how you prove who you are. With SSH it's a private key that never leaves my computer, with HTTPS it's a token. Public key is the lock, private key is the key.
- **I learned** that you can't make a branch before the first commit.

---

## Part 1: Azure account and not losing money

### What I did
- I made a monthly budget of 5 with email alerts at 50%, 80% and 100%.
- I decided to put everything for this project in one resource group.
- I put the 30th day of my account and a weekly "check Cost analysis" reminder in my calendar.

### What I learned
- **I learned** the Azure hierarchy: management group, subscription, resource group, resources.
- **I learned** why one resource group is the best way: I can see what this project costs in one place, and if I delete the group, everything inside goes with it, nothing is left behind that keeps costing money.
- **I learned** why budget alerts matter. The free credit runs out after 30 days, and after that anything over the free limits is real money.
- **I learned** the difference between the 30 day credit and the 12 month free services.

---

## Part 2: Creating the VM and connecting with SSH

### What I did
- I created my first Linux virtual machine on Azure.
  - Region: Austria East
  - Size: B2ats v2 (in the free 12 month list)
  - OS: Ubuntu 24.04
  - Disk: Premium SSD 64 GiB (P6, this one is in the free list, not Standard SSD)
  - Login with SSH key, no password
  - Only the SSH port is open
- I had a problem with the free size not being in my region. I fixed it by picking the right region.
- I set up the disk and network settings so they get deleted together with the VM.
- I saved the private key in ~/.ssh and gave it 400 permissions, so only I can read it.
- I added a shortcut in ~/.ssh/config. Now I connect with one word: azure1.
- I left SSH open to the internet on purpose, so bots will come and I can record them.

### What I learned
- **I learned** the rules of Azure free services and how to stay inside them.
- **I learned** what NSG rules are and how to set them.
- **I learned** why SSH refuses a private key that other people can read, and how to fix the permissions.
- **I learned** how ~/.ssh/config works, so I don't type the IP and key path every time.
- **I learned** the difference between public IP and private IP. My server only sees its private IP. Azure turns the public IP into the private one with NAT.

---

## Part 3: Getting to know the server and updating it

### What I did
- I answered the basic "what is this server" questions with commands.
- I updated the system.
- I changed the timezone from UTC to Europe/Budapest.
- I looked at the running services and explained 5 of them.
- I wrote one line for each important directory.

### Server ID card
| Question | Tool | Answer |
| --- | --- | --- |
| Who am I / my groups | whoami, groups | azureuser; adm, cdrom, sudo, dip, lxd |
| Hostname / OS / kernel | hostnamectl | ubuntu24, Ubuntu 24.04.5 LTS, Linux 7.0.0-1017-azure |
| Uptime / load | uptime | up 19h 49m, load average 0.20 / 0.14 / 0.10 |
| CPU | lscpu, /proc/cpuinfo | 2 CPUs, AMD EPYC 7763 64-Core Processor |
| RAM | /proc/meminfo | MemTotal 908396 kB (about 1 GiB) |
| Disk | df -Th | 61G, 2.2G used |
| Disks / partitions | lsblk | sda with sda1, sda14, sda15, sda16 |
| Processes | ps -ef | a lot of them |
| Running services | systemctl list-units --type=service --state=running | see below |

### 5 running services
- **chrony:** keeps the server clock correct (NTP). This matters because my log times need to be right.
- **dbus:** a background daemon that lets programs send messages to each other, like a post office. For example hostnamectl asks systemd for info through D-Bus.
- **ModemManager:** manages mobile internet modems (USB 4G/5G sticks, SIM modems). My VM has no modem, it's just there because it comes with Ubuntu.
- **ssh:** the SSH server. In its status I saw login tries with names like "admin". That wasn't me, those were bots! The attacks already started before the VM was even 20 hours old.
- **fwupd:** helps install firmware updates from hardware makers. Not much use on a VM.

### Directories
- **/etc:** config files for the system and programs (the name comes from "et cetera")
- **/var/log:** system and service logs
- **/home:** home folders of normal users
- **/usr/bin:** binaries of user programs
- **/tmp:** temporary files
- **/srv:** data the server gives out (websites, FTP)
- **/proc:** a special filesystem that shows info about the system and processes

### What I learned
- **I learned** how to understand a new server in a few minutes: OS, kernel, CPU, RAM, disk, processes and services.
- **I learned** the difference between apt update and apt upgrade. update only refreshes the package list, upgrade really installs new versions.
- **I learned** that after updates like a new kernel you need a reboot, and Ubuntu tells you by creating /var/run/reboot-required.
- **I learned** that enabled and running are different. enabled means "start at boot", running means "working right now". list-unit-files shows the file state, list-units shows what is happening now.
- **I learned** that the Hyper-V UEFI line is the firmware version, not the kernel.
- **I learned** to read /proc/stat right. The top "cpu" line is not a third CPU, it's cpu0 + cpu1 together (4560 + 4670 = 9230). The "processes" number is not how many processes run now, it counts from boot.
- **I learned** that I don't need to memorize the directory tree. I just need the idea: every directory is for one type of data.

---

## Part 4: Users, groups and permissions

### What I did
- I compared the permissions of /etc/passwd and /etc/shadow.
- I made a new user called analyst with no sudo rights, and checked it two ways.
- I made a file in my home folder and tried to read it as analyst. It didn't work, and I proved it was the folder that stopped him, not the file.
- I made a group called reports and put me and analyst in it.
- I made /srv/reports: owner root, group reports, the group can do everything, others can't do anything, and new files inside get the reports group by themselves (setgid).
- I found my own sudo commands in the auth log.

### Commands I used
| What I wanted | Command | What I saw |
| --- | --- | --- |
| passwd permissions | ls -l passwd | -rw-r--r-- root root |
| shadow permissions | ls -l shadow | -rw-r----- root shadow |
| Can analyst use sudo? | sudo -lU analyst | "not allowed to run sudo" |
| analyst's groups | groups analyst | analyst users (no sudo group) |
| Become analyst | su analyst | asked for analyst's password |
| Go into my home as analyst | cd azureuser/ | Permission denied |
| Read my file as analyst, without cd | cat azureuser/newFile | Permission denied |
| Make the folder | sudo mkdir reports (in /srv) | |
| Owner root, group reports | sudo chown -R root:reports /srv/reports/ | root reports |
| Group can do everything, others nothing | sudo chmod -R 770 /srv/reports/ | drwxrwx--- |
| Take off the wrong bit | sudo chmod u-s /srv/reports/ | |
| Turn on setgid | sudo chmod g+s /srv/reports/ | drwxrws--- |
| Test the setgid | mkdir newFolder (in /srv/reports) | newFolder got group reports, not azureuser |
| My sudo history | grep "sudo" auth.log | user, TTY, PWD, USER=root, COMMAND |

### What I learned
- **I learned** to read the 10 letters: first one is the file type (- normal file, d folder, l link), then 3 for the owner, 3 for the group, 3 for everyone else.
- **I learned** that the group part is for the file's own group, not "people in the owner's group".
- **I learned** why passwords are not in /etc/passwd anymore. Everyone can read that file, so everyone could take the hashes and try to crack them. Now the hashes are in /etc/shadow, which only root and the shadow group can read.
- **I learned** that man pages have sections. The passwd command and the passwd file have different pages (the file is section 5).
- **I learned** that useradd is low level: no password, no home folder by default. adduser does all of that for you.
- **I learned** what r, w, x mean on a folder: r = see the names inside, x = go through it (cd, open things by name), w = make or delete things inside (needs x too).
- **I learned** that to reach a file, every folder on the way has to let you through. If one folder says no, the file's own permission doesn't matter.
- **I learned** that permissions belong to files and folders, not to users. My home and analyst's home are both drwxr-x--- because that's Ubuntu's default, not because of who we are.
- **I learned** the numbers: 4 = r, 2 = w, 1 = x. 640 = owner rw, group r, others nothing.
- **I learned** the 4th digit in front: 4 = setuid, 2 = setgid, 1 = sticky. 2770 = owner and group everything, others nothing, new stuff inside gets the folder's group.
- **I learned** what the special bits do:
  - setuid on a program: it runs with the owner's power (the passwd program runs as root, so it can write to shadow).
  - setgid on a folder: new files and folders inside get the folder's group. New folders even get the setgid bit too, so it goes all the way down.
  - sticky bit: you can only delete your own files (like /tmp).
- **I learned** that su asks for the other user's password, but sudo asks for my own. sudo checks the rules and then logs who did what.
- **I learned** the difference between sudo and file permissions. sudo answers "who can I become?" (azureuser gets it from the sudo group). File permissions answer "what can I touch with who I am?" and the kernel checks them every time.
- **I learned** to read a sudo line in auth.log: who ran it, from which terminal, in which folder, as which user, and the full command.
- **I learned** that the times in auth.log end with +00:00, which means UTC. Budapest is one hour ahead.

## Part 5: SSH hardening and two-layer firewall

### What I did
- I checked sshd's real settings with sshd -T, not just by reading the config files.
- I set up the Azure Serial Console as my way back in, in case I lock myself out.
  - First I set root's password by mistake (I ran passwd with sudo but forgot the username).
  - Then I gave azureuser a password, logged in to the Serial Console as azureuser and checked that sudo works there.
  - Then I locked root's password again, so it's back to how Ubuntu ships it.
- I looked inside /etc/ssh/sshd_config.d and found three files that came with the VM (50-cloudimg-settings, 50-cloud-init, 60-cloudimg-settings).
- I wrote my own hardening file 40-hardening-settings.conf, tested it, reloaded ssh and connected from a second terminal with my first session still open.
- I set up ufw: SSH allowed first, then deny incoming / allow outgoing, then enable.
- I looked at the NSG inbound rules in the Azure portal.
- I did the two-layer lab with a Python web server on port 8080, then cleaned everything up.

### Commands I used
| What I wanted | Command | What I saw |
| --- | --- | --- |
| sshd's real settings | sudo sshd -T | every setting, lowercase, one per line |
| Lock root's password | sudo passwd -l root | password changed |
| Password status | passwd -S / sudo passwd -S | azureuser P / root L |
| Make my own file | sudo nano 40-hardening-settings.conf | saved in sshd_config.d, owned by root |
| Test the config | sudo sshd -t | nothing printed = OK |
| Exit code of the last command | echo $? | 0 |
| Reload ssh | systemctl reload ssh.service | polkit asked for my password |
| Check the reload | systemctl status ssh.service | "Reloaded ssh.service" |
| Firewall state | sudo ufw status verbose | deny incoming, allow outgoing, only 22/tcp open |
| Rules with numbers | sudo ufw status numbered | [1], [2] ... |
| Delete a rule | sudo ufw delete 2 | asks first, numbers shift after |
| Web server only on localhost | python3 -m http.server 8080 --bind 127.0.0.1 | Serving HTTP on 127.0.0.1 port 8080 |
| Who listens where | ss -lr | localhost:http-alt (numeric option shows 127.0.0.1:8080) |

### My hardening file
| Setting | Value | Why |
| --- | --- | --- |
| PasswordAuthentication | no | Already off from the VM's own files, but I want it in my file too, so nothing can turn it back on. |
| KbdInteractiveAuthentication | no | Another way to log in with a password. Same reason. |
| PermitRootLogin | no | root is the name every bot tries first. Nobody logs in as root, not even with a key. |
| LoginGraceTime | 30 | My key login takes a few seconds. 120 was way too long. |
| MaxAuthTries | 4 | My client can offer more than one key. 4 gives room, still lower than 6. |

### Two-layer lab
| Step | Result | Why |
| --- | --- | --- |
| Server on 0.0.0.0:8080, nothing opened | timeout | NSG dropped it |
| ufw opened for 8080 | timeout | NSG still dropped it, ufw never saw the packet |
| NSG opened too (priority 1000) | page loads, GET / 200 in the terminal | both doors open |
| Server on 127.0.0.1:8080 | refused | packet got in, but nobody listens on the private IP |

### What I learned
- **I learned** that sshd -T is the truth. The config is split over many files and lines with # are just comments. Also: ssh is the client on my Mac, sshd is the server on the VM.
- **I learned** that "without-password" means root can't use a password but CAN use a key. We close root fully because it's the most guessed name, and azureuser + sudo leaves a record of who did what.
- **I learned** that MaxAuthTries counts every key my client offers, so too low locks me out. LoginGraceTime is how long you get to finish logging in. ClientAlive is for open sessions, not login.
- **I learned** that the Serial Console is like plugging a keyboard into the server. It doesn't use SSH, so it still works when SSH or the firewall is broken. root is locked, so I log in as azureuser and use sudo.
- **I learned** that sudo passwd with no username changes root's password. L = locked, P = password set. Lock is safe, delete makes the password empty, so never delete.
- **I learned** the safety order: make sure the new way in works first, then close the old one. Same for ufw: open SSH first, enable last.
- **I learned** that sshd uses the FIRST value it finds. Include sits at the top, and files are read in lexical order (letter by letter, so "100-" comes before "50-"). My "40-" file wins. It must end in .conf.
- **I learned** that when I can't write a file in /etc, the fix is sudo, NOT giving others write permission.
- **I learned** the safe way to change sshd: test with sshd -t (silence = exit code 0), reload (not restart), connect from a second terminal, check with sshd -T.
- **I learned** that ufw and NSG are both stateful: they remember connections, so replies to my own outgoing traffic get back in, and deleting a rule doesn't kill an open session. To test a rule I always need a NEW connection.
- **I learned** that in NSG a lower number means higher priority, first match wins, and Azure's own rules sit at 65000+. Priority only matters when rules match the same traffic.
- **I learned** that NSG and ufw are two doors in a row: internet → NSG (outside the VM) → ufw (inside the VM) → the program. If NSG drops the packet, ufw never sees it.
- **I learned** the difference between timeout and refused. Timeout = a firewall (NSG or ufw) silently dropped the packet. Refused = the packet reached the machine, but nothing listens on that address and port.
- **I learned** that binding to 0.0.0.0 means "listen on every address of this machine", and binding to 127.0.0.1 means "only this machine can reach me". Every machine has its own loopback.

## Part 6: Seeing the attacks: logs, grep, pipes

### What I did
- I watched auth.log live with tail and read the ssh journal with journalctl.
- I picked real lines from the log and sorted them into types.
- I checked that every successful login was me: the "Accepted" lines, last, and my own public IP.
- I built every pipe one piece at a time and looked at the output after each step.
- I wrote my own IPv4 regex and tested it on regex101.
- I found "duplicate" IP + port pairs in my data and proved they were two different connections.
- I read the logrotate config for auth.log.

### Findings (auth.log, 2–7 November 2026, log times are UTC)
| Question | Answer |
| --- | --- |
| VM created | 1 Nov 23:58 UTC (Azure Activity log) |
| First login attempt | 2 Nov 00:01:57 UTC, about **4 minutes** later, empty username, from 109.160.32.124 |
| Invalid user attempts | 3811 |
| ...of those that did not end with "Connection closed" | 507 (they ended with reset, disconnect or timeout) |
| Different IPs that tried to log in | 125 (scanners that only knock are not counted) |
| Successful logins | only me |
| Rotated log files | none yet, the VM is less than a week old |

**Top 10 usernames**
| Username | Tries |
| --- | --- |
| admin | 912 |
| user | 527 |
| ubuntu | 378 |
| debian | 287 |
| user2 | 129 |
| oracle | 67 |
| test | 65 |
| guest | 65 |
| pi | 44 |
| postgres / developer | 39 (tie) |

**Top 10 IPs (Invalid user + authenticating user)**
| IP | Tries |
| --- | --- |
| 45.43.159.119 | 412 |
| 114.80.32.225 | 412 |
| 39.164.126.118 | 407 |
| 43.231.63.148 | 337 |
| 2.57.122.76 | 326 |
| 92.118.39.14 | 313 |
| 195.178.110.218 | 311 |
| 92.118.39.71 | 274 |
| 171.243.149.187 | 251 |
| 117.50.208.104 | 194 |

**Busiest hours (Budapest time, UTC+1):** 18:00 (1094), 06:00 (885), 13:00 (679), 19:00 (677). The quietest hour still has more than 100 tries.

**Interesting things**
- Bots try default usernames of cloud images and services: ubuntu, debian, ec2-user, pi, oracle, postgres.
- They also try names like claude, codex, cursor, deepseek (AI dev servers) and solana, eth-validator, bankadmin (crypto and finance).
- 45.43.159.119 and 114.80.32.225 had exactly the same count twice (330, then 412). Probably the same botnet with the same script and word list.
- 92.118.39.14 and 92.118.39.71 come from the same /24 block.
- 2.57.122.150 first only scanned, then came back 10 minutes later and tried root.

### Commands I used
- Count the wrong line type (end lines): `grep -c "Connection closed by invalid user" auth.log` → 3304
- Top usernames: `grep "Invalid user" auth.log | awk '{print $6}' | grep -v "from" | sort | uniq -c | sort -nr`
- Top 10 IPs: `grep -e "Invalid user" -e "authenticating user" auth.log | grep -Eo '(([0-9]{1,3}\.){3})[0-9]{1,3}' | sort | uniq -c | sort -nr | head`
- Number of different IPs: `grep -e "Invalid user" -e "authenticating user" auth.log | grep -Eo '(([0-9]{1,3}\.){3})[0-9]{1,3}' | sort | uniq -c | wc -l` → 125
- IP + port pairs seen twice: `grep -e "Invalid user" -e "authenticating user" auth.log | grep -Eo '((([0-9]{1,3}\.){3})[0-9]{1,3})\s(port\s[0-9]{1,5})' | sort | uniq -c | sort -nr | head`
- Check one pair: `grep -E '39.164.126.118\s(port\s55466)' auth.log` → 9 minutes apart, different PIDs
- Tries per hour: `grep -e "Invalid user" -e "authenticating user" auth.log | grep -Eo T[0-9]{2} | grep -Eo [0-9]{2} | sort | uniq -c`
- logrotate settings: `cat rsyslog` in /etc/logrotate.d

### What I learned
- **I learned** the auth.log line types. "Connection closed by IP port" with no user = a scanner that only knocks. "Invalid user" = the name does not exist on my server. "authenticating user" = the name exists (like root), but the bot still got rejected. [preauth] is not an event type, it only means "before login finished".
- **I learned** that the changing port in the log is the attacker's own source port (ephemeral port). Every try hits my port 22.
- **I learned** to count the line that is written exactly once per attempt (the start line), not the end line, because a connection can end in different ways.
- **I learned** that grep is case sensitive, and so are its options. The recursive option searches the whole folder and ignores what comes from the pipe.
- **I learned** that uniq only merges lines that are next to each other, so sort has to come first.
- **I learned** that awk splits on runs of spaces, so an empty username moves every field by one. That is how "from" showed up as a username.
- **I learned** to find data by its shape (regex) or by a fixed word next to it ("port", the "T" in the timestamp), not by its position in the line.
- **I learned** that {} and () need grep's extended mode, and \d, \b and lookahead only work in Perl mode. awk does not have them.
- **I learned** that a repeated value is not automatically a mistake. The PID and the timestamp show if it is one connection or two. One PID = one connection.
- **I learned** that bots never sleep. There is no quiet hour, only campaign peaks.
- **I learned** the logrotate settings: weekly, keep 4 old files, compress, delaycompress. So auth.log.1 stays plain text and only .2.gz and older are compressed. zgrep can read both.

## Part 7: Network basics on my own server

### What I did
- I found my server's IP, subnet and default gateway, and compared them with the VNet and subnet in the Azure portal.
- I worked out /24, /16 and /28 by hand.
- I listed every port my server listens on and which program owns it.
- I found which DNS server my server uses.
- I looked up an A record and a CNAME, then followed a name from the root servers down, step by step.
- I looked up reverse DNS and whois for the top 10 attacker IPs from Part 6.
- I caught real bot traffic on port 22 with tcpdump: one SYN scan and one full handshake.
- I sent an HTTPS request with verbose curl and found the IP, TLS version, certificate, request line and status code.
- I traced the path to a website from the server (mtr) and from my Mac (traceroute).
- I wrote down what happens when you type a URL in the browser.

### Listening ports
| Program | Proto | Address | Port | What it does |
| --- | --- | --- | --- | --- |
| systemd-networkd | UDP | 172.16.0.4 (eth0) | 68 | DHCP client. Got my IP, gateway and DNS from Azure. |
| chronyd | UDP | 127.0.0.1, [::1] | 323 | Control port for chronyc, local only. Time sync goes out by itself. |
| systemd-resolved | UDP + TCP | 127.0.0.53 | 53 | Local DNS stub for programs on this server. |
| systemd-resolved | UDP + TCP | 127.0.0.54 | 53 | Second local DNS address. |
| sshd (port held by systemd) | TCP | 0.0.0.0, [::] | 22 | SSH, open to everyone on IPv4 and IPv6, key only. |

The only door open to the outside is 22. That matches my NSG and ufw rules.

### Who are the top 10 attackers?
| IP | PTR | Netname | Country |
| --- | --- | --- | --- |
| 45.43.159.119 | none | VDSKA-ONLINE | KZ |
| 114.80.32.225 | none | CHINANET-SH | CN |
| 39.164.126.118 | none | CMNET | CN |
| 43.231.63.148 | static-148-63-231-43.ebonenet.com | EBONE1-PK | PK |
| 2.57.122.76 | none | DMZHOSTdotco | NL |
| 92.118.39.14 | none | DMZHOST | NL |
| 195.178.110.218 | none | TECHOFF_SRV_LIMITED | AD |
| 92.118.39.71 | none | DMZHOST | NL |
| 171.243.149.187 | dynamic-ip-adsl.viettel.vn | VIETTEL-VN | VN |
| 117.50.208.104 | none | UCLOUD-NET | CN |

- Most of them are rented servers (hosting and cloud). The rest are big internet providers.
- 3 of the 10 come from DMZHOST.
- "dynamic-ip-adsl" means a home connection, so probably a hacked home device.
- Country means where the IP block is registered, not where the attacker really is.

### Paths
| From → to | Time | Note |
| --- | --- | --- |
| Azure → github.com | ~15 ms | all middle hops hidden |
| Azure → inf.unideb.hu | ~9 ms | all middle hops hidden |
| Mac → inf.unideb.hu | ~15 ms | two private hops (double NAT), my ISP, peering with HBONE (AS1955), core router probably in Budapest, then Debrecen |

My Azure server in Vienna reaches my university faster than my home in the same city.

### What happens when I type a URL
1. **DNS:** First the browser, the OS and the resolver check their caches. If nobody has it, the resolver asks root → TLD → authoritative. I get the IP, sometimes through a CNAME first.
2. **Routing:** That IP is not in my subnet, so the packet goes to the default gateway, through NAT, out with my public IP, and over many routers.
3. **TCP:** The browser sends SYN to port 443, the server answers SYN-ACK, the browser sends ACK. The connection is open.
4. **TLS:** Inside that connection the server shows its certificate. The browser checks the name and the chain, and they agree on keys. From now on everything is encrypted.
5. **HTTP:** The browser sends GET with a Host header. The server sends back a status code (200, 301, 404...) and the page.
6. **Done:** The browser draws the page. The connection closes with FIN, or with RST if something breaks.

### What I learned
- **I learned** that /N means the first N bits are fixed. Addresses = 2^(32-N), usable hosts = that minus 2 (network and broadcast).
- **I learned** that private ranges are a fixed list: 10/8, 172.16/12, 192.168/16. Internet routers never route them.
- **I learned** that the VNet is the whole building and the subnet is one floor.
- **I learned** to read ss: 0.0.0.0 and [::] are open to all, 127.x and [::1] are local only. I need sudo to see other users' processes.
- **I learned** that DNS goes root → TLD → authoritative, and each one only points to the next.
- **I learned** that whois shows who owns the IP block, not who the attacker is.
- **I learned** the TCP flags: SYN, SYN-ACK, ACK opens. FIN closes nicely, RST cuts. A scanner does SYN, SYN-ACK, RST.
- **I learned** that refused = RST right away (nobody listening) and timeout = no answer at all (a firewall dropped it).
- **I learned** to read verbose curl: * is curl's own notes, > is what I send, < is what comes back.
- **I learned** that any status code means HTTP worked. 4xx = client's fault, 5xx = server's fault. 502 = the proxy got no good answer from the app behind it.
- **I learned** that in mtr, loss in the middle is fine. Only loss all the way to the end is a real problem.

## Part 8: Nginx, systemd and the break-it lab

### What I did
- I installed nginx and checked that it is active (running now) and enabled (starts at boot).
- I opened port 80 in ufw (TCP only) and in the NSG, and saw the page from my Mac.
- I turned off the default site and wrote my own site config for /var/www/attackwatch,
  as the default_server with server_name _.
- I found the 20 paths bots ask for most in the access log.
- I broke the server in 7 ways on purpose, found the cause each time and wrote an
  incident note for each one in docs/incidents/.
- I set up a reverse proxy from /api/ to an app on 127.0.0.1:5000.

### What bots look for on port 80
Almost every request is a hunt for secrets left on the web by mistake:
- /.env and its backups (.bak, .old, .save, ~): database passwords and API keys.
- /.git/config, /.git/HEAD: a whole repo with its history.
- /wp-config.php and .bak: WordPress database password.
- /info.php, /phpinfo.php: full server config.
- /mcp, /sse: AI tool servers left open without login.
- Some bots test if my server is an open proxy (GET http://ip-api.com/..., CONNECT).
- Some send TLS handshakes or other protocols to port 80, nginx answers 400.

Everything they asked for got 404. Nothing to find.

### The 7 incidents
| # | What I broke | What I saw | Where the cause was |
| --- | --- | --- | --- |
| 1 | stopped nginx | refused in 28 ms | systemctl status, ss (no :80) |
| 2 | removed a semicolon, restart | failed to start, refused | status/journal, config test (line 7, mistake on line 5) |
| 3 | index.html to 640 | 403 | error.log: open() failed (13: Permission denied) |
| 4 | second server on port 80 | errno 13 without sudo, errno 98 with sudo | ss with process names: nginx holds 80 |
| 5 | deleted NSG rule for 80 | timeout after 75 s | tcpdump: no packets at all |
| 6 | 3 GB file in /etc | df 4% → 9% | du, one level at a time |
| 7 | /api/ proxy to 127.0.0.1:5000, no app | 502 | error.log: connect() failed (111: Connection refused) |

### Commands I used
- Is nginx running / enabled: `systemctl is-active nginx` → active, `systemctl is-enabled nginx` → enabled
- Test the nginx config: `sudo nginx -t` → "syntax is ok", "test is successful"
- Top 20 paths from access.log: `awk '$1 != "<my IP>" && $1 != "<server IP>" && $1 != "127.0.0.1" {print $0}' access.log | awk -F'"' '{print $2}' | awk '{print $2}' | awk '$1 ~ /^\//' | sort | uniq -c | sort -nr | head -20`
- Who holds port 80: `sudo ss -lntpu | grep ':80'` → nginx master + 2 workers, fd=5
- Catch only my port 80 traffic: `sudo tcpdump -i any -nn 'host <my public IP> and tcp port 80'`
- Find what fills the disk: `sudo du -h --max-depth=1 /` → /etc 3.1G, then `sudo du -h --max-depth=1 /etc/` → /etc/myTestFlie 3.1G

### What I learned
- **I learned** that systemd is PID 1 and manages everything as units. active = running now,
  enabled = starts at boot. I have to check both.
- **I learned** that sites-available is the library and sites-enabled has symlinks to what is on.
- **I learned** that without default_server, the first server block for a port catches
  everything. server_name _ is just a name that never matches.
- **I learned** that every line in access.log is one request, so I only filter out my own IPs
  and then cut out the path.
- **I learned** that the nginx master runs as root (to open port 80, a privileged port) and the
  workers run as www-data. Workers fall into "others" for files owned by root.
- **I learned** that errors in nginx logs are the kernel's errno values: 2 = no such file,
  13 = permission denied, 98 = address in use, 111 = connection refused.
- **I learned** that the line number in an error is where the program noticed the problem,
  not always where I made the mistake.
- **I learned** to use reload, not restart, after a config change. With a broken config, reload
  keeps the old one running. Restart takes the site down.
- **I learned** that refused is fast (RST), timeout is slow and silent (a firewall dropped it).
- **I learned** to do a positive check before trusting silence. My Mac's en0 address is my
  private home IP, the server sees my public IP because of NAT.
- **I learned** that df shows THAT the disk is filling, du shows WHERE.
- **I learned** that 403 = nginx can't read the file, 502 = nginx works but the app behind it
  doesn't answer.
- **I learned** that a reverse proxy keeps the app on 127.0.0.1. Only port 80 is open, nginx
  reaches the app over loopback.
- **I learned** that behind a proxy the Server header can lie. The body and the app's own log
  show who really answered.

### Weak spots
- Skipping the positive check (wrong IP in tcpdump).
- Reading numbers in output too fast (df, body size vs status code, cut-off status lines).
- nginx syntax: semicolons, mixing up directive names. Always run the config test.
- Mixing up refused and timeout words (RST vs nothing, NSG vs ufw).

### Next time
- Start Part 9: the skeleton of scripts/attack-report.sh.
