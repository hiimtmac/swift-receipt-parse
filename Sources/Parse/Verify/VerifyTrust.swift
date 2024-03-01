// VerifyTrust.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation
import X509

extension ReceiptValidator {
    static func verifyTrust(
        intermediateCertificates: [Certificate],
        signingCertificate: Certificate,
        creationDate: Date
    ) async throws {
        guard let url = Bundle.module.url(forResource: "AppleIncRootCertificate", withExtension: "cer") else {
            throw Error.trust("Missing root cert")
        }

        let certData = try Data(contentsOf: url)
        let rootCertificate = try Certificate(derEncoded: Array(certData))
        let trustRoots = CertificateStore([rootCertificate])

        let untrustedIntermediates = CertificateStore(intermediateCertificates)

        var verifier = Verifier(rootCertificates: trustRoots) {
            RFC5280Policy(validationTime: creationDate)
        }

        let result = await verifier.validate(
            leafCertificate: signingCertificate,
            intermediates: untrustedIntermediates
        )

        switch result {
        case .validCertificate: break
        case .couldNotValidate(let policyFailures):
            let reasons = policyFailures
                .map(\.policyFailureReason.description)
                .joined(separator: ", ")
            throw Error.trust("Could not validate: \(reasons)")
        }
    }
}
