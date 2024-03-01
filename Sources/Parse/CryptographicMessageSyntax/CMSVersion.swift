// CMSVersion.swift
// Copyright (c) 2024 hiimtmac inc.

import SwiftASN1

/// ``CMPVersion`` is defined in ASN1. as:
/// ```
///  CMSVersion ::= INTEGER
///                 { v0(0), v1(1), v2(2), v3(3), v4(4), v5(5) }
/// ```
@usableFromInline
struct CMSVersion: RawRepresentable, Hashable {
    @usableFromInline
    var rawValue: Int

    @inlinable
    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    @usableFromInline
    static let v0 = Self(rawValue: 0)

    @usableFromInline
    static let v1 = Self(rawValue: 1)

    @usableFromInline
    static let v2 = Self(rawValue: 2)

    @usableFromInline
    static let v3 = Self(rawValue: 3)

    @usableFromInline
    static let v4 = Self(rawValue: 4)

    @usableFromInline
    static let v5 = Self(rawValue: 5)
}
