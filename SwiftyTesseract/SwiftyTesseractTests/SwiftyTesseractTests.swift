//
//  SwiftyTesseractTests.swift
//  SwiftyTesseractTests
//
//  Created by Steven Sherry on 2/28/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import XCTest
@testable import SwiftyTesseract

/// Must be tested with legacy tessdata to verify results for `EngineMode.tesseractOnly`
class SwiftyTesseractTests: XCTestCase {
  
  var swiftyTesseract: SwiftyTesseract!
  
  override func setUp() {
      super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
    swiftyTesseract = nil
  }
    
  func testVersion() {
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle)
    XCTAssertEqual("4.00.00alpha", swiftyTesseract.version!)
  }
  
  func testReturnStringTestImage() {
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle)
    guard let image = UIImage(named: "image_sample.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "1234567890"
    try? swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else { return }
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
  func testRealImage() {
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = try! SwiftyTesseract(language: .english, bundle: bundle)
    guard let image = UIImage(named: "IMG_1108.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "2F.SM.LC.SCA.12FT"
    try? swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else { return }
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
  func testRealImage_withWhiteList() {
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle, engineMode: .tesseractOnly)
    swiftyTesseract.whiteList = "ABCDEFGHIJKLMNOPQRSTUVWXYZ."
    guard let image = UIImage(named: "IMG_1108.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "ZF.SM.LC.SCAJZFT"
    
    try? swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else { return }
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
  func testRealImage_withBlackList() {
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle, engineMode: .tesseractOnly)
    swiftyTesseract.blackList = "0123456789"
    guard let image = UIImage(named: "IMG_1108.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "Z‘F.SM.LC.SCA.lZF|'"
    
    try? swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else { return }
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
  func testWithNoImage() {
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle)
    let image = UIImage()
    XCTAssertThrowsError(try swiftyTesseract.performOCR(on: image) { $0 })
  }
}
