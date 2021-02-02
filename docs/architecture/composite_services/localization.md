---

layout: default
title: Localization
parent: Composite Services
grand_parent: Localization
nav_order: 4

---

# Localization

For localization in the backend, we use [nestjs-i18n](https://www.npmjs.com/package/nestjs-i18n) which allows for an easy way to handle translations on the backend.

## Folder Structure

Translations will be stored in an `i18n` folder in the root of your composite, and there will be a subdirectory for each supported locale (`en_KR`, `en_US`, etc.), which should be auto-generated when you scaffold your project with the generator. Inside each of those folders you will have JSON files containing your key/value strings. Then when needing to reference any localized string, you can use dependency injection to inject your `Localizations` and reference any of the necessary keys.

## Adding Translations

When adding a new string, add it to the `en_US.json` file with the english translation. When needing to get translations for existing keys, the `en_US.json` file will be sent to the translations team and once they get the translated strings from OneSky, the corresponding JSON files will be put into a translations ticket which can then be manually added to the composite service.
