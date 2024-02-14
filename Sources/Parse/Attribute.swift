import Foundation
import SwiftASN1

@usableFromInline
struct Attribute: DERParseable {
    @usableFromInline
    var type: Int
    
    @usableFromInline
    var version: Int

    @usableFromInline
    var value: ASN1OctetString

    @inlinable
    init(
        type: Int,
        version: Int,
        value: ASN1OctetString
    ) {
        self.type = type
        self.version = version
        self.value = value
    }
    
    @inlinable
    init(derEncoded rootNode: ASN1Node) throws {
        self = try DER.sequence(rootNode, identifier: .sequence) { nodes in
            let type = try Int(derEncoded: &nodes)
            let version = try Int(derEncoded: &nodes)
            let value = try ASN1OctetString(derEncoded: &nodes)
            
            return .init(type: type, version: version, value: value)
        }
    }
}

extension Array where Element == Attribute {
    @inlinable
    subscript(type: Int) -> Attribute? {
        if let attr = self.first(where: { $0.type == type }) {
            return attr
        }
        return nil
    }
    
    @inlinable
    subscript(all type: Int) -> [Attribute] {
        self.filter { $0.type == type }
    }
}

extension DateFormatter {
    @usableFromInline
    static let rfc3339: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        f.timeZone = .init(abbreviation: "UTC")
        return f
    }()
}
