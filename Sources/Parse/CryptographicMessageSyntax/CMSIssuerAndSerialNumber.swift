// CMSIssuerAndSerialNumber.swift
// Copyright (c) 2024 hiimtmac inc.

import SwiftASN1
import X509

// https://github.com/apple/swift-certificates/blob/main/Sources/X509/DistinguishedName.swift#L197

extension DistinguishedName {
    @inlinable
    static func derEncoded(_ sequenceNodeIterator: inout ASN1NodeCollection.Iterator) throws -> DistinguishedName {
        // This is a workaround for the fact that, even though the conformance to DERImplicitlyTaggable is
        // deprecated, Swift still prefers calling init(derEncoded:withIdentifier:) instead of this one.
        let dnFactory: (inout ASN1NodeCollection.Iterator) throws -> DistinguishedName =
        DistinguishedName.init(derEncoded:)
        return try dnFactory(&sequenceNodeIterator)
    }
}

// https://github.com/apple/swift-certificates/blob/197ba89b062c6dfb2770aebde741b76572d5bc71/Sources/X509/CryptographicMessageSyntax/CMSIssuerAndSerialNumber.swift

/// ``CMSIssuerAndSerialNumber`` is defined in ASN.1 as:
/// ```
/// IssuerAndSerialNumber ::= SEQUENCE {
///         issuer Name,
///         serialNumber CertificateSerialNumber }
/// ```
/// The definition of `Name` is taken from X.501 [X.501-88], and the
/// definition of `CertificateSerialNumber` is taken from X.509 [X.509-97].
@usableFromInline
struct CMSIssuerAndSerialNumber: DERParseable, Hashable {
    @usableFromInline
    var issuer: DistinguishedName

    @usableFromInline
    var serialNumber: Certificate.SerialNumber

    @inlinable
    init(
        issuer: DistinguishedName,
        serialNumber: Certificate.SerialNumber
    ) {
        self.issuer = issuer
        self.serialNumber = serialNumber
    }

    @inlinable
    init(derEncoded rootNode: ASN1Node) throws {
        self = try DER.sequence(rootNode, identifier: .sequence) { nodes in
            let issuer = try DistinguishedName.derEncoded(&nodes)
            let serialNumber = try ArraySlice<UInt8>(derEncoded: &nodes)
            return .init(issuer: issuer, serialNumber: .init(bytes: serialNumber))
        }
    }
}
