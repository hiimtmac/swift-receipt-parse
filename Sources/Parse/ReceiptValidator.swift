// ReceiptValidator.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation
import SwiftASN1
import X509

extension ASN1ObjectIdentifier {
    /// Cryptographic Message Syntax (CMS) Data.
    ///
    /// ASN.1 definition:
    /// ```
    /// id-data OBJECT IDENTIFIER ::= { iso(1) member-body(2)
    ///    us(840) rsadsi(113549) pkcs(1) pkcs7(7) 1 }
    /// ```
    @usableFromInline
    static let cmsData: ASN1ObjectIdentifier = [1, 2, 840, 113_549, 1, 7, 1]
}

public enum ReceiptValidator {
    public static func validate(
        receiptCreationDate: Date,
        bundleIdentifier: String,
        appVersion: String,
        sha1Hash: String,
        data: Data
    ) async throws {
        try await verifyTrustChain(
            data: data,
            creationDate: receiptCreationDate
        )
        try verifyBundleIdentifier(id: bundleIdentifier)
        try verifyVersionIdentifier(version: appVersion)
        try verifySHA1Hash(sha: sha1Hash)
    }

    // https://developer.apple.com/documentation/appstorereceipts/validating_receipts_on_the_device#4180978
    static func verifyTrustChain(
        data: Data,
        creationDate: Date
    ) async throws {
        let decodedCMSContentInfo = Array(data)
        let derParse = try DER.parse(decodedCMSContentInfo)
        let cmsContentInfo = try CMSContentInfo(derEncoded: derParse)
        let signedData = try CMSSignedData(asn1Any: cmsContentInfo.content)

        guard signedData.version == .v1 else {
            throw Error.signature("Only v1 is supported")
        }

        guard signedData.signerInfos.count == 1 else {
            throw Error.signature("Too many signatures")
        }

        guard 
            signedData.encapContentInfo.eContentType == .cmsData,
            signedData.signerInfos.allSatisfy({ $0.version == .v1 })
        else {
            throw Error.signature("Invalid v1 signed data")
        }

        // This subscript is safe, we confirmed a count of 1 above.
        let signer = signedData.signerInfos[0]

        guard signedData.digestAlgorithms.contains(signer.digestAlgorithm) else {
            throw Error.signature("Digest algorithm mismatch")
        }

        guard let signingCert = try signedData.certificates?.certificate(signerInfo: signer) else {
            throw Error.signature("Unable to locate signing certificate")
        }

        guard let eContent = signedData.encapContentInfo.eContent else {
            throw Error.signature("Missing content")
        }

        try verifySignature(
            certificate: signingCert,
            content: eContent.bytes,
            signature: signer.signature.bytes
        )

        // Ok, the signature was signed by the private key associated with this cert. Now we need to validate the certificate.
        // This force-unwrap is safe: we know there are certificates because we've located at least one certificate from this set!
        try await verifyTrust(
            intermediateCertificates: signedData.certificates!,
            signingCertificate: signingCert,
            creationDate: creationDate
        )
    }

    enum Error: Swift.Error, LocalizedError {
        case bundleIdentifier
        case appVersion
        case sha1Hash
        case signature(String)
        case trust(String)
        case unsupportedOS

        var errorDescription: String? {
            switch self {
            case .bundleIdentifier: "Invalid bundle identifier"
            case .appVersion: "Invalid app version"
            case .sha1Hash: "Invalid SHA1 hash"
            case let .signature(string): "Signature: \(string)"
            case let .trust(string): "Trust: \(string)"
            case .unsupportedOS: "Unsupported OS"
            }
        }
    }
}

extension Array where Element == Certificate {
    func certificate(signerInfo: CMSSignerInfo) throws -> Certificate? {
        switch signerInfo.signerIdentifier {
        case let .issuerAndSerialNumber(issuerAndSerialNumber):
            self.first { cert in
                cert.issuer == issuerAndSerialNumber.issuer && cert.serialNumber == issuerAndSerialNumber.serialNumber
            }
        case let .subjectKeyIdentifier(subjectKeyIdentifier):
            self.first { cert in
                (try? cert.extensions.subjectKeyIdentifier)?.keyIdentifier == subjectKeyIdentifier.keyIdentifier
            }
        }
    }
}
