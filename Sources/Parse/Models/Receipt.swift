// Receipt.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation

public struct Receipt {
    public let bundleIdentifier: String
    public let appVersion: String
    public let opaqueValue: ArraySlice<UInt8>
    public let sha1Hash: String
    public let inAppPurchaseReceipts: [InAppPurchaseReceipt]
    public let originalApplicationVersion: String
    public let receiptCreationDate: Date
    public let receiptExpirationDate: Date?

    public struct InAppPurchaseReceipt {
        public let quantity: Int
        public let productIdentifier: String
        public let transactionIdentifier: String
        public let originalTransactionIdentifier: String
        public let purchaseDate: Date
        public let originalPurchaseDate: Date
        public let subscriptionExpirationDate: Date?
        public let subscriptionIntroductoryPricePeriod: Int?
        public let cancellationDate: Date?
        public let webOrderLineItemID: Int
    }
}
