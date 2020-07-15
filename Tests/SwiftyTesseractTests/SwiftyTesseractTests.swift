import XCTest
@testable import SwiftyTesseract

#if canImport(Combine)
import Combine
#endif

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

final class SwiftyTesseractTests: XCTestCase {
  
  var swiftyTesseract: SwiftyTesseract!
  
  override func setUp() {
    swiftyTesseract = SwiftyTesseract(language: .english, dataSource: Bundle.module)
  }
  
  override func tearDown() {
    swiftyTesseract = nil
  }
  
  func testVersion() {
    print(swiftyTesseract.version!)
    
    XCTAssertNotNil(swiftyTesseract.version)
  }
  
  func testReturnStringTestImage() {
    let image = getImageData(named: "image_sample", ofType: "jpg")
    let answer = "1234567890"
    
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else {
      return XCTFail("OCR was unsuccessful")
    }
    
    XCTAssertEqual(answer, string.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func testRealImage_withWhitelist() {
    swiftyTesseract = SwiftyTesseract(language: .english, dataSource: Bundle.module) {
      set(.whitelist, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ.")
    }
    
    let image = getImageData(named: "IMG_1108", ofType: "jpg")
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccesful") }
    print("Whitelist result: \(string)")
    XCTAssertFalse(string.contains("2") || string.contains("1"))
  }
  
  func testRealImage_withBlacklist() {
    swiftyTesseract = SwiftyTesseract(language: .english, dataSource: Bundle.module) {
      set(.blacklist, value: "0123456789")
    }
    
    let image = getImageData(named: "IMG_1108", ofType: "jpg")
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccesful") }
    print("Blacklist result: \(string)")
    XCTAssertFalse(string.contains("2") || string.contains("1"))
  }
  
  func testMultipleSpacesImage_withPreserveMultipleSpaces() {
    swiftyTesseract = SwiftyTesseract(language: .english, dataSource: Bundle.module) {
      set(.preserveInterwordSpaces, value: .true)
    }
    
    let image = getImageData(named: "MultipleInterwordSpaces", ofType: "png")
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    
    XCTAssertTrue(string.contains("  "))
  }
  
  func testNormalAndSmallFontsImage_withMinimumharacterHeight() {
    swiftyTesseract = SwiftyTesseract(language: .english, dataSource: Bundle.module) {
      set(.minimumCharacterHeight, value: .integer(25))
    }
    
    let image = getImageData(named: "NormalAndSmallFonts", ofType: "jpg")
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(string.trimmingCharacters(in: .whitespacesAndNewlines), "21.02.2012")
  }
  
  func testMultipleLanguages() {
    swiftyTesseract = SwiftyTesseract(languages: [.english, .french], dataSource: Bundle.module) {
      set(.blacklist, value: "|")
    }
    let answer = """
    Lenore
    Lenore, Lenore, mon amour
    Every day I love you more
    Without you, my heart grows sore
    Je te aime encore tres beaucoup, Lenore
    Lenore, Lenore, don‘t think me a bore
    But I can go on and on about your charms
    forever and ever more
    On a scale of one to three, I love you four
    Mon amour, je te aime encore tres beaucoup,
    Lenore
    """
    let image = getImageData(named: "Lenore3", ofType: "png")
        
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(answer.trimmingCharacters(in: .whitespacesAndNewlines), string.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func testWithNoImage() {
    let image = Data()
    guard case let .failure(error) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR should have failed") }
    XCTAssertEqual(error as! SwiftyTesseract.Error, SwiftyTesseract.Error.unableToExtractTextFromImage)
  }
  
  func testWithCustomLanguage() {
    swiftyTesseract = SwiftyTesseract(language: .custom("OCRB"), dataSource: Bundle.module)
    
    let image = getImageData(named: "MVRCode3", ofType: "png")
    let answer = """
    P<GRCELLINAS<<GEORGIOS<<<<<<<<<<<<<<<<<<<<<<
    AE00000057GRC6504049M1208283<<<<<<<<<<<<<<00
    """
        
    guard case let .success(string) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(answer.trimmingCharacters(in: .whitespacesAndNewlines), string.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
//  #if canImport(Combine)
  @available(iOS 13.0, OSX 10.15, *)
  func testSuccessPublisher() {
    let expect = expectation(description: "ocr expectation")
    var cancellables = Set<AnyCancellable>()
    
    swiftyTesseract.performOCRPublisher(on: getImageData(named: "image_sample", ofType: "jpg"))
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
  
  @available(iOS 13.0, OSX 10.15, *)
  func testFailurePublisher() {
    var cancellables = Set<AnyCancellable>()
    
    swiftyTesseract.performOCRPublisher(on: Data())
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .finished:
            XCTFail("OCR should have failed")
          case .failure(let error):

            XCTAssertEqual(error as! SwiftyTesseract.Error, SwiftyTesseract.Error.unableToExtractTextFromImage)
          }
        },
        receiveValue: { _ in XCTFail("OCR should have failed") }
      )
      .store(in: &cancellables)
  }
//  #endif

  func getImageData(named name: String, ofType type: String) -> Data {
    let imagePath = Bundle.module.url(forResource: name, withExtension: type, subdirectory: "images")
    let data = try! Data(contentsOf: imagePath!)
    return data
  }
  
  
  static var allTests = [
    ("testVersion", testVersion),
    ("testReturnStringTestImage", testReturnStringTestImage)
  ]
}
