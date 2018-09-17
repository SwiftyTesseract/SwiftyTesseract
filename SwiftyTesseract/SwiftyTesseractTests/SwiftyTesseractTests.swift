//
//  SwiftyTesseractTests.swift
//  SwiftyTesseractTests
//
//  Created by Steven Sherry on 2/28/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import XCTest
import SwiftyTesseract

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
    print(swiftyTesseract.version!)
    XCTAssertNotNil(swiftyTesseract.version)
  }
  
  func testReturnStringTestImage() {
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle)
    guard let image = UIImage(named: "image_sample.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }
    let answer = "1234567890"
    
    swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else {
        XCTFail("String is nil")
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
        XCTFail("String is nil")
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
        XCTFail("String is nil")
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
        XCTFail("String is nil")
        return
      }
      XCTAssertFalse(string.contains("2") && string.contains("1"))
    }

  }
  
  func testMultipleLanguages() {
    swiftyTesseract = SwiftyTesseract(languages: [.english, .french], bundle: bundle, engineMode: .tesseractOnly)
    let answer = """
    Lenore
    Lenore, Lenore, mon amour
    Every day I love you more
    Without you, my heart grows sore
    Je te aime encore très beauCoup, Lenore
    Lenore, Lenore, don’t think me a bore
    But I can go on and on about your charms
    forever and ever more
    On a scale of one to three, I love you four
    Mon amour, je te aime encore trés beaucoup,
    Lenore
    """
    guard let image = UIImage(named: "Lenore3.png", in: bundle, compatibleWith: nil) else { fatalError() }
    swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else {
        XCTFail("String is nil")
        return
      }
      
      XCTAssertEqual(answer.trimmingCharacters(in: .whitespacesAndNewlines), string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
  func testWithNoImage() {
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle, engineMode: .tesseractOnly)
    let image = UIImage()
    swiftyTesseract.performOCR(on: image) { string in
      XCTAssertNil(string)
    }
  }
  
  func testWithCustomLanguage() {
    guard let image = UIImage(named: "MVRCode3.png", in: bundle, compatibleWith: nil) else { fatalError() }
    swiftyTesseract = SwiftyTesseract(language: .custom("OCRB"), bundle: bundle, engineMode: .tesseractOnly)
    let answer = """
    P<GRCELLINAS<<GEORGIOS<<<<<<<<<<<<<<<<<<<<<<
    AE00000057GRC6504049M1208283<<<<<<<<<<<<<<00
    """
    swiftyTesseract.performOCR(on: image) { string in
      guard let string = string else {
        XCTFail("String is nil")
        return
      }
      
      XCTAssertEqual(answer.trimmingCharacters(in: .whitespacesAndNewlines), string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
  }
  
  func testLoadingStandardAndCustomLanguages() {
    // This test would otherwise crash if it was unable to load both languages
    swiftyTesseract = SwiftyTesseract(languages: [.custom("OCRB"), .english], bundle: bundle)
    XCTAssert(true)
  }
  
  func testMultipleThreads() {
    let bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(language: .english, bundle: bundle)
    guard let image = UIImage(named: "image_sample.jpg", in: Bundle(for: self.classForCoder), compatibleWith: nil) else { fatalError() }

    /*
     `measure` is used because it runs a given closure 10 times. If performOCR(on:completionHandler:) was not thread safe,
     there would be failures & crashes in various tests.
    */
    measure {
      DispatchQueue.global(qos: .userInitiated).async {
        self.swiftyTesseract.performOCR(on: image) { string in
          XCTAssertNotNil(string)
        }
      }
    }
    
    swiftyTesseract = nil
  
  }

}
