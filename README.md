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
     inst.ks=http://<server-ip>:8000/ks.cfg
     ```
     Note: `server-ip` is the IP of where Python web server is running off, in my case, it was my PC IP address.

2. Create a git repository for an automation project and deploy using Ansible the following on VM created at 1):
   - Create the following users:
     - `bmadmin` with UID/GID: 1100; shell `/bin/bash`; password: `tEsts3cr3t!` (sudo access)
     - `batch` user with UID/GID: 1108; shell `/bin/bash`
     - `dockerapp` user with UID/GID: 10000; shell `/bin/bash`
   - Install Docker.
   - Deploy/configure HAProxy and 2 Apache containers.

   Flow: web client -> HAProxy (rr) -> Apache containers (display HTML page).

   HAProxy should balance requests using round-robin across Apache containers and display a simple HTML page/message that will show the following dynamic message: `"$HOSTNAME or $CONTAINER_ID: ansible is awesome!"`

   **Notes:**
   - HTML page Apache and HAProxy configuration files should reside on the Docker host (VM from point 1.), so these can be redeployed/modified without rebuilding containers.
   - Hostname or container_id should be dynamically displayed. You can use JavaScript or PHP to achieve that (or other methods).

   For this task login to VM and execute the following command:
    ```
    ansible-playbook -i inventory/hosts playbooks/site.yml --ask-vault-pass
    ```
    
Note: Password for the vault is: `krzysiek`

3. Export/compress the virtual machine and put this somewhere we can download and review. Ansible repo project can be uploaded to GitHub or other platforms or sent as a TGZ file for review (or leave it on the exported VM).

######## end ########

    