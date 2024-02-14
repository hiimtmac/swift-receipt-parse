import XCTest
@testable import Parse

final class ParseTests: XCTestCase {
    func testExample() throws {
        let url = Bundle.module.url(forResource: "receipt", withExtension: nil)!
        let data = try Data(contentsOf: url)
        
        XCTAssertNoThrow(try ReceiptParser.parse(from: data))
    }
}
