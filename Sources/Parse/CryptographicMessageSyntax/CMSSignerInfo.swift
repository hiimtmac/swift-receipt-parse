// CMSSignerInfo.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation
import SwiftASN1

// https://github.com/apple/swift-certificates/blob/197ba89b062c6dfb2770aebde741b76572d5bc71/Sources/X509/CryptographicMessageSyntax/CMSSignerInfo.swift

/// ``CMSSignerInfo`` is defined in ASN.1 as:
/// ```
/// SignerInfo ::= SEQUENCE {
///   version CMSVersion,
///   sid SignerIdentifier,
///   digestAlgorithm DigestAlgorithmIdentifier,
///   signedAttrs [0] IMPLICIT SignedAttributes OPTIONAL,
///   signatureAlgorithm SignatureAlgorithmIdentifier,
///   signature SignatureValue,
///   unsignedAttrs [1] IMPLICIT UnsignedAttributes OPTIONAL }
///
/// SignatureValue ::= OCTET STRING
/// DigestAlgorithmIdentifier ::= AlgorithmIdentifier
/// SignatureAlgorithmIdentifier ::= AlgorithmIdentifier
/// ```
/// - Note: If the `SignerIdentifier` is the CHOICE `issuerAndSerialNumber`,
/// then the `version` MUST be 1.  If the `SignerIdentifier` is `subjectKeyIdentifier`,
/// then the `version` MUST be 3.
@usableFromInline
struct CMSSignerInfo: DERParseable, Hashable {
    @usableFromInline
    var version: CMSVersion

    @usableFromInline
    var signerIdentifier: CMSSignerIdentifier

    @usableFromInline
    var digestAlgorithm: AlgorithmIdentifier

    @usableFromInline
    var signature: ASN1OctetString

    @usableFromInline
    var signatureAlgorithm: AlgorithmIdentifier

    @inlinable
    init(
        version: CMSVersion,
        signerIdentifier: CMSSignerIdentifier,
        digestAlgorithm: AlgorithmIdentifier,
        signatureAlgorithm: AlgorithmIdentifier,
        signature: ASN1OctetString
    ) {
        self.version = version
        self.signerIdentifier = signerIdentifier
        self.digestAlgorithm = digestAlgorithm
        self.signatureAlgorithm = signatureAlgorithm
        self.signature = signature
    }

    @inlinable
    init(derEncoded rootNode: ASN1Node) throws {
        self = try DER.sequence(rootNode, identifier: .sequence) { nodes in
            let version = try CMSVersion(rawValue: Int(derEncoded: &nodes))

            let signerIdentifier = try CMSSignerIdentifier(derEncoded: &nodes)

            let digestAlgorithm = try AlgorithmIdentifier(derEncoded: &nodes)

            // we need to skip this node even though we don't support it (signed attributes)
            _ = DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { _ in }

            let signatureAlgorithm = try AlgorithmIdentifier(derEncoded: &nodes)

            let signature = try ASN1OctetString(derEncoded: &nodes)

            // we need to skip this node even though we don't support it (unsigned attributes)
            _ = DER.optionalImplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) { _ in }

            return .init(
                version: version,
                signerIdentifier: signerIdentifier,
                digestAlgorithm: digestAlgorithm,
                signatureAlgorithm: signatureAlgorithm,
                signature: signature
            )
        }
    }
}
