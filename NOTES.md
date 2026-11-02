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

### Next time
- Part 4: compare the permissions of /etc/passwd and /etc/shadow.