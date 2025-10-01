// EN: Basic test file for ShotCast
// DE: Basis-Testdatei für ShotCast

import XCTest
import SwiftUI
@testable import ShotCast

final class ShotCastTests: XCTestCase {
    
    // EN: Test ItemType file extension detection
    // DE: Test ItemType Dateierweiterungs-Erkennung
    func testItemTypeFromFileExtension() {
        XCTAssertEqual(ItemType.from(fileExtension: "jpg"), .image)
        XCTAssertEqual(ItemType.from(fileExtension: "pdf"), .pdf)
        XCTAssertEqual(ItemType.from(fileExtension: "swift"), .code)
        XCTAssertEqual(ItemType.from(fileExtension: "mp3"), .audio)
        XCTAssertEqual(ItemType.from(fileExtension: "zip"), .archive)
        XCTAssertEqual(ItemType.from(fileExtension: "unknown"), .file)
    }
    
    // EN: Test Color hex initialization
    // DE: Test Farb-Hex-Initialisierung
    func testColorHexInit() {
        let blue = Color(hex: "#007AFF")
        XCTAssertNotNil(blue)
        
        let red = Color(hex: "FF0000")
        XCTAssertNotNil(red)
    }
}