# test-repo

###### practical test #######

1. Create a virtual machine (using VirtualBox) with Rocky or Almalinux distribution with the following specs:
   - 2vCPU's
   - 2GB RAM
   - 20 GB disk (thin provisioning)

   Disk layout:
   - boot 500MB
   - / 2GB
   - lvm
   - /usr 4GB
   - /tmp 2GB
   - /var 5GB
   - /home 2GB
   - /opt 1GB

   **What to do:**
   - Download Almalinux distribution ISO.
   - Install VirtualBox on your PC, then execute this PS1 script to create VirtualBox (adjust paths to your ISO or VirtualBox):
     ```
     .\create_almalinux_vm.ps1
     ```
   - Copy `my.ks` to whatever location and then run the following command:
     ```
     python -m http.server 8000
     ```
     This will start a web server on port 8000 and it will be able to serve `my.ks` to VirtualBox.

   - When VirtualBox is booting off installation ISO, press TAB and add to the
     ```
     inst.ks=http://<server-ip>:8000/my.ks
     ```
     Note: `server-ip` is the IP of where Python web server is running off, in my case, it was my PC IP address.

2. Create a git repository for an automation project and deploy using ansible the following on VM created at 1):
   - Create the following users:
     - `bmadmin` with UID/GID: 1100; shell `/bin/bash`; password: `tEsts3cr3t!` (sudo access)
     - `batch` user with UID/GID: 1108; shell `/bin/bash`
     - `dockerapp` user with UID/GID: 10000; shell `/bin/bash`
   - Install Docker.
   - Deploy/configure HAProxy and 2 Apache containers.
     - flow: web client -> haproxy (rr) -> apache containers (display html page)
     - haproxy should balance requests using round-robin across apache containers and display a simple html page/message that will show the following dynamic message: "$HOSTNAME or $CONTAINER_ID: ansible is awesome !"
     - Notes:
       - html page apache and haproxy configuration files should reside on docker host (VM from point 1.), so these can be redeployed/modified without rebuilding containers
       - hostname or container_id should be dynamic displayed, you can use javascript or php to achieve that (or other method)


   For this task login to VM and execute the following command:
    ```
    ansible-playbook -i inventory/hosts playbooks/site.yml --ask-vault-pass
    ```
    Note: Password for the vault is: `krzysiek`


3. Export/compress the virtual machine and put this somewhere we can download and review. Ansible repo project can be uploaded to GitHub or other platforms or sent as a TGZ file for review (or leave it on the exported VM).

   - github url:
     https://github.com/chrysek70/test-repo
   - downlad of VirtualBox VM:
     http://www.wianecki.com/AlmaLinuxVM.zip

######## end ########

NOTE: linux passworsd is set to krzysiek, linux user is cw and its password is also set to krzysiek

results:
when running curl against haproxy which is set to round-robin we gett the following results
```
[cw@localhost ~]$ curl http://localhost
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apache Container</title>
</head>
<body>
    <h1>Host: 8205b27aa738</h1>
    <p>Ansible is awesome!</p>
</body>
</html>

[cw@localhost ~]$ curl http://localhost
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apache Container</title>
</head>
<body>
    <h1>Host: c09ee86153cd</h1>
    <p>Ansible is awesome!</p>
</body>
</html>

[cw@localhost ~]$
```

when connecting to individual servers we gett he following

```
[cw@localhost ~]$ curl http://127.0.0.1:8081
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apache Container</title>
</head>
<body>
    <h1>Host: 8205b27aa738</h1>
    <p>Ansible is awesome!</p>
</body>
</html>

[cw@localhost ~]$
```
and
```
[cw@localhost ~]$ curl http://127.0.0.1:8082
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apache Container</title>
</head>
<body>
    <h1>Host: c09ee86153cd</h1>
    <p>Ansible is awesome!</p>
</body>
</html>

[cw@localhost ~]$
```

index pages that are used by docker containers are in the following locations for each container, they can be modified withour rebuilding docker containers:
```
[cw@localhost ~]$ ls -la /var/www/apache1/
total 8
drwxr-xr-x. 2 root root  41 May  4 14:28 .
drwxr-xr-x. 4 root root  36 May  4 13:30 ..
-rw-r--r--. 1 root root 270 May  4 13:30 index.html
-rw-r--r--. 1 root root 289 May  4 14:28 index.php
[cw@localhost ~]$ ls -la /var/www/apache2/
total 8
drwxr-xr-x. 2 root root  41 May  4 14:28 .
drwxr-xr-x. 4 root root  36 May  4 13:30 ..
-rw-r--r--. 1 root root 270 May  4 13:30 index.html
-rw-r--r--. 1 root root 289 May  4 14:28 index.php
[cw@localhost ~]$
```

Final thoughts:
- I rarely used virtual box, so I did run into quite a few PC crashes when I changed from NAT ro Bridge interface, it took me a bit to figure this out why it was crashing my PC, so I did set port forwarding of my SSH port 22 to 2222 so I could ssh to that VM. Then I used curl and lynx to test my pages.
- This project introduced me to AlmaLinux, a distribution I hadn’t worked with before. Opting for it over RockyLinux was a spontaneous decision, driven by the opportunity to explore something new. While they share similarities, delving into AlmaLinux offered a fresh learning curve.
- I also did decide to automate as much as I could, so I was able to figure out how to create vm in virtual box using powershell commands, this gave me ability to set exact specs for the vm as described in the taks, I also did setup kickstart file which also gave me ability top set my linux partitions and everything else to exact specifiactions that were given in your test. Unfortunatelly I did not have pxeboot so during iso boot I had to append inst.ks=http://<server-ip>:8000/my.ks to end of command line, this coul dbe avoided I think with pxeboot setup.
- I also did run into issues with SELinux was enforcing so I had to disable it:
  - sudo setenforce 0
- 
