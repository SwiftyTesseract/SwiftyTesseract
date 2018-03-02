//
//  SwiftyTesseractTests.swift
//  SwiftyTesseractTests
//
//  Created by Steven Sherry on 2/28/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import XCTest
@testable import SwiftyTesseract

class SwiftyTesseractTests: XCTestCase {
  var swiftyTesseract: SwiftyTesseract!
    override func setUp() {
        super.setUp()
      // Figure out how to get the path to a referenced directory programmatically
      let path = "/Users/stevensherry/Documents/Code/SwiftyTesseract/SwiftyTesseract/SwiftyTesseractTests/tessdata"
      swiftyTesseract = SwiftyTesseract(dataPath: path)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
      
    }
    
  func testVersion() {
    XCTAssertEqual("4.00.00alpha", swiftyTesseract.version!)
  }
  
  func testTesseractSuccesfullyInitialized() {
    XCTAssertEqual(0, swiftyTesseract.apiReturnCode)
  }
  
  func testReturnString() {
    guard let image = UIImage(named: "image_sample.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "1234567890"
    XCTAssertEqual(answer, swiftyTesseract.performOCR(from: image).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
  }
    
}
