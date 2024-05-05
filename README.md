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

my playbook run
```
[cw@localhost ansible-automation]$ ansible-playbook -i inventory/hosts playbooks/site.yml --ask-vault-pass
Vault password:

PLAY [webserver] *******************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [localhost]

TASK [../roles/user_setup : Create Groups] *****************************************************************************
ok: [localhost] => (item={'name': 'bmgroup', 'gid': '1100'})
ok: [localhost] => (item={'name': 'batchgroup', 'gid': '1108'})
ok: [localhost] => (item={'name': 'dockerappgroup', 'gid': '10000'})

TASK [../roles/user_setup : Create Users] ******************************************************************************
changed: [localhost] => (item={'name': 'bmadmin', 'uid': '1100', 'group': 'bmgroup', 'shell': '/bin/bash', 'password': '$6$rounds=656000$gteyS6FsNFAFbc2z$mSRaogikiKag1GJhtx8quhsifXPk4gh5Os1x7BVMAUjmmBip0.Vt2qKYRTr5vpEjZlbpCnl.HMX94izLwx1oj0'})
ok: [localhost] => (item={'name': 'batch', 'uid': '1108', 'group': 'batchgroup', 'shell': '/bin/bash'})
ok: [localhost] => (item={'name': 'dockerapp', 'uid': '10000', 'group': 'dockerappgroup', 'shell': '/bin/bash'})

TASK [../roles/user_setup : Grant sudo access to bmadmin] **************************************************************
ok: [localhost]

TASK [../roles/docker_setup : Install Docker dependencies] *************************************************************
ok: [localhost]

TASK [../roles/docker_setup : Set up Docker repository] ****************************************************************
ok: [localhost]

TASK [../roles/docker_setup : Install Docker] **************************************************************************
ok: [localhost]

TASK [../roles/docker_setup : Start and enable Docker service] *********************************************************
ok: [localhost]

TASK [../roles/haproxy_setup : Install HAProxy] ************************************************************************
ok: [localhost]

TASK [../roles/haproxy_setup : Deploy HAProxy configuration] ***********************************************************
ok: [localhost]

TASK [../roles/haproxy_setup : Enable and start HAProxy service] *******************************************************
ok: [localhost]

TASK [../roles/apache_setup : Deploy Apache containers] ****************************************************************
ok: [localhost] => (item=1)
ok: [localhost] => (item=2)

TASK [../roles/apache_setup : Ensure directory exists on host] *********************************************************
ok: [localhost] => (item=1)
ok: [localhost] => (item=2)

TASK [../roles/apache_setup : Copy custom PHP page to host directories] ************************************************
ok: [localhost] => (item=1)
ok: [localhost] => (item=2)

PLAY RECAP *************************************************************************************************************
localhost                  : ok=14   changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[cw@localhost ansible-automation]$
```


when running curl against haproxy which is set to round-robin we gett the following results
```
[cw@localhost ansible-automation]$ curl http://127.0.0.1
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

[cw@localhost ansible-automation]$ curl http://127.0.0.1
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

[cw@localhost ansible-automation]$ curl http://127.0.0.1
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
-rw-r--r--. 1 root root 289 May  4 14:28 index.php
[cw@localhost ~]$ ls -la /var/www/apache2/
total 8
drwxr-xr-x. 2 root root  41 May  4 14:28 .
drwxr-xr-x. 4 root root  36 May  4 13:30 ..
-rw-r--r--. 1 root root 289 May  4 14:28 index.php
[cw@localhost ~]$
```

Final thoughts:
-  Since I rarely use virtual box I had a couple PC crashes when I changed from NAT to Bridge interface. I figured out that by setting port forwarding of my SSH port from 22 to 2222 I could connect to that VM. Then I used curl and lynx to test my pages.
- This project introduced me to AlmaLinux, a distribution I had not worked with before. Opting for it over RockyLinux was a spontaneous decision, driven by the opportunity to explore something new. While they share similarities, delving into AlmaLinux offered a fresh learning experience.
- I automated as much as possible and was able to figure out how to create vm in virtual box using powershell commands. This gave me the ability to set exact specs for the vm as described in the tasks. I created kickstart file which allowed me to set my linux partitions and packages to exact specifications given in the test. I do not have pxeboot so during iso boot I had to append inst.ks=http://<server-ip>:8000/my.ks to end of command line. I think this could be avoided with pxeboot setup.
- Lastly SELinux was enforcing which created some issues with port blocking so I had to disable it:
    ```
    sudo setenforce 0
    ```
