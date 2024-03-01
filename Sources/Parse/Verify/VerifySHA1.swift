// VerifySHA1.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import Crypto

extension ReceiptValidator {
    // https://developer.apple.com/documentation/appstorereceipts/validating_receipts_on_the_device#3744656
    static func verifySHA1Hash(sha: String) throws {
        #if canImport(UIKit)
        guard
            let vendorId = UIDevice.current.identifierForVendor
        else {
            throw Error.sha1Hash
        }

        let bytes = withUnsafeBytes(of: vendorId.uuid) { Data.init($0) }
        let sha1Hash = Insecure.SHA1.hash(data: bytes)

        let sha1String = Array(sha1Hash)
            .map { String(format: "%02hhx", $0) }
            .joined()

        guard
            sha1String == sha
        else {
            throw Error.sha1Hash
        }
        #else
        // TODO: support macOS/tvOS/watchOS
        throw Error.unsupportedOS
        #endif
    }
}
