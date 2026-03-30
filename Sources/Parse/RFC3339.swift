// RFC3339.swift
// Copyright (c) 2026 hiimtmac inc.

public import struct Foundation.Date
public import protocol Foundation.ParseStrategy
public import SwiftASN1

// https://mjtsai.com/blog/2020/10/08/date-format-change-in-app-store-receipts/
@usableFromInline
struct RFC3339ParseStrategy: ParseStrategy {
    @usableFromInline
    func parse(_ value: String) throws -> Date {
        do {
            let parser = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
            return try parser.parse(value)
        } catch {
            let parser = Date.ISO8601FormatStyle(includingFractionalSeconds: false)
            return try parser.parse(value)
        }
    }
}

extension ParseStrategy where Self == RFC3339ParseStrategy {
    @usableFromInline
    static var rfc3339: Self { .init() }
}

extension Date {
    @inlinable
    init?(_ attribute: Attribute) throws {
        let ia5 = try ASN1IA5String(derEncoded: attribute.value.bytes)
        guard !ia5.bytes.isEmpty else { return nil }
        let string = String(ia5)
        self = try Date(string, strategy: .rfc3339)
    }
}
