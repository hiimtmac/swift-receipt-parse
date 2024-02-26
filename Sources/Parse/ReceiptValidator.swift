import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(CryptoKit)
import CryptoKit
#endif

public enum ReceiptValidator {
    public static func validate(receipt: Receipt) throws {
        try verifyTrustChain()
        try verifyBundleIdentifier(id: receipt.bundleIdentifier)
        try verifyVersionIdentifier(version: receipt.appVersion)
        try verifySHA1Hash(sha: receipt.sha1Hash)
    }
    
    static func verifyTrustChain() throws {
        
    }
    
    static func verifyBundleIdentifier(id: String) throws {
        guard
            let bundleIdentifier = Bundle.main.bundleIdentifier,
            id == bundleIdentifier
        else {
            throw Error.bundleIdentifier
        }
    }
    
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
    
    static func verifySHA1Hash(sha: String) throws {
        #if canImport(UIKit) && canImport(CryptoKit)
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
        // https://developer.apple.com/documentation/appstorereceipts/validating_receipts_on_the_device#3744656
        throw Error.unsupportedOS
        #endif
    }
    
    enum Error: Swift.Error, LocalizedError {
        case bundleIdentifier
        case appVersion
        case sha1Hash
        case unsupportedOS
    }
}
