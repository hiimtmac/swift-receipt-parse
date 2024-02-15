import SwiftASN1
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

public enum ReceiptParser {
    public static func parse(from data: Data) throws -> Receipt {
        let decodedCMSContentInfo = Array(data)
        let result = try DER.parse(decodedCMSContentInfo)
        let cmsContentInfo = try CMSContentInfo(derEncoded: result)
        
        guard cmsContentInfo.contentType == .cmsSignedData else {
            throw Error.contentTypeMismatch
        }
        
        let signedData = try CMSSignedData(asn1Any: cmsContentInfo.content)
        let parsedContent = try DER.parse(signedData.encapContentInfo.eContent.bytes)
        
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
        case missingValue(String)
        
        var errorDescription: String? {
            switch self {
            case .contentTypeMismatch: "Receipt structure is not PKCS7 signed data"
            case .missingValue(let string): "Unable to decode field \(string)"
            }
        }
    }
}
