// CMSSignedData.swift
// Copyright (c) 2026 hiimtmac inc.

public import SwiftASN1
#if Verification
public import X509
#endif

// https://github.com/apple/swift-certificates/blob/197ba89b062c6dfb2770aebde741b76572d5bc71/Sources/X509/CryptographicMessageSyntax/CMSSignedData.swift

/// ``SignedData`` is defined in ASN.1 as:
/// ```
/// SignedData ::= SEQUENCE {
///   version CMSVersion,
///   digestAlgorithms DigestAlgorithmIdentifiers,
///   encapContentInfo EncapsulatedContentInfo,
///   certificates [0] IMPLICIT CertificateSet OPTIONAL,
///   crls [1] IMPLICIT RevocationInfoChoices OPTIONAL,
///   signerInfos SignerInfos }
///
/// DigestAlgorithmIdentifiers ::= SET OF DigestAlgorithmIdentifier
/// DigestAlgorithmIdentifier ::= AlgorithmIdentifier
/// SignerInfos ::= SET OF SignerInfo
/// CertificateSet ::= SET OF CertificateChoices
///
/// CertificateChoices ::= CHOICE {
///  certificate Certificate,
///  extendedCertificate [0] IMPLICIT ExtendedCertificate, -- Obsolete
///  v1AttrCert [1] IMPLICIT AttributeCertificateV1,       -- Obsolete
///  v2AttrCert [2] IMPLICIT AttributeCertificateV2,
///  other [3] IMPLICIT OtherCertificateFormat }
///
/// OtherCertificateFormat ::= SEQUENCE {
///   otherCertFormat OBJECT IDENTIFIER,
///   otherCert ANY DEFINED BY otherCertFormat }
/// ```
/// - Note: At the moment we don't support `crls` (`RevocationInfoChoices`)
@usableFromInline
struct CMSSignedData: DERParseable, Hashable {
    @usableFromInline
    var version: CMSVersion

    @usableFromInline
    var digestAlgorithms: [AlgorithmIdentifier]

    @usableFromInline
    var encapContentInfo: CMSEncapsulatedContentInfo

    #if Verification
    @usableFromInline
    var certificates: [Certificate]?

    @usableFromInline
    var signerInfos: [CMSSignerInfo]

    @inlinable
    init(
        version: CMSVersion,
        digestAlgorithms: [AlgorithmIdentifier],
        encapContentInfo: CMSEncapsulatedContentInfo,
        certificates: [Certificate]?,
        signerInfos: [CMSSignerInfo]
    ) {
        self.version = version
        self.digestAlgorithms = digestAlgorithms
        self.encapContentInfo = encapContentInfo
        self.certificates = certificates
        self.signerInfos = signerInfos
    }
    
    #else
    
    @inlinable
    init(
        version: CMSVersion,
        digestAlgorithms: [AlgorithmIdentifier],
        encapContentInfo: CMSEncapsulatedContentInfo
    ) {
        self.version = version
        self.digestAlgorithms = digestAlgorithms
        self.encapContentInfo = encapContentInfo
    }
    #endif

    @inlinable
    init(derEncoded: ASN1Node) throws {
        self = try DER.sequence(derEncoded, identifier: .sequence) { nodes in
            let version = try CMSVersion(rawValue: Int.init(derEncoded: &nodes))

            let digestAlgorithms = try DER.set(of: AlgorithmIdentifier.self, identifier: .set, nodes: &nodes)

            let encapContentInfo = try CMSEncapsulatedContentInfo(derEncoded: &nodes)

            #if Verification
            let certificates = try DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) {
                node in
                try DER._set(
                    of: Certificate.self,
                    identifier: .init(tagWithNumber: 0, tagClass: .contextSpecific),
                    rootNode: node
                )
            }
            #else
            _ = DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { _ in }
            #endif

            // we need to skip this node even though we don't support it (crls)
            _ = DER.optionalImplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) { _ in }

            #if Verification
            let signerInfos = try DER.set(of: CMSSignerInfo.self, identifier: .set, nodes: &nodes)
            #else
            _ = try ASN1Any(derEncoded: &nodes)
            #endif

            #if Verification
            return .init(
                version: version,
                digestAlgorithms: digestAlgorithms,
                encapContentInfo: encapContentInfo,
                certificates: certificates,
                signerInfos: signerInfos
            )
            #else
            return .init(
                version: version,
                digestAlgorithms: digestAlgorithms,
                encapContentInfo: encapContentInfo
            )
            #endif
        }
    }
}

extension DER {
    @inlinable
    static func _set<T: DERParseable>(
        of: T.Type = T.self,
        identifier: ASN1Identifier,
        rootNode: ASN1Node
    ) throws -> [T] {
        guard rootNode.identifier == identifier, case let .constructed(nodes) = rootNode.content else {
            throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }

        return try nodes.map { node in try T(derEncoded: node) }
    }
}
