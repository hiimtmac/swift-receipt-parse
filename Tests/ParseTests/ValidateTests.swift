// ValidateTests.swift
// Copyright (c) 2026 hiimtmac inc.

#if Verification
import Foundation
import Testing
@testable import Parse

@Suite
struct ValidationTests {
    @Test
    func testValidate() async throws {
        let url = Bundle.module.url(forResource: "receipt", withExtension: nil)!
        let data = try Data(contentsOf: url)
        let base64 = Data(base64Encoded: data)!

        let receipt = try ReceiptParser.parse(from: Array(base64))

        try await ReceiptValidator.verifyTrustChain(
            data: Array(base64),
            creationDate: receipt.receiptCreationDate
        )
    }
}
#endif
