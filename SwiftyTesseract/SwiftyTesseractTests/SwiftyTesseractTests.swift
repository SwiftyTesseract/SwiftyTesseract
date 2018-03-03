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
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(bundle: bundle)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    swiftyTesseract = nil
  }
    
  func testVersion() {
    XCTAssertEqual("4.00.00alpha", swiftyTesseract.version!)
  }
  
  func testTesseractSuccesfullyInitialized() {
    XCTAssertEqual(0, swiftyTesseract.apiReturnCode)
  }
  
  func testReturnStringTestImage() {
    guard let image = UIImage(named: "image_sample.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "1234567890"
    swiftyTesseract.performOCR(from: image) { string in
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
  func testReturnImageWithBlacklist() {
    guard let image = UIImage(named: "IMG_1108.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "2F.SM.LC.SCA.12FT"
    swiftyTesseract.blackList = CharacterGroup.specialCharacters.filterOut(".")
    swiftyTesseract.performOCR(from: image) { string in
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
  func testReturnImageWithWhiteList() {
    guard let image = UIImage(named: "IMG_1108.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "2FSMLCSCA12FT"
    swiftyTesseract.whiteList = CharacterGroup.uppercase.rawValue.appending(.numbers)
    swiftyTesseract.performOCR(from: image) { string in
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
  func testReturnImageWithBlackAndWhiteList() {
    guard let image = UIImage(named: "IMG_1108.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "FSMLCSCA1FT"
    swiftyTesseract.blackList = "2'"
    swiftyTesseract.whiteList = CharacterGroup.uppercase.rawValue.appending(.numbers)
    swiftyTesseract.performOCR(from: image) { string in
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
}
