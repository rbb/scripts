Command Line Tips
=================

Most of these came from <http://rubytune.com/cheat>

### Process Basics
-   All processes, with params + Hierarchy: `ps auxww`
-   Show all ruby-related PIDs and processes: `pgrep -fl ruby`
-   What is a process doing: `strace -f -p $PID`
-   What files does a process have open: `lsof -p $PID`
-   `pkill <name of process>`
-   Keep an eye on a process: `watch 'ps aux|grep <proc name>'`

### Tips N Tricks
- Change to last working dir: `cd -`
- Run forever: `while true;do foo; sleep 1;done`
- List PCI devices: `lspci`
- List USB devices: lspci
- Re-run the previous command with sudo: `sudo !!`
- Print the last cat command: `!cat:p`
- In OSX, prevent sleeping (for 1 hour) with: `caffeinate -t 3600`
    - Note: you can install in ubuntu with the following pap: `sudo add-apt-repository ppa:caffeine-developers/ppa`
- Open a serial console at device/file = /dev/ttyS0 and baudrate = 115200
    - Using Minicom (only newer versions support -D and -b): `minicom -D /dev/ttyS0 -b 115200`
    - When in Minicom, "Ctrl-a e" to turn on local echo
    - Using Screen: `screen /dev/ttyS0 115200`
    - When in Screen, "Ctrl-a esc" to enter the copy/scroll mode,
            which will enable page-up/down among other things
- grep with **or** : `grep 'pattern1\|pattern2' filename`
- Get (ubuntu) kernel and release info:
    -   Kernel version: `uname -a`
    -   Detailed kernel: `cat /proc/version`
    -   Ubuntu version: `lsb_release -a`
    -   partition info: `sudo fdisk -l`
- Find out if CPU is 32 or 64 bit: `sudo lshw`
- Check logs. Note: different unix systems use different logging mechanisms.
    - `dmesg`
    - `cat /var/log/syslog` or generally, anything in `/var/log` or
      `/tmp/log` or on some embedded systems, even just `/tmp`.
    - See [Ubuntu](http://askubuntu.com/questions/26237/difference-between-var-log-messages-var-log-syslog-and-var-log-kern-log) and [Stackoverflow](http://stackoverflow.com/questions/10979435/where-does-linux-store-my-log) for more info.
- (In Ubuntu) Make a locally compiled program the default for opening a particular filetype
    (from [ubuntugenius](http://ubuntugenius.wordpress.com/2012/06/18/ubuntu-fix-add-program-to-list-of-applications-in-open-with-when-right-clicking-files-in-nautilus/)
    `mimeopen -d Recipes.pdf`, which will return something like the menu below. 
    Select \#4, then supply the command, maybe its something like `/opt/myapp/bin/imagefoo`
    ```
     Please choose a default application for files of type application/pdf
    
    1) GIMP Image Editor (gimp)
    2) Adobe Reader 9 (AdobeReader)
    3) Document Viewer (evince)
    4) Other...
    ```

### Memory
- How much mem is free? [Learn how to read output](http://www.linuxatemyram.com/): `free -m`, `cat /proc/meminfo`
- Are we swapping ([First line is avg since boot](http://library.linode.com/linux-tools/common-commands/vmstat)): `vmstat 1`
- Top 10 memory hogs: `ps aux|head -1 && ps aux|sort -k 4 -nr | head`
- Detect OOM other bad things: `for i in messages kern.log syslog; do egrep -i "s[ie]g|oo(m|ps)" /var/log/$i{,.0}; done`
- Disable OOM killer for a process: `echo -17 > /proc/$PID/oom_adj`

### Disk/Files
- Check reads/writes per disk: `iostat -xnk 5`
- Files (often logs) marked for deletion but not yet deleted: `lsof | grep delete`
- Overview of all disks: `df -hs`
- Usage of this dir and all subdirs: `du -hs`
- Find files over 100MB:`find ./ -size +100000000c -print`
- Find files created in the last 7 days: `find ./ -mtime 2 -o -ctime 2`
- Find file older than 14 days: `find *.gz -mtime +14 -type f;`
- Find and grep files (equiv to one grep command per find): `find . -type f -exec grep foo {} \;`
- Find and grep files (equiv to one grep command with all found files): `find . -type f -exec grep foo {} +`
- Delete (or other action) on files older than 14 days: `find *.gz -mtime +14 -type f -exec rm {} \;`
- Generate a large file (count \* bs = total bytes): `dd if=/dev/zero of=file.txt count=1024 bs=102`
- To have a CIFS server share mounted on boot, add a line like the one below, with `[user]` and `[password]` replaced as appropriate, to `/etc/fstab`:
    ```
    //192.168.221.10/public /home/Public cifs username=[user],password=[password],uid=[user],dirmode=0777,file_mode=0777,gid=[user],nounix,noserverino,rw
    ```

### Network
-   TCP sockets in use:
    -   `lsof -nPi tcp`
    -   `netstat -lnp`
-   Get IP/Ethernet Info: `ip addr, ifconfig`
-   Set extra ethernet address on same interface (as eth0): `sudo ifconfig eth0:1 <ip_addr>`
-   Remove extra IP address from an interface: `sudo ifconfig eth0:1 down`
-   host &lt;=&gt; IP resolution: `host <ip_addr&gt`;, `host <hostname>`
-   Curl, display headers (I), follow redirects (L): `curl -LI http://google.com`
-   Traceroute with stats over time (top for traceroute) [Requires install](http://www.bitwizard.nl/mtr/index.html): `mtr google.com`
-   Traceroute using TCP to avoid ICMP blockage: `tcptraceroute google.com`
-   Firewall/iptables:
    -   List any IP blocks/rules, with packet counts: `iptables -vnL`
    -   List any IP blocks/rules with packet counts, but for NAT tables: `iptables -vnL -t nat`
    -   Drop any network requests from IP: `iptables -I INPUT -s 66.75.84.220`
-   Show traffic by port: `iftop`
-   Show all ports listening with process PID: `netstat -tlnp`
-   Connect to GPSd stream: `nc <host> 2947`
-   Other uses for netcat (nc): (http://mylinuxbook.com/linux-netcat-command/)
    - Check wireless interface status and set channel: `iwconfig`
    - Check attached Wifi clients: `iw dev wlan1 station dump or wlanconfig ath0 list sta`\
    - Check what AP is used from a client: `iw dev wlan0 link`
    - Check on AP stats from client bridge: `iw dev wlan0 station dump`
    - Have an AP tell a client to dissassociate: `iwpriv ath0 kickmac 00:02:6f:01:02:03` (use mac address of client)
- Copy SSH key from localhost to server: `cat ~/.ssh/id_rsa.pub | ssh user@hostname 'cat >> .ssh/authorized_keys'` (assumes that the key pair has already been generated)
- Mount a remote directory with sshfs
    - `sshfs user@host: mountpoint`
    - To install: `#apt-get install fuse-utils sshfs; modprobe fuse`
- list bridges: `brctl show`

### WiFi
-   Connect to a wireless network, via the command line, from
    [ghacks.net](http://www.ghacks.net/2009/04/14/connect-to-a-wireless-network-via-command-line/):
    -   (if necessary) `ifconfig wlan0 up`
    -   `iwconfig wlan0 essid NETWORK_ID key WIRELESS_KEY`, if no
        password, then skip the `key WIRELESS_KEY` part.

### Package Management
-   Install a package: `(sudo) apt-get install XXX`
-   Search for a package:
-   -   `apt-cache search XXX`
    -   `apt-cache search "*XXX*"`, for a package name with wildcards
    -   `aptitude show XXX`
    -   `aptitude show ~nXXX`, for the equivalent of apt-get with
        "**XXX**"
-   Search the the install log: `grep install /var/log/dpkg.log`
-   List all installed packages: `dpkg -l`
-   List files provided by package: `dpkg -L package`
-   More at [Debian Package Management Cheat
    Sheet](http://www.cyberciti.biz/tips/linux-debian-package-management-cheat-sheet.html)
-   More on [apt
    logs](http://linuxcommando.blogspot.com/2008/08/how-to-show-apt-log-history.html)
-   Save/Restore the list of installed packages:
-   -   `dpkg --get-selections > packages.txt`
    -   `sudo dpkg --clear-selections`
    -   `sudo dpkg --set-selections < packages.txt`
    -   See also:
        http://askubuntu.com/questions/17823/how-to-list-all-installed-packages
    -   See also:
        http://wiki.mediatemple.net/w/%28ve%29:Backup\_and\_Restore\_Installed\_Packages

### Subversion
- Commit (checkin changes): `svn ci -m "commit message"`
- Update (make sure local/working copy has the latest): `svn up`
- Revert (loose changes in local/working copy): `svn revert`;
- Rollback a directory to a previous version (ie from rev 20 back to rev 17): `svn up; svn merge -r 20:17 .; svn ci -m "rollback commit message"`
    - For more see [stackoverflow](http://stackoverflow.com/questions/2324999/revert-a-svn-folder-to-a-previous-revision)
- List conflicted files: `svn status | grep -P '^(?=.{0,6}C)'`
- To revert a file to an old version in your working copy: `svn up -r 147 myfile.py`
- More at [Subversion Tips](http://192.168.221.8/phpwiki/index.php/Subversion%20Tips)

### Git
- Commit checkin **all** changes (not just staging area): `git commit -a`
- Add additional changes to last commit:
    ```
    git checkout 7991072
    make changes
    git commit --amend
    ```

### Kernel Modules
-   `lsmod` : list kernel modules that are loaded
-   `modprobe xxx`: attempt to load kernel module xxx

### Bash Scripting
- To increment a counter: `COUNTER=$(($COUNTER + 1))` or `COUNTER=$[COUNTER + 1]`.
    - Note: the second version does not work under busybox (ash).
- xtrace: Echo commands after processing (substitutions, etc): `set -x` Note: xtrace starts each line it prints with one `+` for
  each level of expansion. From "[Learning the bash shell](http://shop.oreilly.com/product/9780596009656.do)"
- To apply an environment variable change, just to a single command: `LC_COLLATE=C ls -A --group-directories-first`,
  which groups directories, .xxx files, and \_xxxx files.
- To print then environment variables `printenv` or `env`
- Add a message to the syslog: `logger message`
- [Bash pitfalls](http://mywiki.wooledge.org/BashPitfalls)

### Performance Analysis Tools: (from [thi slidedeck](http://www.slideshare.net/brendangregg/linux-performance-analysis-and-tools)

-   Basic: uptime, top, htop, mtop, iostat, vmstat, free, nicstat, dstat
-   Intermediate: sar, netastat, pidstat, strace, tcpdump, blktrace,
    iotop, slabtop, sysctl, /proc
-   Advanced: perf, dtrace

### Restart a locked linux machine
- `Ctrl + Alt + PrtSc (SysRq) + reisub`
- Just to make it clear. You need to press and hold Ctrl, Alt
  and PrtSc(SysRq) buttons, and while holding them, you need to press r, e, i, s, u, b
- From [Jovica Ilic](http://www.jovicailic.org/2013/05/linux-gets-frozen-what-do-you-do/)

I've also archived the [wiki page](http://russandbecky.org/FCI_wiki_command_line_magic.html) I
maintain at work, with a lot of the same stuff.

### Macports
- Update source tree (rsync): `sudo port selfupdate`
- List outdated sources: `port outdated`
- Apply the outdated sources: `sudo port upgrade outdated`
- More [common tasks](https://guide.macports.org/chunked/using.common-tasks.html)

### Ipython/Jupyter
- Convert a IPython Notebook into a Python file: `ipython nbconvert --to=python [YOUR_NOTEBOOK].ipynb`
- Start jupyter (python) notebook: `jupyter [YOUR_NOTEBOOK].ipynb`
