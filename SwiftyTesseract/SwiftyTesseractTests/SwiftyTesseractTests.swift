//
//  SwiftyTesseractTests.swift
//  SwiftyTesseractTests
//
//  Created by Steven Sherry on 2/28/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import XCTest
import SwiftyTesseract
import PDFKit
import Combine

/// Must be tested with legacy tessdata to verify results for `EngineMode.tesseractOnly`
class SwiftyTesseractTests: XCTestCase {
  
  var swiftyTesseract: SwiftyTesseract!
  var bundle: Bundle!
  var cancellables: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    bundle = Bundle(for: self.classForCoder)
    swiftyTesseract = SwiftyTesseract(language: .english, dataSource: bundle)
    cancellables = Set()
  }
  
  override func tearDown() {
    super.tearDown()
    swiftyTesseract = nil
    cancellables = nil
  }
    
  func testVersion() {
    print(swiftyTesseract.version!)
    XCTAssertNotNil(swiftyTesseract.version)
  }
  
  func testReturnStringTestImage() {
    let image = getImage(named: "image_sample.jpg")
    let answer = "1234567890"
    
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
    
  }

  func testBlockIterator() {
    let image = getImage(named: "image_sample.jpg")
    let answer = "1234567890"

    guard case .success(_) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    guard case let .success(blocks) = swiftyTesseract.recognizedBlocks(for: .symbol) else { return XCTFail("Failed getting iterator") }
    XCTAssertEqual(answer.count, blocks.count)
    XCTAssertEqual(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"], blocks.map(\.text))


    guard case .success(let wordBlocks) = swiftyTesseract.recognizedBlocks(for: .word) else { return XCTFail("Failed getting iterator") }
    XCTAssertEqual(1, wordBlocks.count)
    XCTAssertEqual(answer, wordBlocks.first!.text)
  }
  
  func testBlockIteratorFailsWhenOCRHasNotYetBeenPerformed() {
    guard case .failure = swiftyTesseract.recognizedBlocks(for: .symbol) else { return XCTFail("Iterator should not have been received") }
  }
  
  func testRealImage() {
    let image = getImage(named: "IMG_1108.jpg")
    let answer = "2F.SM.LC.SCA.12FT"

    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func testRealImage_withWhiteList() {
    swiftyTesseract.whiteList = "ABCDEFGHIJKLMNOPQRSTUVWXYZ."
    let image = getImage(named: "IMG_1108.jpg")
    
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertFalse(string.contains("2") && string.contains("1"))
  }
  
  func testRealImage_withBlackList() {
    swiftyTesseract.blackList = "0123456789"
    let image = getImage(named: "IMG_1108.jpg")
    
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertFalse(string.contains("2") && string.contains("1"))
  }
    
  func testMultipleSpacesImage_withPreserveMultipleSpaces() {
    swiftyTesseract = SwiftyTesseract(language: .english, dataSource: bundle, engineMode: .tesseractOnly)
    swiftyTesseract.preserveInterwordSpaces = true
    let image = getImage(named: "MultipleInterwordSpaces.jpg")
    
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertTrue(string.contains("  "))
  }
  
  func testNormalAndSmallFontsImage_withMinimumCharacterHeight() {
    swiftyTesseract.minimumCharacterHeight = 15
    let image = getImage(named: "NormalAndSmallFonts.jpg")
    
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(string.trimmingCharacters(in: .whitespacesAndNewlines), "21.02.2012")
  }
  
  func testMultipleLanguages() {
    swiftyTesseract = SwiftyTesseract(languages: [.english, .french], dataSource: bundle, engineMode: .tesseractOnly)
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
    let image = getImage(named: "Lenore3.png")
    
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(answer.trimmingCharacters(in: .whitespacesAndNewlines), string.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func testWithNoImage() {
    let image = UIImage()
    guard case let .failure(error) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR should have failed") }
    XCTAssertEqual(error as! SwiftyTesseract.Error, SwiftyTesseract.Error.imageConversionError)
  }
  
  func testWithCustomLanguage() {
    let image = getImage(named: "MVRCode3.png")
    swiftyTesseract = SwiftyTesseract(language: .custom("OCRB"), dataSource: bundle, engineMode: .tesseractOnly)
    let answer = """
    P<GRCELLINAS<<GEORGIOS<<<<<<<<<<<<<<<<<<<<<<
    AE00000057GRC6504049M1208283<<<<<<<<<<<<<<00
    """
    
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(answer.trimmingCharacters(in: .whitespacesAndNewlines), string.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func testLoadingStandardAndCustomLanguages() {
    // This test would otherwise crash if it was unable to load both languages
    swiftyTesseract = SwiftyTesseract(languages: [.custom("OCRB"), .english], dataSource: bundle)
  }
  
  // This really more or less exists purely to show how to perform OCR on a background thread
  func testSuccessPublisher() {
    let expect = expectation(description: "ocr expectation")
    
    swiftyTesseract.performOCRPublisher(on: getImage(named: "image_sample.jpg"))
      .subscribe(on: DispatchQueue.global(qos: .background))
      .receive(on: DispatchQueue.main)
      .assertNoFailure()
      .sink { string in
        XCTAssertEqual("1234567890", string.trimmingCharacters(in: .whitespacesAndNewlines))
        expect.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [expect], timeout: 5.0)
  }
  
  func testFailurePublisher() {
    swiftyTesseract.performOCRPublisher(on: UIImage())
      .sink(
        receiveCompletion: { completion in
          if case .finished = completion { XCTFail("Should have failed") }
        },
        receiveValue: { _ in XCTFail("Should have failed") }
      )
      .store(in: &cancellables)
  }
  
  func testMultipleThreads() {
    let image = getImage(named: "image_sample.jpg")

    /*
     `measure` is used because it runs a given closure 10 times. If performOCR(on:completionHandler:) was not thread safe,
     there would be failures & crashes in various tests.
    */
    measure {
      DispatchQueue.global(qos: .userInitiated).async {
        guard case .success = self.swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR Failed") }
      }
    }
    
    swiftyTesseract = nil
  
  }

  func testPDFSinglePage() throws {
    let image = getImage(named: "image_sample.jpg")
    
    let data = try swiftyTesseract.createPDF(from: [image])
    
    let document = PDFDocument(data: data)
    XCTAssertNotNil(document)
    XCTAssertEqual(document?.string, "1234567890\n ")
  }
  
  func testPDFMultiplePages() throws {
    let image = getImage(named: "image_sample.jpg")
    
    let data = try swiftyTesseract.createPDF(from: [image, image, image])
    
    let document = PDFDocument(data: data)
    XCTAssertNotNil(document)
    XCTAssertTrue(document?.string?.contains("1234567890") ?? false)
  }

  func testDataSourceFromFiles() {
    // Move data from bundle to documents directory /tessdata
    guard let documentsFolder = try? FileManager.default.url(for: .documentDirectory,
                                                         in: .userDomainMask,
                                                         appropriateFor: nil,
                                                         create: false) else { return XCTFail() }
    // this directory will contain our traineddata and is what we will pass to the data source
    let tessData = documentsFolder.appendingPathComponent("tessdata")

    try? FileManager.default.createDirectory(at: tessData, withIntermediateDirectories: true, attributes: nil)
    
    // Copy the english training data file from he test applicatinon bundle and copy it to the user documents directory
    if let path = bundle.url(forResource: "eng", withExtension: "traineddata", subdirectory: "tessdata") {
        try? FileManager.default.copyItem(at: path, to: tessData.appendingPathComponent("eng.traineddata"))
    }

    // setup the data source class
    struct MyDataSource: LanguageModelDataSource {
        let pathToTrainedData: String
    }

    let dataSource = MyDataSource(pathToTrainedData: tessData.path)

    // init the wrapper class using our custom data source.
    let swt = SwiftyTesseract(language: .english, dataSource: dataSource)

    // test it
    let image = getImage(named: "IMG_1108.jpg")
    let answer = "2F.SM.LC.SCA.12FT"

    guard case let .success(string) = swt.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func getImage(named name: String) -> UIImage {
    UIImage(named: name, in: Bundle(for: self.classForCoder), compatibleWith: nil)!
  }
}
