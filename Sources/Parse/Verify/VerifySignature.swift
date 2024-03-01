// VerifySignature.swift
// Copyright (c) 2024 hiimtmac inc.

import _CryptoExtras
import Crypto
import Foundation
import X509

extension ReceiptValidator {
    static func verifySignature(
        certificate: Certificate,
        content: ArraySlice<UInt8>,
        signature: ArraySlice<UInt8>
    ) throws {
        guard let key = _RSA.Signing.PublicKey(certificate.publicKey) else {
            throw Error.signature("Create public key")
        }
        let signature = _RSA.Signing.RSASignature(rawRepresentation: signature)
        let digest = SHA256.hash(data: content)
        let padding = _RSA.Signing.Padding.insecurePKCS1v1_5

        guard key.isValidSignature(signature, for: digest, padding: padding) else {
            throw Error.signature("Invalid signature")
        }
    }
}
