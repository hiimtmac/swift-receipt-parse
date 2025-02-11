// CMSSignerIdentifier.swift
// Copyright (c) 2024 hiimtmac inc.

import SwiftASN1
import X509

// https://github.com/apple/swift-certificates/blob/197ba89b062c6dfb2770aebde741b76572d5bc71/Sources/X509/CryptographicMessageSyntax/CMSSignerIdentifier.swift

/// ``CMSSignerIdentifier`` is defined in ASN.1 as:
/// ```
/// SignerIdentifier ::= CHOICE {
///   issuerAndSerialNumber IssuerAndSerialNumber,
///   subjectKeyIdentifier [0] SubjectKeyIdentifier }
///  ```
@usableFromInline
enum CMSSignerIdentifier: DERParseable, Hashable {
    @usableFromInline
    static let skiIdentifier = ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)

    case issuerAndSerialNumber(CMSIssuerAndSerialNumber)
    case subjectKeyIdentifier(SubjectKeyIdentifier)

    @inlinable
    init(derEncoded node: ASN1Node) throws {
        switch node.identifier {
        case .sequence:
            self = try .issuerAndSerialNumber(.init(derEncoded: node))

        case Self.skiIdentifier:
            self = try DER.explicitlyTagged(
                node,
                tagNumber: Self.skiIdentifier.tagNumber,
                tagClass: Self.skiIdentifier.tagClass
            ) { node in
                .subjectKeyIdentifier(.init(keyIdentifier: try ASN1OctetString(derEncoded: node).bytes))
            }

        default:
            throw ASN1Error.unexpectedFieldType(node.identifier)
        }
    }

    @inlinable
    init(issuerAndSerialNumber certificate: Certificate) {
        self = .issuerAndSerialNumber(.init(issuer: certificate.issuer, serialNumber: certificate.serialNumber))
    }
}
