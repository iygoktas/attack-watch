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

## Part 5: SSH hardening and two-layer firewall (in progress)

### What I did (session 1)
- I checked sshd's real settings with sshd -T, not just by reading the config files.
- I saw that key login was on, password login was off, and root could still log in with a key.
- I set up the Azure Serial Console as my way back in, in case I lock myself out.
  - First I set root's password by mistake (I ran passwd with sudo but forgot the username).
  - Then I set a password for azureuser, logged in to the Serial Console as azureuser and checked that sudo works there.
  - Then I locked root's password again, so it's back to how Ubuntu ships it.
- I looked inside /etc/ssh/sshd_config.d and found two files that came with the VM.
- I wrote my own hardening file: 40-hardening-settings.conf. It's not active yet, sshd only reads it after a reload.

### Commands I used
| What I wanted | Command | What I saw |
| --- | --- | --- |
| sshd's real settings | sudo sshd -T | every setting, lowercase, one per line |
| Lock root's password | sudo passwd -l root | password changed |
| Password status | passwd -S / sudo passwd -S | azureuser P / root L |
| Files that came with the VM | cat 50-cloudimg-settings.conf, sudo cat 50-cloud-init.conf | ClientAliveInterval 120 / PasswordAuthentication no |
| Make my own file | sudo nano 40-hardening-settings.conf | saved in sshd_config.d, owned by root |

### My hardening file
| Setting | Value | Why |
| --- | --- | --- |
| PasswordAuthentication | no | Already off from cloud-init, but I want it in my own file too, so no other file can turn it back on. |
| KbdInteractiveAuthentication | no | Another way to log in with a password. Already off, same reason. |
| PermitRootLogin | no | root is the name every bot tries first. Nobody logs in as root, not even with a key. |
| LoginGraceTime | 30 | My key login takes a few seconds. 120 was way too long and lets bots hold open connections for nothing. |
| MaxAuthTries | 4 | My client can offer more than one key (Azure key + GitHub key). 4 gives room, still lower than 6. |

### What I learned
- **I learned** that sshd -T is the truth. The config is split over many files and lines with # are just comments, so reading one file can fool you. Also: ssh is the client on my Mac, sshd is the server on the VM.
- **I learned** that "without-password" is the old name for "prohibit-password": root can't use a password but CAN use a key. We close it fully because root is the most guessed name, and logging in as azureuser + sudo leaves a record of who did what.
- **I learned** that PasswordAuthentication no came from cloud-init, because I picked "SSH public key" in Azure.
- **I learned** that MaxAuthTries counts tries per connection and every key my client offers is one try, so too low locks me out. LoginGraceTime is how long you get to finish logging in. ClientAlive is for already open sessions, not login.
- **I learned** that the Serial Console is like plugging a keyboard into the server. It doesn't use SSH, so it still works if I break SSH or the firewall, but it needs a real password.
- **I learned** that sudo passwd with no username changes root's password, not mine. As azureuser, passwd asks for my current password; root doesn't need it.
- **I learned** that L = locked, no usable password, P = password set. Lock is safe, delete makes the password empty, so never delete. A password on azureuser doesn't help bots, because SSH password login is off.
- **I learned** the safety order: first make sure the new way in works, only then close the old one.
- **I learned** that sshd uses the FIRST value it finds (most programs use the last). Include sits at the top of sshd_config, so files in sshd_config.d beat the main file.
- **I learned** that Include reads files in lexical order, letter by letter, not as numbers ("100-x" comes before "50-x"). My "40-" file comes before the "50-" files, so it wins. It also has to end in .conf or sshd never sees it.
- **I learned** that when I can't write to a file in /etc, the fix is sudo, NOT giving "others" write permission. Otherwise any user could edit the sshd config and own the server.
- **I learned** that writing the file changes nothing until sshd reloads.

### Next time
- Test the config without applying it (look for "test mode" in man sshd).
- Find out the difference between reload and restart, and pick one.
- Keep my current session open and try to connect from a second terminal.
- Check with sshd -T that all five settings changed.
- Then ufw.