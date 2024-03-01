// VerifyBundleID.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation

extension ReceiptValidator {
    static func verifyBundleIdentifier(id: String) throws {
        guard
            let bundleIdentifier = Bundle.main.bundleIdentifier,
            id == bundleIdentifier
        else {
            throw Error.bundleIdentifier
        }
    }
}
