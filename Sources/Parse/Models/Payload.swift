// Payload.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation
import SwiftASN1

@usableFromInline
struct Payload: DERParseable {
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

extension Payload {
    var bundleIdentifier: String? {
        get throws { try attributes.bundleIdentifier }
    }

    var appVersion: String? {
        get throws { try attributes.appVersion }
    }

    var opaqueValue: ArraySlice<UInt8>? {
        get throws { try attributes.opaqueValue }
    }

    var sha1Hash: String? {
        get throws { try attributes.sha1Hash }
    }

    var inAppPurchaseReceipts: [InAppPurchaseReceipt]? {
        get throws { try attributes.inAppPurchaseReceipts }
    }

    var originalApplicationVersion: String? {
        get throws { try attributes.originalApplicationVersion }
    }

    var receiptCreationDate: Date? {
        get throws { try attributes.receiptCreationDate }
    }

    var receiptExpirationDate: Date? {
        get throws { try attributes.receiptExpirationDate }
    }
}

extension Int {
    @usableFromInline
    static let bundleIdentifier = 2
    @usableFromInline
    static let appVersion = 3
    @usableFromInline
    static let opaqueValue = 4
    @usableFromInline
    static let sha1Hash = 5
    @usableFromInline
    static let inAppPurchaseReceipt = 17
    @usableFromInline
    static let originalApplicationVersion = 19
    @usableFromInline
    static let receiptCreationDate = 12
    @usableFromInline
    static let receiptExpirationDate = 21
}

extension Array where Element == Attribute {
    @inlinable
    var bundleIdentifier: String? {
        get throws {
            if let attr = self[.bundleIdentifier] {
                // TODO: could this use Time?
//                let time = try Time(asn1Any: attr.attrValues[0])
//                return Date(time)
                let utf8 = try ASN1UTF8String(derEncoded: attr.value.bytes)
                return String(utf8)
            }
            return nil
        }
    }

    @inlinable
    var appVersion: String? {
        get throws {
            if let attr = self[.appVersion] {
                let utf8 = try ASN1UTF8String(derEncoded: attr.value.bytes)
                return String(utf8)
            }
            return nil
        }
    }

    @inlinable
    var opaqueValue: ArraySlice<UInt8>? {
        get throws {
            if let attr = self[.opaqueValue] {
                return attr.value.bytes
            }
            return nil
        }
    }

    @inlinable
    var sha1Hash: String? {
        get throws {
            if let attr = self[.sha1Hash] {
                return attr.value.bytes
                    .map { String(format: "%02hhx", $0) }
                    .joined()
            }
            return nil
        }
    }

    @inlinable
    var inAppPurchaseReceipts: [InAppPurchaseReceipt]? {
        get throws {
            let attrs = self[all: .inAppPurchaseReceipt]
            let contents = try attrs.map(\.value.bytes).map(DER.parse)
            return try contents.map(InAppPurchaseReceipt.init)
        }
    }

    @inlinable
    var originalApplicationVersion: String? {
        get throws {
            if let attr = self[.originalApplicationVersion] {
                let utf8 = try ASN1UTF8String(derEncoded: attr.value.bytes)
                return String(utf8)
            }
            return nil
        }
    }

    @inlinable
    var receiptCreationDate: Date? {
        get throws {
            if let attr = self[.receiptCreationDate] {
                let ia5 = try ASN1IA5String(derEncoded: attr.value.bytes)
                let string = String(ia5)
                return DateFormatter.rfc3339.date(from: string)
            }
            return nil
        }
    }

    @inlinable
    var receiptExpirationDate: Date? {
        get throws {
            if let attr = self[.receiptExpirationDate] {
                let ia5 = try ASN1IA5String(derEncoded: attr.value.bytes)
                let string = String(ia5)
                return DateFormatter.rfc3339.date(from: string)
            }
            return nil
        }
    }
}
