// AlgorithmIdentifier.swift
// Copyright (c) 2024 hiimtmac inc.

import SwiftASN1

@usableFromInline
package struct AlgorithmIdentifier: DERParseable, Hashable, Sendable {
    @usableFromInline
    var algorithm: ASN1ObjectIdentifier

    @usableFromInline
    var parameters: ASN1Any?

    @inlinable
    init(algorithm: ASN1ObjectIdentifier, parameters: ASN1Any?) {
        self.algorithm = algorithm
        self.parameters = parameters
    }

    @inlinable
    package init(derEncoded rootNode: ASN1Node) throws {
        // The AlgorithmIdentifier block looks like this.
        //
        // AlgorithmIdentifier  ::=  SEQUENCE  {
        //   algorithm   OBJECT IDENTIFIER,
        //   parameters  ANY DEFINED BY algorithm OPTIONAL
        // }
        self = try DER.sequence(rootNode, identifier: .sequence) { nodes in
            let algorithmOID = try ASN1ObjectIdentifier(derEncoded: &nodes)

            let parameters = nodes.next().map { ASN1Any(derEncoded: $0) }

            return .init(algorithm: algorithmOID, parameters: parameters)
        }
    }
}

// MARK: Algorithm Identifier Statics

extension AlgorithmIdentifier {
    // MARK: For the RSA signature types, explicit ASN.1 NULL is equivalent to a missing parameters field.

    // We include both here, and the usage sites need to handle the equivalent.
    @usableFromInline
    static let sha1WithRSAEncryption = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha1WithRSAEncryption,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    @usableFromInline
    static let sha1WithRSAEncryptionUsingNil = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha1WithRSAEncryption,
        parameters: nil
    )

    @usableFromInline
    static let sha256WithRSAEncryption = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha256WithRSAEncryption,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    @usableFromInline
    static let sha256WithRSAEncryptionUsingNil = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha256WithRSAEncryption,
        parameters: nil
    )

    @usableFromInline
    static let sha384WithRSAEncryption = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha384WithRSAEncryption,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    @usableFromInline
    static let sha384WithRSAEncryptionUsingNil = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha384WithRSAEncryption,
        parameters: nil
    )

    @usableFromInline
    static let sha512WithRSAEncryption = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha512WithRSAEncryption,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    @usableFromInline
    static let sha512WithRSAEncryptionUsingNil = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha512WithRSAEncryption,
        parameters: nil
    )

    @usableFromInline
    static let rsaKey = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.rsaEncryption,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    @usableFromInline
    static let sha1UsingNil = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha1,
        parameters: nil
    )

    @usableFromInline
    static let sha1 = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha1,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    @usableFromInline
    static let sha256UsingNil = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha256,
        parameters: nil
    )

    @usableFromInline
    static let sha256 = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha256,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    @usableFromInline
    static let sha384UsingNil = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha384,
        parameters: nil
    )

    @usableFromInline
    static let sha384 = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha384,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    @usableFromInline
    static let sha512UsingNil = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha512,
        parameters: nil
    )

    @usableFromInline
    static let sha512 = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha512,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )
}

extension ASN1ObjectIdentifier.AlgorithmIdentifier {
    static let sha1WithRSAEncryption: ASN1ObjectIdentifier = [1, 2, 840, 113_549, 1, 1, 5]

    static let sha1: ASN1ObjectIdentifier = [1, 3, 14, 3, 2, 26]

    static let sha256: ASN1ObjectIdentifier = [2, 16, 840, 1, 101, 3, 4, 2, 1]

    static let sha384: ASN1ObjectIdentifier = [2, 16, 840, 1, 101, 3, 4, 2, 2]

    static let sha512: ASN1ObjectIdentifier = [2, 16, 840, 1, 101, 3, 4, 2, 3]
}
