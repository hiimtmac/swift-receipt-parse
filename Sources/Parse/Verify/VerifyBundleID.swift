// VerifyBundleID.swift
// Copyright (c) 2026 hiimtmac inc.

import class Foundation.Bundle

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
