import SwiftASN1

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
struct CMSSignedData: DERParseable {
    @usableFromInline 
    var encapContentInfo: CMSEncapsulatedContentInfo

    @inlinable
    init(
        encapContentInfo: CMSEncapsulatedContentInfo
    ) {
        self.encapContentInfo = encapContentInfo
    }

    @inlinable
    init(derEncoded: ASN1Node) throws {
        self = try DER.sequence(derEncoded, identifier: .sequence) { nodes in
            // we need to skip this node even though we don't support it (version)
            _ = try ASN1Any(derEncoded: &nodes)
            // we need to skip this node even though we don't support it (digest algos)
            _ = try ASN1Any(derEncoded: &nodes)
//            let digestAlgorithms = try DER.set(of: AlgorithmIdentifier.self, identifier: .set, nodes: &nodes)

            let encapContentInfo = try CMSEncapsulatedContentInfo(derEncoded: &nodes)
            // we need to skip this node even though we don't support it (certificates)
            _ = DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { _ in }

            // we need to skip this node even though we don't support it (crls)
            _ = DER.optionalImplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) { _ in }

            // we need to skip this node even though we don't support it (signer infos)
            _ = try ASN1Any(derEncoded: &nodes)
//            let signerInfos = try DER.set(of: CMSSignerInfo.self, identifier: .set, nodes: &nodes)

            return .init(encapContentInfo: encapContentInfo)
        }
    }
}
