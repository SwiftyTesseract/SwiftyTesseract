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
  var bundle: Bundle!
  
  override func setUp() {
    super.setUp()
    bundle = Bundle(for: self.classForCoder)
  }
  
  override func tearDown() {
    super.tearDown()
    swiftyTesseract = nil
  }
    
  func testVersion() {
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle)
    XCTAssertNotNil(swiftyTesseract.version)
  }
  
  func testReturnStringTestImage() {
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle)
    guard let image = UIImage(named: "image_sample.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "1234567890"
    
    swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else {
        XCTFail()
        return
      }
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }

  }
  
  func testRealImage() {
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle)
    guard let image = UIImage(named: "IMG_1108.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "2F.SM.LC.SCA.12FT"

    swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else {
        XCTFail()
        return
      }
      XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    }

  }
  
  func testRealImage_withWhiteList() {
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle, engineMode: .tesseractOnly)
    swiftyTesseract.whiteList = "ABCDEFGHIJKLMNOPQRSTUVWXYZ."
    guard let image = UIImage(named: "IMG_1108.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    
    swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else {
        XCTFail()
        return
      }
      XCTAssertFalse(string.contains("2") && string.contains("1"))
    }

  }
  
  func testRealImage_withBlackList() {
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle, engineMode: .tesseractOnly)
    swiftyTesseract.blackList = "0123456789"
    guard let image = UIImage(named: "IMG_1108.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    
    swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else {
        XCTFail()
        return
      }
      XCTAssertFalse(string.contains("2") && string.contains("1"))
    }

  }
  
  func testWithNoImage() {
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle)
    let image = UIImage()
    swiftyTesseract.performOCR(on: image) { string in
      XCTAssertNil(string)
    }
  }
}
