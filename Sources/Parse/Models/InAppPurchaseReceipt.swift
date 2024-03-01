// InAppPurchaseReceipt.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation
import SwiftASN1

@usableFromInline
struct InAppPurchaseReceipt: DERParseable {
    @usableFromInline
    var attributes: [Attribute]

    @inlinable
    init(derEncoded rootNode: ASN1Node) throws {
        self.attributes = try DER.set(
            of: Attribute.self,
            identifier: .set,
            rootNode: rootNode
        )
    }
}

extension InAppPurchaseReceipt {
    var quantity: Int? {
        get throws { try attributes.quantity }
    }

    var productIdentifier: String? {
        get throws { try attributes.productIdentifier }
    }

    var transactionIdentifier: String? {
        get throws { try attributes.transactionIdentifier }
    }

    var originalTransactionIdentifier: String? {
        get throws { try attributes.originalTransactionIdentifier }
    }

    var purchaseDate: Date? {
        get throws { try attributes.purchaseDate }
    }

    var originalPurchaseDate: Date? {
        get throws { try attributes.originalPurchaseDate }
    }

    var subscriptionExpirationDate: Date? {
        get throws { try attributes.subscriptionExpirationDate }
    }

    var subscriptionIntroductoryPricePeriod: Int? {
        get throws { try attributes.subscriptionIntroductoryPricePeriod }
    }

    var cancellationDate: Date? {
        get throws { try attributes.cancellationDate }
    }

    var webOrderLineItemID: Int? {
        get throws { try attributes.webOrderLineItemID }
    }
}

extension Int {
    @usableFromInline
    static let quantity = 1701
    @usableFromInline
    static let productIdentifier = 1702
    @usableFromInline
    static let transactionIdentifier = 1703
    @usableFromInline
    static let originalTransactionIdentifier = 1705
    @usableFromInline
    static let purchaseDate = 1704
    @usableFromInline
    static let originalPurchaseDate = 1706
    @usableFromInline
    static let subscriptionExpirationDate = 1708
    @usableFromInline
    static let subscriptionIntroductoryPricePeriod = 1719
    @usableFromInline
    static let cancellationDate = 1712
    @usableFromInline
    static let webOrderLineItemID = 1711
}

extension Array where Element == Attribute {
    @inlinable
    var quantity: Int? {
        get throws {
            if let attr = self[.quantity] {
                return try Int(derEncoded: attr.value.bytes)
            }
            return nil
        }
    }

    @inlinable
    var productIdentifier: String? {
        get throws {
            if let attr = self[.productIdentifier] {
                let utf8 = try ASN1UTF8String(derEncoded: attr.value.bytes)
                return String(utf8)
            }
            return nil
        }
    }

    @inlinable
    var transactionIdentifier: String? {
        get throws {
            if let attr = self[.transactionIdentifier] {
                let utf8 = try ASN1UTF8String(derEncoded: attr.value.bytes)
                return String(utf8)
            }
            return nil
        }
    }

    @inlinable
    var originalTransactionIdentifier: String? {
        get throws {
            if let attr = self[.originalTransactionIdentifier] {
                let utf8 = try ASN1UTF8String(derEncoded: attr.value.bytes)
                return String(utf8)
            }
            return nil
        }
    }

    @inlinable
    var purchaseDate: Date? {
        get throws {
            if let attr = self[.purchaseDate] {
                let ia5 = try ASN1IA5String(derEncoded: attr.value.bytes)
                let string = String(ia5)
                return DateFormatter.rfc3339.date(from: string)
            }
            return nil
        }
    }

    @inlinable
    var originalPurchaseDate: Date? {
        get throws {
            if let attr = self[.originalPurchaseDate] {
                let ia5 = try ASN1IA5String(derEncoded: attr.value.bytes)
                let string = String(ia5)
                return DateFormatter.rfc3339.date(from: string)
            }
            return nil
        }
    }

    @inlinable
    var subscriptionExpirationDate: Date? {
        get throws {
            if let attr = self[.subscriptionExpirationDate] {
                let ia5 = try ASN1IA5String(derEncoded: attr.value.bytes)
                let string = String(ia5)
                return DateFormatter.rfc3339.date(from: string)
            }
            return nil
        }
    }

    @inlinable
    var subscriptionIntroductoryPricePeriod: Int? {
        get throws {
            if let attr = self[.subscriptionIntroductoryPricePeriod] {
                return try Int(derEncoded: attr.value.bytes)
            }
            return nil
        }
    }

    @inlinable
    var cancellationDate: Date? {
        get throws {
            if let attr = self[.cancellationDate] {
                let ia5 = try ASN1IA5String(derEncoded: attr.value.bytes)
                let string = String(ia5)
                return DateFormatter.rfc3339.date(from: string)
            }
            return nil
        }
    }

    @inlinable
    var webOrderLineItemID: Int? {
        get throws {
            if let attr = self[.webOrderLineItemID] {
                return try Int(derEncoded: attr.value.bytes)
            }
            return nil
        }
    }
}
