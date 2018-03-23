//
//  RecognitionLanguageTests.swift
//  SwiftyTesseractTests
//
//  Created by Steven Sherry on 3/22/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import XCTest
@testable import SwiftyTesseract

class RecognitionLanguageTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testRecognitionLanugageString_withMultipleLangues() {
    let languages: [RecognitionLanguage] = [.english, .french, .italian]
    let languagesString = RecognitionLanguage.createLanguageString(from: languages)
    XCTAssertEqual(languagesString, "eng+fra+ita")
  }
  
  func testRecognitionLanguageString_withOneLanguage() {
    let language: [RecognitionLanguage] = [.english]
    let languageString = RecognitionLanguage.createLanguageString(from: language)
    XCTAssertEqual(languageString, "eng")
  }
  
}
