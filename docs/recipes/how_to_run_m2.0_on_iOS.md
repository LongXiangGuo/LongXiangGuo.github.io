---
layout: default
title: How to Run Mobile Connected 2.0 on iOS
parent: Recipes
nav_order: 20
---

# How to Run Mobile Connected 2.0 on iOS

If you want to build Mobile Connected 2.0 project for iOS, and run it on a Simulator, this is the guide for you!

## Getting the project ready

```bash
# wipes pub dependencies
make clean
# wipes derived data / resets simulator
make wipe_ios_cache
make reset_ios_simulator

# wipes lock files, which will help get past semantic versioning issues
rm pubspec.lock
rm ios/Podfile.lock
# updates any globally-cached pub dependencies to support latest Flutter / Dart
pub cache repair
# wipes cocoa pods dependencies / cleans Xcode build environment
rm -Rf ios/Pods
rm -Rf ios/.symlinks
rm -Rf ios/Flutter/Flutter.framework
rm -Rf ios/Flutter/Flutter.podspec
```
### Vault Fomula

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/vault
```
### Required for HERE Maps

```bash
brew install git-lfs
git lfs install
```

### Login & Load Keys from Vault    

This is required for HERE Maps to work properly, 
if you want to run the app without maps skip this step.

```bash
curl https://releases.hashicorp.com/vault/1.4.0/vault_1.4.0_darwin_amd64.zip > vault_1.4.0_darwin_amd64.zip
tar -xvf vault_1.4.0_darwin_amd64.zip
```

```bash
sudo mv ./vault /usr/local/bin/
```

```bash
echo "export VAULT_ADDR=https://secrets.connected.bmw/" >> ~/.bash_profile
source ~/.bash_profile
```

```bash
brew install consul-template
vault login -method=oidc -path=rtac role=mobile20
make load_keys_vault
```

#### More Details About Vault Install Process in the links below

[Runtime Docs](https://pages.code.connected.bmw/runtime/docs/developer-guides/vault/)

[Connected 2.0 Docs](https://pages.code.connected.bmw/mobile20/mobile-docs/docs/recipes/how_to_setup_vault/)


## Run the app

```bash
dart scripts/cli/cli.dart preProcessPubspec universalrow
flutter pub get # don't need a full install just yet
cd ios; pod update # in ios folder
cd ../; make install_dependencies # project root folder
cd ios; pod install # in ios folder
```

