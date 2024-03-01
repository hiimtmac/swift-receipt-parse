// ValidateTests.swift
// Copyright (c) 2024 hiimtmac inc.

import XCTest
@testable import Parse

final class ValidateTests: XCTestCase {
    func testExample() async throws {
        let url = Bundle.module.url(forResource: "receipt", withExtension: nil)!
        let data = try Data(contentsOf: url)
        let base64 = Data(base64Encoded: data)!

        let receipt = try ReceiptParser.parse(from: base64)

        try await ReceiptValidator.verifyTrustChain(
            data: base64,
            creationDate: receipt.receiptCreationDate
        )
    }
}
