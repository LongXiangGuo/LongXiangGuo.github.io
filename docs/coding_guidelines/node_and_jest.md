---
layout: default
title: Node & Jest
parent: Coding Guidelines
nav_order: 8
---

# Node & Jest Coding Guidelines

{: .no_toc }

## Table of contents

{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Node

## Overview

TBD

## 1. Tests

### 1A. Avoid using unnecessary mock methods

Mock is a test-double that is intended for verifying that a method was called. When we don't need to verify that the method was called then we shouldn't use it.

✅ Good

```typescript
vehicle.isMapped = () => true;
```

❌ Bad

```typescript
vehicle.isMapped = jest.fn().mockReturnValue(true);
```
