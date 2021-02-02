---
layout: default
title: How to create a Buildnode and Mac Vagrant image
parent: Recipes
nav_order: 18
---

# How to create a Buildnode and Mac Vagrant image

## Steps for setting up a Mac Buildnode (physical hardware / host system)

These steps are for a buildnode itself, i.e. the host system / base operation system
that will run on the real hardware (e.g. Mac mini) and that will be called by the
pipeline.
So this section is talking about the requirements and steps to do for the host
operation system.

We also have a chapter that details how to create a vagrant image that will run
on the host system as a VM and do the real compilation. If you are looking for this then
just head over to **Steps to create a macOS vagrant image**

### Install vanilla MacOS Catalina

Do a clean installation of MacOS catalina

### Change shell to bash

In Mac OS catalina the default shell was changed from bash to zsh. In order to ensure
that all Shell-Scripts work as expected, the default shell should be changed back to
bash:
I do not know if this hurts but to be safe change it back to bash:

```sh
chsh -s /bin/bash
```

### Install Homebrew

Install the package manager Homebrew. For more details about homebrew see: [https://brew.sh/](https://brew.sh/)

- Install Homebrew

  ```sh
  /bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  ```

- Disable HomeBrew Analytics:

  ```sh
  printf "\n\nexport HOMEBREW_NO_ANALYTICS=1" >> ~/.bash_profile
  ```

### Install Docker

Download and Install Docker from [docker.com](https://www.docker.com/get-started)

### Install Vagrant

Install Vagrant 2.2.7 from [vagrantup.com](https://www.vagrantup.com/)

### Additional Install Steps

Check out the [documentation in the MacFarm-repo](https://code.connected.bmw/runtime/macfarm-ansible#pre-existing-requirements-for-new-macs)
and ensure that all requirements are met.

### TimeMachine Backup

This step is optional, but it might be a good idea to create an encrypted TimeMachine backup so that
when you need to add more build slaves you do not have to go over all these steps again.

## Steps to create a macOS vagrant image (virtual machine running on host)

These steps are for the virtual machine that will run on the buildnode, i.e. the vagrant image that will run as a VM on the MacMini.

### Prerequisite

- Install Virtualbox 6.1 from [virtualbox.org](https://www.virtualbox.org/wiki/Downloads)
- Install Vagrant 2.2.7 from [vagrantup.com](https://www.vagrantup.com/)
- Make sure you have **lots of free DiskSpace**, you need around 3 times the space the vagrant image itself has, so >= 170 GB would be good.

### Get access to the Vagrant-image-Artifactory instance

The easiest way to get access it to create a PR to this repo:
[code.connected.bmw/runtime/onprem-artifactory](https://code.connected.bmw/runtime/onprem-artifactory)
Here is an example PR of what you need to change: [PR-55](https://code.connected.bmw/runtime/onprem-artifactory/pull/55/files)

Once that PR is approved and merge you should soonish get access to the correct folders and images at
[luusartf01.w10:8081/artifactory](http://luusartf01.w10:8081/artifactory)

### Fetch the vagrant base image from Artifactory

Download the correct base vagrant image. Which one you chose depends on what your goal is.
For example, if you want to upgrade the image used to build the M2 app,
then you should download the latest eadrax image (at the time of writing this guide: eadrax-v0.2.3.box).

If you need to create a new clean image then you can take the mac-vagrant-image (This is a base image with only macOS Catalina 10.15.3 installed)

- Login to Artifactory and get [eadrax-v0.2.3.box](http://luusartf01.w10:8081/artifactory/webapp/#/artifacts/browse/tree/General/eadrax/eadrax-v0.2.3.box)
- For the following steps it is assumed that the file is stored in the folder ~/Downloads

#### Add the vagrant box

```sh
vagrant box add --name my-eadrax-box ~/Downloads/eadrax-v0.2.3.box
```

After the command was executed, one should see something like this in the terminal:

```sh
==> box: Successfully added box 'my-eadrax-box' (v0) for 'virtualbox'
```

#### Start the vagrant box

The following commands will create a new folder, change into that folder, init the image there
and then start it. The last command will take a while, so be patient.

```sh
mkdir -p ~/dev/vagrant/eadrax
cd ~/dev/vagrant/eadrax
vagrant init my-eadrax-box
vagrant up
```

#### First steps in the image

##### Connect via vagrant ssh

With the following commands one can ssh into the box, play around a bit and at the end exit
the box again and then halt it:

```sh
vagrant ssh
whoami
cat /etc/passwd
exit
vagrant halt // This command will stop the vagrant image from running
```

##### Connect via VirtualBox

Open VirtualBox on your Mac. You should now see the vagrant image in the list of VMs and it should be running.
Double-click on it to open the image. Now you have access to the image via a UI and can click around.
(If you are asked for a PW then it is "vagrant")

### Proxy issues

If your Mac is connected to the BMW network then you might have issues reaching public internet from inside the vagrant image.
You have two options:

- Temporarily setup proxy inside the vagrant image. (Do not forget to remove these settings later before publishing the image!)
- Connect your Mac to a network outside of the BMW Network. When in HomeOffice this means to disconnecting from VPN. If you are in the office then you can connected to a public WiFi or connect via hotspot on your phone.

### Make the updates you need to the Vagrant image

For example, if you need to update the Xcode version then from inside the vagrant image download and install the needed version of Xcode.

- Download Xcode 12.1 (or the needed Xcode version)
- Unpack Xcode and rename it from "Xcode" to "Xcode_12.1" (so that multiple version could be installed)
- Call `sudo xcode-select -switch /Path/to/new/Xcode.app` to select the Xcode version that should be used
- Call `xcode-select -p` to check that the correct version has been set

It is also possible to download files to your local Mac and then copy them over to the vagrant image using scp.
For example by calling this:

```sh
scp -P 2222 /Path/to/local/file vagrant@127.0.0.1:/Path/to/location/in/vagrant/image
```

### Further steps

Now the image has to be further customized, i.e. flutter, fastlane, etc. have to get installed
and other software that is required in order to do the build.

### Document your changes

On the Desktop of the macOS vagrant image there should be a file called `CHANGELOG.md`.
If there is none, then please create one.

Then update this `CHANGELOG.md` to contain information about the changes you made.
For example if you updated Xcode from 11.6 to 12.1, or if you installed some new tool.

### Create new Vagrant Image

Once you are done with all your configs of the Vagrant image then you need to create
a new image that will contain all these changes.

To create a new image you use the package command. Please be aware that this command
will really take a while (~45 Minutes).

```sh
vagrant package --output eadrax-v0.2.4.box
```

## Upload new Vagrant image to Artifactory

Now you have a new Vagrant image and you want to share this with the world. Then you
need to upload it to our Artifactory-instance in Chicago.

> Note: This Artifactory instance is being shutdown soonish since we are closing down
> the Chicago office. We will need to update this guide later on with information about
> how this will look like in the future.

The easiest way to upload the new image is via the CLI using curl. This requires a few steps.

### Get API Key

You need to have an API-key assigned to your user-profile at
[luusartf01.w10:8081/artifactory](http://luusartf01.w10:8081/artifactory)
To get this go to:
[luusartf01.w10:8081/artifactory](http://luusartf01.w10:8081/artifactory)
and then click on your user name in the upper right corner
Then under "Authentication Settings" make sure that you have an API key set. If not press the button to get one.
![API Key]({{site.baseurl}}/assets/images/recipes/how_to_create_a_buildnode_and_mac_vagrant_image/api-key.png)

### Upload using curl

Now you have the correct credential to use curl and upload the image.
The upload is done with this curl command. In this example we are uploading a new eadrax vagrant
image used for Mobile2.

Please be aware that this step will take a while since it is uploading around 50GB via the BMW network.
And you will not get any progress feedback in the terminal. For me this took 20 hours last time I uploaded.

One way to check how much data that has been transferred already is by using the `Activity Monitor` app in macOS.
Start the `Activity Monitor` and then select the `Network` and locate `curl` under `Process Name`. Then you will be able to see how much data curl has completed uploading under the `Sent Bytes` section.

```sh
curl -v -u {yourUsername}:{yourApiKey} -T /Local/Path/To/eadrax-v0.2.4.box http://luusartf01.w10:8081/artifactory/eadrax/eadrax-v0.2.4.box;box_name=eadrax;box_provider=virtualbox;box_version=0.2.4
```

For more details, see [here](https://code.connected.bmw/runtime/onprem-artifactory/blob/master/uploadscript/upload-vagrant-artifactory.sh#L67)

After the upload has completed you will need to configure some properties on the image inside Artifactory.
This is needed so that our MacFarm-ansible script can locate the correct image file.
Open Artifactory in a browser and go to your newly uploaded image. For example [eadrax-v0.2.3.box](http://luusartf01.w10:8081/artifactory/webapp/#/artifacts/browse/tree/Properties/eadrax/eadrax-v0.2.3.box)
Now click on the `Properties` tab. In there you need to add these properties:

| Name         | Value                                       |
| ------------ | ------------------------------------------- |
| box_name     | eadrax                                      |
| box_provider | virtualbox                                  |
| box_version  | 0.2.4 // Here your new version number comes |

![Set Artifactory properties]({{site.baseurl}}/assets/images/recipes/how_to_create_a_buildnode_and_mac_vagrant_image/set-artifactory- properties.png)

## Update Jenkins Mac nodes to use new the Vagrant image

To expose the new Vagrant image to the Jenkins mac nodes you need to update the _nodes.ini_
file in the [MacFarm-Ansible repo](https://code.connected.bmw/runtime/macfarm-ansible).

Here is an exmaple PR of what you need to change:
[PR-169](https://code.connected.bmw/runtime/macfarm-ansible/pull/169)

In this PR we are updating the first Eadrax group to use the Eadrax-Vagrant-image with version
number 0.2.2 and we named that group "eadrax_xcode11_6_flutter_1_20_4"

Once that PR gets merged then you should be able to run your iOS-Jenkins jobs on a node with
that image by updating your jenkins file so that it references that new
jenkins-label: "eadrax_xcode11_6_flutter_1_20_4"
