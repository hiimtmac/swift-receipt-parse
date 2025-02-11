// ParseTests.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation
import Testing
@testable import Parse

@Suite
struct ParseTests {
    @Test
    func testExample() throws {
        let url = Bundle.module.url(forResource: "receipt", withExtension: nil)!
        let data = try Data(contentsOf: url)
        let base64 = Data(base64Encoded: data)!

        #expect(throws: Never.self) {
            try ReceiptParser.parse(from: base64)
        }
    }
}
