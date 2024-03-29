// ParseTests.swift
// Copyright (c) 2024 hiimtmac inc.

import XCTest
@testable import Parse

final class ParseTests: XCTestCase {
    func testExample() throws {
        let url = Bundle.module.url(forResource: "receipt", withExtension: nil)!
        let data = try Data(contentsOf: url)
        let base64 = Data(base64Encoded: data)!

        XCTAssertNoThrow(try ReceiptParser.parse(from: base64))
    }
}
