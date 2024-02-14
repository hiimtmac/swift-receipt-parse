import SwiftASN1

extension ASN1ObjectIdentifier {
    /// Cryptographic Message Syntax (CMS) Signed Data.
    ///
    /// ASN.1 definition:
    /// ```
    /// id-signedData OBJECT IDENTIFIER ::= { iso(1) member-body(2)
    ///    us(840) rsadsi(113549) pkcs(1) pkcs7(7) 2 }
    /// ```
    @usableFromInline
    static let cmsSignedData: ASN1ObjectIdentifier = [1, 2, 840, 113549, 1, 7, 2]
}

/// ``ContentInfo`` is defined in ASN.1 as:
/// ```
/// ContentInfo ::= SEQUENCE {
///   contentType ContentType,
///   content [0] EXPLICIT ANY DEFINED BY contentType }
/// ContentType ::= OBJECT IDENTIFIER
/// ```
@usableFromInline
struct CMSContentInfo: DERParseable {
    @usableFromInline
    var contentType: ASN1ObjectIdentifier
    
    @usableFromInline
    var content: ASN1Any
    
    @inlinable
    init(contentType: ASN1ObjectIdentifier, content: ASN1Any) {
        self.contentType = contentType
        self.content = content
    }
    
    @inlinable
    init(derEncoded rootNode: ASN1Node) throws {
        self = try DER.sequence(rootNode, identifier: .sequence) { nodes in
            let contentType = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let content = try DER.explicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in
                ASN1Any(derEncoded: node)
            }
            return .init(contentType: contentType, content: content)
        }
    }
}
