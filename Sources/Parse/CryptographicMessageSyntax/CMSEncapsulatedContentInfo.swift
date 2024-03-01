// CMSEncapsulatedContentInfo.swift
// Copyright (c) 2024 hiimtmac inc.

import SwiftASN1

/// ``CMSEncapsulatedContentInfo`` is defined in ASN.1 as:
/// ```
/// EncapsulatedContentInfo ::= SEQUENCE {
///   eContentType ContentType,
///   eContent [0] EXPLICIT OCTET STRING OPTIONAL }
/// ContentType ::= OBJECT IDENTIFIER
/// ```
@usableFromInline
struct CMSEncapsulatedContentInfo: DERParseable, Hashable {
    @usableFromInline
    var eContentType: ASN1ObjectIdentifier

    @usableFromInline
    var eContent: ASN1OctetString?

    @inlinable
    init(eContentType: ASN1ObjectIdentifier, eContent: ASN1OctetString? = nil) {
        self.eContentType = eContentType
        self.eContent = eContent
    }

    @inlinable
    init(derEncoded rootNode: ASN1Node) throws {
        self = try DER.sequence(rootNode, identifier: .sequence) { nodes in
            let eContentType = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let eContent = try DER.optionalExplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in
                try ASN1OctetString(derEncoded: node)
            }

            return .init(eContentType: eContentType, eContent: eContent)
        }
    }
}
