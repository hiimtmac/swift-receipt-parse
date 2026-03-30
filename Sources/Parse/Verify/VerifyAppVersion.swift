// VerifyAppVersion.swift
// Copyright (c) 2026 hiimtmac inc.

#if Verification
import class Foundation.Bundle

extension ReceiptValidator {
    // This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in macOS) in the Info.plist.
    static func verifyVersionIdentifier(version: String) throws {
        #if os(iOS)
        guard
            let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
            version == appVersion
        else {
            throw Error.appVersion
        }
        #else
        // TODO: support macOS/tvOS/watchOS
        throw Error.unsupportedOS
        #endif
    }
}
#endif
