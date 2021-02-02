---
layout: default
title: How to Setup Private Pub Server
parent: Recipes
nav_order: 7
---

# How to Setup Private Pub Server

When using _pub publish_ a dart package, by default it is published onto [pub.dev site](https://pub.dev), which is viewed publicly. In order to protect BMW intellectual property, it is required to host a private pub server for dart package management. The private pub server is based on Dart package [unpub](https://pub.dev/packages/unpub).

## Create a Linux Virtual Machine to Host the Private Pub Server

- First create a resource group under subscription _BTC_Tools_, e.g. _pubserverrg_ at location _centralus_.
- Execute [the ARM template](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-secured-vm-from-template) to create a Linux virtual machine.
- In order to ssh into the VM _pubdev-vm_, you will need to get the adminstrator username and the corresponding password from vault. The information is stored here:
  ```bash
  vault kv get secret/mobile20/vm_40_122_47_29
  ```

## Limit Access to the Newly Created VM

In order to limit the access to the VM, go to [the azure developer portal](https://portal.azure.com), first to associate the VM's network security group with the VM's network interface, then add Inbound security rules.

## Install Needed Software Packages onto the VM

Following software packages are required in order for _unpub_ to run:

- mongodb
- dart sdk
- flutter

So follow the steps below to install them:

- ssh into the VM from the laptop connected to BMW intranet
- install mongodb
  ```bash
  sudo apt-get -y update
  sudo apt-get -y install mongodb
  ```
- install dart
  ```bash
  sudo apt-get install apt-transport-https
  sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
  sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
  sudo apt-get update
  sudo apt-get install dart
  ```
- install flutter
  ```bash
  curl -O https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.9.1+hotfix.5-stable.tar.xz
  mkdir development
  cd development
  tar xf ~/flutter_linux_v1.9.1+hotfix.5-stable.tar.xz
  rm -rf ~/flutter_linux_v1.9.1+hotfix.5-stable.tar.xz
  ```
- update .profile

  add the line below to the bottom of _~/.profile_

  ```
  export PATH="/usr/lib/dart/bin:$HOME/.pub-cache/bin:$HOME/development/flutter/bin:$PATH"
  ```

- install unpub in this way if you are pulling from pub
  ```bash
  pub global activate unpub
  ```
  - if you forked unpub, then zip the unpub source and scp to the VM using the username and password from Vault using the following commands:
  ```bash 
  cd unpub/unpub
  scp ./unpub.zip mobile20@40.122.47.29:/home/mobile20
  ```
- On the VM, create the development directory and unzip the source in that directory
  ```bash
  cd development/unpub
  pub get
  pub global activate --source path .

- create scripts directory
  ```bash
  cd ~ (should be /home/mobile20)
  mkdir scripts
  ```

- add init_pub_server.sh script to scripts
  ```bash
  #!/bin/bash -e
  dart /home/mobile20/development/unpub/bin/unpub.dart --port 443 --database mongodb://localhost:27017/dart_pub --pem_path /home/mobile20/unpub_certs
  ```
  * Be sure to chmod +x the script

- create unpub_certs directory
  ```bash
  cd ~
  mkdir unpub_certs
  ```

- create certs for the VM -- Run the directions found at certbot based on software (apache) and OS (ubuntu 18.04 LTS) found at https://certbot.eff.org/

- Run the following command
  ```bash 
  cat fullchain1.pem privkey1.pem > cert.pem
  ```
- Copy all .pem files into unpub_certs

- On the VM, the /home/mobile20 directory should look like this:
  ```bash
  development  scripts  unpub_certs
  ```
## Make unpub Run on Startup

- Create a system daemon service file
  ```bash
  sudo nano /etc/systemd/system/unpub.service
  ```
- Paste in the content below. Press ctrl + x then y to save and exit

  ```
  Description=A self-hosted private Dart Pub server for Enterprise.

  Wants=network.target
  After=syslog.target network-online.target

  [Service]
  Type=simple
  ExecStart=/home/mobile20/scripts/init_pub_server.sh
  Restart=on-failure
  RestartSec=10
  KillMode=process

  [Install]
  WantedBy=multi-user.target
  ```

- Reload services
  ```bash
  sudo systemctl daemon-reload
  ```
- Enable the service
  ```bash
  sudo systemctl enable unpub
  ```
- Start the service
  ```bash
  sudo systemctl start unpub
  ```
- Check the status of the service
  ```bash
  systemctl status unpub
  ```
- Load [unpub server](http://pubdev.centralus.cloudapp.azure.com:4000/) to verify it is running

# How to Publish Dart Package to the Private Pub Server

- First we need to add each user that is allowed to publish the package as a uploader
  ```bash
  flutter packages pub uploader --server 'http://pubdev.centralus.cloudapp.azure.com:4000' --package <package_name> add <user_google_account_email>
  ```
- Publish the current package
  ```bash
  flutter packages pub publish --server 'http://pubdev.centralus.cloudapp.azure.com:4000/'
  ```

# How to Use Packages that are hosted at the Private Pub Server

The following format should be used in pubspec.yaml dependencies section:

```
  firebase_push_notification:
    hosted:
      name: firebase_push_notification
      url: http://pubdev.centralus.cloudapp.azure.com:4000
    version: ^0.0.1
```
