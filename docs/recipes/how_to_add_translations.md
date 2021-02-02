---
layout: default
title: How to add translations
parent: Recipes
nav_order: 11
---

# Translations

## First Time - Setup

You will need to have npm installed on your PC and also followed the main project-onboarding steps.

### arb-converter

Install the arb-converter by running:

`npm install arb-converter-cli`

### npm registry setup

Make sure your npm registry is set correctly by running:

`npm config ls`

The registry should be set to http://btcnpmregistry.centralus.cloudapp.azure.com/ 

If not, set the correct registry

`npm config set registry http://btcnpmregistry.centralus.cloudapp.azure.com/`

## Client (mobile-connected)

Strings in the client are contained within the [localizations_sdk](https://code.connected.bmw/mobile20/mobile-connected/tree/master/localizations_sdk/lib/i18n/features) library.

## Adding String Translations
During development, add new strings to the strings files in the localizations_sdk - the files in this library are organized by features. Please make sure that you follow the naming conventions defined on the [localization page](../../architecture/core/localization)

If you're adding a new strings file, make sure you add a getter for the strings in [this](https://code.connected.bmw/mobile20/mobile-connected/blob/master/localizations_sdk/lib/i18n/localizations.dart) file.

Once the string files are ready:

1. Execute "**make update_translations**", run the dart formatter (`make format`), and commit the appeared changes (now the Strings are in your Translations).
2. When you execute "**make update_translations**" again you should see that no changes were made.
3. Ensure that files like "messages_en_KR.dart, messages_en_US.dart, messages_ko_KR.dart, messages_messages.dart" are NOT commited.

## Weekly Translation Tasks

Overview of steps:

1. Importing translations to latest release-branch
2. Importing translations to master-branch
3. Versioning intl_en.json file
4. Export translation file

## Importing Translations

### Jira Workflow

1. Download all .json files from the Jira-Tickets. Currently there are 9 files.

`intl_nl.json`
`intl_ko.json`
`intl_fr_LU.json`
`intl_fr_BE.json`
`intl_fr.json`
`intl_en_GB.json`
`intl_en.json`
`intl_de_LU.json`
`intl_de.json`

Attention: Please make sure all files are named correctly, especially the korean file:
Should be <u>intl_ko.json</u>, not: <u>intl_kr.json</u>. Watch out for correct upper/lowercaseing. (Intl vs. intl). Filenames are lowercase with the exception of the country code (last token).

2. Save these files in any convenient temporary folder. Say - Users/qNumber/translations

3. Navigate to that folder with the translation files and convert the .json into .arb-files by executing

   `npx arb-converter to-arb . --from-hierarchical-json .`

4. Go on with the steps of the common flow (see below).

### XML workflow

1. Put the XML file into the root of the mobile-connected repository.
    File example: `A4A_Mobile20_Client_2020-11_KW40_200928_1620_XML.xml`

2. Convert all languages into single .json files and put them into a new folder "mobile-connected/translations" by running

    `python scripts/cli/convert_xml_to_json.py`

3. Navigate to the mobile-connected/translations and convert the .json into .arb-files:

   `npx arb-converter to-arb . --from-hierarchical-json `

   Note: Do not commit this newly created folder!

4. Go on with the steps of the common flow (see below).

### Common Workflow

After receiving the `.arb` files from either Jira or xml you can go on with the importing process:

1. Copy and replace the .arb files into the `localizations_sdk/lib/i18n/l10` folder. Ignore (as in DELETE) and `_cn`  files for further processing. 

2. Generate the corresponding messages `_{​​​​​locale}​​​​​.dart` files for all locales by running from the localizations_sdk folder:

   `flutter pub run intl_translation:generate_from_arb --output-dir=lib/i18n/l10n --no-use-deferred-loading lib/i18n/features/*_strings.dart lib/i18n/l10n/intl_*.arb`

3. Revert now all changes to files, that do not concern languages you want to import!
   (this could be for example intl_zh_CN.arb, messages_zh_CN.dart)

4. Format the code by running
`make format`

5. You are now ready to commit and push. Create a Draft PR to see in which features tests fail.

6. Fix the tests, 

When opening a PR for a release branch (release/202X.XX) we can contact on BMW Teams Fabio.Carneiro@bmwgroup.com and ask for earlier merge. Before we do that, makre sure that otherwise the PR does meet all requirements for a regular PR (Tests, Reviewers)

### Versioning of the intl_en_US.json file

After successful import of the translations, we save the latest `intl_en.json`  file.

1. Checkout the translations_import repository
2. Create a branch named e.g. "import_dd.mm.yyyy", where the date should be the monday of the week.
3. Navigate to translation_imports/imports and delete the current file `intl_en.json`.
4. Now take the latest valid intl_en.json file that was imported to master and rename it to `intl_en_US.json` and put it into the translation_imports/imports folder.
5. Commit and push: commit-message should include the date of the import (i.e. monday of the week)
6. Create a PR. It can be directly merged after at least one approval from our Team.

## Exporting translations

In addition to the import, we also have to make an export from **release-branch** and from **master-branch**, which serves as a basis for the translation agency.

1. Checkout release-branch/master-branch of [mobile-connected](https://code.connected.bmw/mobile20/mobile-connected) and run the following to convert the arb files to json:

   `npx arb-converter from-arb ./localizations_sdk/lib/i18n/l10n/intl_messages.arb --to-hierarchical-json intl_messages.json`
   
   Now the `intl_messages.json` file in mobile-connected should be updated.
   
2. In each case (relase or master) copy and save the `intl_messages.json` in any other convenient folder, rename it to `intl_messages_release.json`, resp. `intl_messages_master.json`.
  
3. Send both files to Robert Vasenda

4. Delete the  `intl_messages.json`file in the repository

## BFFs

The string file setup in the BFFs is fairly simple. Each locale has json files that contain strings. the en_US json file is submitted for translations and we get back the corresponding json files for all other supported locales. Just include these files in the correct folder locations in the project and run the formatter.
