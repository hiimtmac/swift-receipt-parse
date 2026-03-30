// ParseTests.swift
// Copyright (c) 2024 hiimtmac inc.

import Foundation
import Testing
@testable import Parse

@Suite
struct ParseTests {
    @Test
    func testExample() throws {
        let url = Bundle.module.url(forResource: "receipt", withExtension: nil)!
        let data = try Data(contentsOf: url)
        let base64 = Data(base64Encoded: data)!

        let parsed = try ReceiptParser.parse(from: base64)
        #expect(parsed.appVersion == "19782")
        #expect(parsed.sha1Hash == "34f4f3905b994a483228399bf11aa849bea84013")
        #expect(parsed.originalApplicationVersion == "1.0")
        #expect(parsed.receiptCreationDate.timeIntervalSince1970 == 1707921232)
        #expect(parsed.receiptExpirationDate == nil)
        
        testReceipt(parsed.inAppPurchaseReceipts[0]) { receipt in
            #expect(receipt.transactionIdentifier == "2000000520090992")
            #expect(receipt.originalTransactionIdentifier == "2000000472061161")
            #expect(receipt.purchaseDate.timeIntervalSince1970 == 1707422588)
            #expect(receipt.originalPurchaseDate.timeIntervalSince1970 == 1701714004)
            #expect(receipt.subscriptionExpirationDate?.timeIntervalSince1970 == 1707422888)
            #expect(receipt.webOrderLineItemID == 2000000051047480)
        }
        
        testReceipt(parsed.inAppPurchaseReceipts[1]) { receipt in
            #expect(receipt.transactionIdentifier == "2000000523296772")
            #expect(receipt.originalTransactionIdentifier == "2000000522947832")
            #expect(receipt.purchaseDate.timeIntervalSince1970 == 1707874484)
            #expect(receipt.originalPurchaseDate.timeIntervalSince1970 == 1707834825)
            #expect(receipt.subscriptionExpirationDate?.timeIntervalSince1970 == 1707878084)
            #expect(receipt.webOrderLineItemID == 2000000051464412)
        }
        
        testReceipt(parsed.inAppPurchaseReceipts[2]) { receipt in
            #expect(receipt.transactionIdentifier == "2000000473171909")
            #expect(receipt.originalTransactionIdentifier == "2000000473143508")
            #expect(receipt.purchaseDate.timeIntervalSince1970 == 1701835661)
            #expect(receipt.originalPurchaseDate.timeIntervalSince1970 == 1701832158)
            #expect(receipt.subscriptionExpirationDate?.timeIntervalSince1970 == 1701835961)
            #expect(receipt.webOrderLineItemID == 2000000043733019)
        }
        
        testReceipt(parsed.inAppPurchaseReceipts[3]) { receipt in
            #expect(receipt.transactionIdentifier == "2000000473127193")
            #expect(receipt.originalTransactionIdentifier == "2000000473041682")
            #expect(receipt.purchaseDate.timeIntervalSince1970 == 1701830498)
            #expect(receipt.originalPurchaseDate.timeIntervalSince1970 == 1701815045)
            #expect(receipt.subscriptionExpirationDate?.timeIntervalSince1970 == 1701830798)
            #expect(receipt.webOrderLineItemID == 2000000043727703)
        }
    }
    
    func testReceipt(_ receipt: Receipt.InAppPurchaseReceipt, handler: (Receipt.InAppPurchaseReceipt) -> Void) {
        #expect(receipt.cancellationDate == nil)
        #expect(receipt.quantity == 1)
        #expect(receipt.subscriptionIntroductoryPricePeriod == 0)
        handler(receipt)
    }
}
