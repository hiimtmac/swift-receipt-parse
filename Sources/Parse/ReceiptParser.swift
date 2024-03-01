// ReceiptParser.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation
import SwiftASN1

public enum ReceiptParser {
    public static func parse(from data: Data) throws -> Receipt {
        let decodedCMSContentInfo = Array(data)
        let result = try DER.parse(decodedCMSContentInfo)
        let cmsContentInfo = try CMSContentInfo(derEncoded: result)

        guard cmsContentInfo.contentType == .cmsSignedData else {
            throw Error.contentTypeMismatch
        }

        let signedData = try CMSSignedData(asn1Any: cmsContentInfo.content)
        guard let eContent = signedData.encapContentInfo.eContent else {
            throw Error.eContentMissing
        }
        let parsedContent = try DER.parse(eContent.bytes)

        let parsedReceipt = try Payload(derEncoded: parsedContent)

        guard let bundleIdentifier = try parsedReceipt.bundleIdentifier else {
            throw Error.missingValue("Payload.bundleIdentifier")
        }

        guard let appVersion = try parsedReceipt.appVersion else {
            throw Error.missingValue("Payload.appVersion")
        }

        guard let opaqueValue = try parsedReceipt.opaqueValue else {
            throw Error.missingValue("Payload.opaqueValue")
        }

        guard let sha1Hash = try parsedReceipt.sha1Hash else {
            throw Error.missingValue("Payload.sha1Hash")
        }

        guard let originalApplicationVersion = try parsedReceipt.originalApplicationVersion else {
            throw Error.missingValue("Payload.originalApplicationVersion")
        }

        guard let receiptCreationDate = try parsedReceipt.receiptCreationDate else {
            throw Error.missingValue("Payload.receiptCreationDate")
        }

        let inAppPurchaseReceipts = try parsedReceipt.inAppPurchaseReceipts ?? []

        let parsedInAppPurchaseReceipts = try inAppPurchaseReceipts.map { receipt in
            guard let quantity = try receipt.quantity else {
                throw Error.missingValue("Payload.inAppPurchaseReceipts.quantity")
            }

            guard let productIdentifier = try receipt.productIdentifier else {
                throw Error.missingValue("Payload.inAppPurchaseReceipts.quantity")
            }

            guard let transactionIdentifier = try receipt.transactionIdentifier else {
                throw Error.missingValue("Payload.inAppPurchaseReceipts.transactionIdentifier")
            }

            guard let originalTransactionIdentifier = try receipt.originalTransactionIdentifier else {
                throw Error.missingValue("Payload.inAppPurchaseReceipts.originalTransactionIdentifier")
            }

            guard let purchaseDate = try receipt.purchaseDate else {
                throw Error.missingValue("Payload.inAppPurchaseReceipts.purchaseDate")
            }

            guard let originalPurchaseDate = try receipt.originalPurchaseDate else {
                throw Error.missingValue("Payload.inAppPurchaseReceipts.originalPurchaseDate")
            }

            guard let webOrderLineItemID = try receipt.webOrderLineItemID else {
                throw Error.missingValue("Payload.inAppPurchaseReceipts.webOrderLineItemID")
            }

            return Receipt.InAppPurchaseReceipt(
                quantity: quantity,
                productIdentifier: productIdentifier,
                transactionIdentifier: transactionIdentifier,
                originalTransactionIdentifier: originalTransactionIdentifier,
                purchaseDate: purchaseDate,
                originalPurchaseDate: originalPurchaseDate,
                subscriptionExpirationDate: try receipt.subscriptionExpirationDate,
                subscriptionIntroductoryPricePeriod: try receipt.subscriptionIntroductoryPricePeriod,
                cancellationDate: try receipt.cancellationDate,
                webOrderLineItemID: webOrderLineItemID
            )
        }

        return Receipt(
            bundleIdentifier: bundleIdentifier,
            appVersion: appVersion,
            opaqueValue: opaqueValue,
            sha1Hash: sha1Hash,
            inAppPurchaseReceipts: parsedInAppPurchaseReceipts,
            originalApplicationVersion: originalApplicationVersion,
            receiptCreationDate: receiptCreationDate,
            receiptExpirationDate: try parsedReceipt.receiptExpirationDate
        )
    }

    enum Error: Swift.Error, LocalizedError {
        case contentTypeMismatch
        case eContentMissing
        case missingValue(String)
        case noCertificates
        case noSignerInfo

        var errorDescription: String? {
            switch self {
            case .contentTypeMismatch: "Receipt structure is not PKCS7 signed data"
            case .eContentMissing: "Receipt missing content"
            case let .missingValue(string): "Unable to decode field \(string)"
            case .noCertificates: "No certificates in PKCS7 structure"
            case .noSignerInfo: "No signer info in PKCS7 structure"
            }
        }
    }
}
