# swift-receipt-parse

A library for parsing apple receipts

## Overview

This library helps to parse PKCS7 receipt data from Apple in its ASN1 form using only swift (no openssl needed). Some CMS structures copied from [swift-certificates](https://github.com/apple/swift-certificates) as there is non-public API. Right now no signature validation occurs and the signature and certificates are ignored.

## Getting Started

To use swift-receipt-parse, add the following dependency to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/hiimtmac/swift-receipt-parse.git", branch: "main")
]
```

> [!WARNING]
> Note that this repository does not have any tags yet, so the API is not stable.

You can then add the specific product dependency to your target:

```swift
dependencies: [
    .product(name: "ReceiptParse", package: "swift-receipt-parse"),
]
```

#### Documentation

https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1
https://developer.apple.com/documentation/appstorereceipts/validating_receipts_on_the_device#//apple_ref/doc/uid/TP40010573-CH1-SW2
