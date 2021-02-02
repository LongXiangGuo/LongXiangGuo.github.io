---
layout: default
title: Legal Documents
parent: GDPR
grand_parent: Architecture
nav_order: 2
---

# Legal Document NPM Package

Currently there are 3 public methods in the [NPM package](https://code.connected.bmw/library/bmw-npm/tree/master/packages/legal-document-api) that are used to access the [Core Legal Docs API](https://code.connected.bmw/core-services/legal-document-check-service):

1. `isAcceptanceRequired` will retrieve whether or not acceptance is required due to a first-time log-in, or the legal documents have been updated since the last time the user accepted them. If a locale is not passed in, the default language for that region will be returned.

2. `getLegalDocuments` will retrieve the legal documents to display in the corresponding language. If a locale is not passed in, the default language for that region will be returned.

3. `acceptLatestPolicies` will accept the given version of legal policies for the user.

The core API will take as a parameter a `acceptanceRequiredOptions` model:

```javascript
interface AcceptanceRequiredOptions {
  appbrand: AppBrand;
  clientVersion: string;
  locale?: string;
  platform: Platform;
  region: Region;
  useAcceptedLocale?: boolean;
}
```

The core API will use this information to look up the correct legal documents to display based on the information passed in. If a `locale` is not specified, then the default `locale` for the given `Region` will be used.

## Core Legal Document Resources

- [Legal Document Check API](https://code.connected.bmw/core-services/legal-document-check-service) is a service to handle interactions with legal documents and acceptances.
- [Legal Document Processor](https://code.connected.bmw/internal-tools/legal-documents-web) converts .doc files into GDPR readable JSON.
- [Legal Document Deployment Script](https://code.connected.bmw/internal-tools/legal-documents) will handle deployment new sets of legal documents
