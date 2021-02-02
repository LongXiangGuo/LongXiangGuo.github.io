---
layout: default
title: How to Setup a MacOS Device Farm
parent: Recipes
nav_order: 1
---

[Java SE 8 Oracle]: https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
[Installing Jenkins MacOS]: https://www.macminivault.com/installing-jenkins-on-macos/
[Jenkins]: https://jenkins.io/download/
[Shepherd]: mailto:richard.shepherd@bmwna.com
[Pipeline Path Issue]: https://issues.jenkins-ci.org/browse/JENKINS-41492

# How to Set Up a MacOS Device Farm with Jenkins

## Motivation

We are able to run performance tests on emulated devices in the pipeline. However, the performance capabilities of an emulated device are not analogous to a real phone. That's where the BMW Device Farm comes into play.

## Assumptions

1. You are using MacOS Mojave (10.14)
2. This is a clean install

## Setting up a Flutter Device Farm (iOS & Android)

### Step 1 - Normal Setup

First, make sure XCode and Homebrew are installed.

For XCode, you can download it from [Apple's website](https://developer.apple.com/download/more/). This will take a very long time (download size is 6 GB).

If you are missing Homebrew, run this command in your terminal (this will also take some time):

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

For the remaining software and setting up your bash or zsh script, please follow the [Getting Started Guide]({{site.baseurl}}/docs/onboarding/getting_started).

**Note: You'll want to install Flutter somewhere common (not under `/Users/{your-user}`/**, since Jenkins jobs are executed by a dedicated Jenkins user. Attempting to use software from another user's directory will not work out well...

Here's some suggestions for where to install Flutter:

- `/Applications/`
- `/Users/Shared/`

### Step 2 - Installing Jenkins

Once you're done with **Step 1**, please plug in a device and run `flutter devices` to ensure that Flutter can discover a phone over USB.

Once that works, please continue:

1. Ensure Java SE 8 is installed on the machine
   - We can't use Java 11, just yet
   - Type this into the terminal, the result should be "1.8.0_{patch-version}>": `java -version`
   - If not, here's your options:
     1. You can download using Brew: `brew cask install java8`
     2. Otherwise, download it directly from [Oracle's website][Java SE 8 Oracle]
        - You may need to create a free Oracle account to download it
2. Download the latest stable version of Jenkins
   - You can download it directly from the [Jenkins website][Jenkins]
   - Otherwise, you can download using Brew: `brew install jenkins-lts`
3. Open http://localhost:8080 in your browser, you'll be directed to the local Jenkins server and be prompted to "Unlock Jenkins"
4. Type this in your terminal, and past the result in the "Administrator password" field:
   - `cat /Users/administrator/.jenkins/secrets/initialAdminPassword`
5. Create a Jenkins user
   - Recommended username / password is **admin / admin**

Alternatively, this [online guide][Installing Jenkins MacOS] seemed like it might be worth attempting. They also setup the IP address so jobs can be triggered remotely.

### Step 3 - Creating a Pipeline Job

1. Logout, and log back in as the new user, **Jenkins**
2. Open http://localhost:8080 in your browser, and log into the local Jenkins server
3. Use the same `.bash_profile`/`.zshrc` from **Step 1**, and use the same values for the Jenkins shell (for zsh, replace the following `.bash_profile`s with `.zshrc`):

   ```bash
   echo 'creates the file'
   touch ~/.bash_profile
   echo 'opens the file'
   vi ~/.bash_profile

   ## Paste the contents in this file
   ```

   Then add this line (this is so "Jenkins" can run Brew):

   ```bash
   export PATH=`/usr/local/bin:$PATH`
   ```

   Then execute this to reload your CLI environment variables:

   ```bash
   source ~/.bash_profile
   ```

4. Update the global environment for Jenkins builds
   - In your terminal, type `echo $PATH` and copy the result (only keep the stuff we added to the **$PATH** in our .bash_profile / .zshrc for Brew, Flutter, and Dart)
     - It should look something like `/usr/local/bin:/Applications/flutter/bin:/Applications/flutter/bin/cache/dart-sdk/bin`
   - Time to configure our settings! Go back to the home screen
     - Select **Manage Jenkins** on the left-hand panel
     - Select **Configure System**
     - Under **Global properties**, check **Environment variables** and select the **Add** button
     - **You need to name it "PATH+EXTRA"**, please see the [Jenkins issue][Pipeline Path Issue] for more info
     - For the value, paste the path data for Brew, Flutter and Dart
     - Append `:$PATH` to the end, it should look something like this:

       ```bash
       /usr/local/bin:/Applications/flutter/bin:/Applications/flutter/bin/cache/dart-sdk/bin:$PATH
       ```

5. Create a Pipeline Project
   - After logging into the Jenkins server, select **New item**
   - Select **Pipeline Project**
   - Under **Pipeline**, add the following under **Pipeline script**:

     ```groovy
     pipeline {
         agent any
         stages {
             stage('Testing Device Connection with Flutter') {
                 steps {
                     sh('flutter devices')
                 }
             }
         }
     }
     ```

   - After saving, select **Build Now** in the left-hand panel
   - If you have any phones plugged in via USB, this build should display them

6. (**Optional**) Delete the .bash_profile / .zshrc if you plan on running non-pipeline builds with this Jenkins box
