import XCTest
import SwiftyTesseract

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
  
  var swiftyTesseract: Tesseract!
  
  override func setUp() {
    swiftyTesseract = Tesseract(language: .english, dataSource: Bundle.module)
  }
  
  override func tearDown() {
    swiftyTesseract = nil
  }
  
  // MARK: - Platform Agnostic Tests
  
  func test_OcrReturnsCorrectValue_whenPerformedOnValidImageData() {
    let image = getImageData(named: "image_sample", ofType: "jpg")
    let expected = "1234567890"
    
    guard case let .success(actual) = swiftyTesseract.performOCR(on: image) else {
      return XCTFail("OCR was unsuccessful")
    }
    
    XCTAssertEqual(expected, actual.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func test_OcrDoesNotRecognizeCharactersOutsideOfAllowlist_whenAllowlistIsSet() {
    swiftyTesseract.configure {
      set(.allowlist, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ.")
    }
    
    let image = getImageData(named: "IMG_1108", ofType: "jpg")
    let actual = getString(from: image)
    
    XCTAssertFalse(actual.contains("2") || actual.contains("1"))
  }
  
  func test_OcrDoesNotRecognizeCharactersInDisallowList_whenDisallowlistIsSet() {
    swiftyTesseract.configure {
      set(.disallowlist, value: "0123456789")
    }
    
    let image = getImageData(named: "IMG_1108", ofType: "jpg")
    let actual = getString(from: image)
    XCTAssertFalse(actual.contains("2") || actual.contains("1"))
  }
  
  func test_OcrPreservesMutipleSpaces_whenPreserveInterwordSpacesIsSet() {
    swiftyTesseract.configure {
      set(.preserveInterwordSpaces, value: .true)
    }
    
    let image = getImageData(named: "MultipleInterwordSpaces", ofType: "png")
    let actual = getString(from: image)
    
    XCTAssertTrue(actual.contains("  "))
  }
  
  func test_OcrDoesNotRecognizeCharactersBelowMinimumHeight_whenMinimumCharacterHeightIsSet() {
    swiftyTesseract.configure {
      set(.minimumCharacterHeight, value: .integer(25))
    }
    
    let image = getImageData(named: "NormalAndSmallFonts", ofType: "jpg")
    let actual = getString(from: image)
    XCTAssertEqual(actual.trimmingCharacters(in: .whitespacesAndNewlines), "21.02.2012")
  }
  
  func test_OcrRecognizesMultipleLanguages_whenMultipleLanguagesAreSet() {
    swiftyTesseract = Tesseract(languages: [.english, .french], dataSource: Bundle.module) {
      set(.disallowlist, value: "|")
    }
    let expected = """
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
    let actual = getString(from: image)
    
    XCTAssertEqual(expected.trimmingCharacters(in: .whitespacesAndNewlines), actual.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func test_OcrFails_whenGivenInvalidImageData() {
    let image = Data()
    guard case let .failure(error) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR should have failed") }
    XCTAssertEqual(error, Tesseract.Error.unableToExtractTextFromImage)
  }
  
  func test_OcrRecognizesExpectedValueOfCustomLanguage_whenCustomLanguageIsSet() {
    swiftyTesseract = Tesseract(language: .custom("OCRB"), dataSource: Bundle.module)
    
    let image = getImageData(named: "MVRCode3", ofType: "png")
    let expected = """
    P<GRCELLINAS<<GEORGIOS<<<<<<<<<<<<<<<<<<<<<<
    AE00000057GRC6504049M1208283<<<<<<<<<<<<<<00
    """
        
    guard case let .success(actual) = swiftyTesseract.performOCR(on: image) else { return XCTFail("OCR was unsuccessful") }
    XCTAssertEqual(expected.trimmingCharacters(in: .whitespacesAndNewlines), actual.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func test_recognizedBlocksRunsAsExpected_whenProvidedValidImageData() {
    let image = getImageData(named: "image_sample", ofType: "jpg")
    let expected = "1234567890"
    
    guard case let .success((_, dict)) = swiftyTesseract.recognizedBlocks(from: image, for: [.symbol, .word]) else {
      return XCTFail("Failed getting OCR results and iterator")
    }
    
    XCTAssertEqual(expected.count, dict[.symbol]!.count)
    XCTAssertEqual(expected.map(String.init), dict[.symbol]!.map(\.text))
    XCTAssertEqual(1, dict[.word]!.count)
    XCTAssertEqual(expected, dict[.word]!.first!.text)
    
    guard case let .success((_, actualBlocks0)) = swiftyTesseract.recognizedBlocks(from: image, for: .symbol) else {
      return XCTFail("Failed getting OCR result and iterator")
    }
    
    XCTAssertEqual(expected.count, actualBlocks0.count)
    XCTAssertEqual(expected.map(String.init), actualBlocks0.map(\.text))
    
    guard case let .success((_, actualBlocks1)) = swiftyTesseract.recognizedBlocks(from: image, for: .word) else {
      return XCTFail("Failed getting OCR result and iterator")
    }
    
    XCTAssertEqual(1, actualBlocks1.count)
    XCTAssertEqual(expected, actualBlocks1.first!.text)
  }
  
  // MARK: - Apple Platform Agnostic Combine Tests
  #if canImport(Combine)
  @available(iOS 13.0, OSX 10.15, *)
  func test_OcrPublisherIsSuccessful_whenProvidedValidImageData() {
    var cancellables = Set<AnyCancellable>()
    
    swiftyTesseract.performOCRPublisher(on: getImageData(named: "image_sample", ofType: "jpg"))
      .assertNoFailure()
      .sink { actual in
        XCTAssertEqual("1234567890", actual.trimmingCharacters(in: .whitespacesAndNewlines))
      }
      .store(in: &cancellables)
  }
  
  @available(iOS 13.0, OSX 10.15, *)
  func test_OcrPublisherFails_whenProvidedInvalidImageData() {
    var cancellables = Set<AnyCancellable>()
    
    swiftyTesseract.performOCRPublisher(on: Data())
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .finished:
            XCTFail("OCR should have failed")
          case .failure(let error):
            XCTAssertEqual(error, Tesseract.Error.unableToExtractTextFromImage)
          }
        },
        receiveValue: { _ in XCTFail("OCR should have failed") }
      )
      .store(in: &cancellables)
  }
  #endif
  
  // MARK: - UIKit Specific Tests
  #if canImport(UIKit)
  func test_OcrReturnsCorrectValue_whenPerformedOnUIImage() {
    let image = UIImage(data: getImageData(named: "image_sample", ofType: "jpg"))!
    let expected = "1234567890"
    guard case let .success(actual) = swiftyTesseract.performOCR(on: image) else {
      return XCTFail("OCR was unsuccessful")
    }
    
    XCTAssertEqual(expected, actual.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func test_recognizedBlocksRunsAsExpected_whenPerformedWithUIImage() {
    let image = UIImage(data: getImageData(named: "image_sample", ofType: "jpg"))!
    let expected = "1234567890"
    
    guard case let .success((_, dict)) = swiftyTesseract.recognizedBlocks(from: image, for: [.symbol, .word]) else {
      return XCTFail("Failed getting OCR results and iterator")
    }
    
    XCTAssertEqual(expected.count, dict[.symbol]!.count)
    XCTAssertEqual(expected.map(String.init), dict[.symbol]!.map(\.text))
    XCTAssertEqual(1, dict[.word]!.count)
    XCTAssertEqual(expected, dict[.word]!.first!.text)
    
    guard case let .success((_, actualBlocks0)) = swiftyTesseract.recognizedBlocks(from: image, for: .symbol) else {
      return XCTFail("Failed getting OCR result and iterator")
    }
    
    XCTAssertEqual(expected.count, actualBlocks0.count)
    XCTAssertEqual(expected.map(String.init), actualBlocks0.map(\.text))
    
    guard case let .success((_, actualBlocks1)) = swiftyTesseract.recognizedBlocks(from: image, for: .word) else {
      return XCTFail("Failed getting OCR result and iterator")
    }
    
    XCTAssertEqual(1, actualBlocks1.count)
    XCTAssertEqual(expected, actualBlocks1.first!.text)
  }
  
  #if canImport(Combine)
  @available(iOS 13.0, *)
  func test_performOCRPublisherSucceeds_whenPerformedOnValidNSImage() {
    var cancellables = Set<AnyCancellable>()
    let image = UIImage(data: getImageData(named: "image_sample", ofType: "jpg"))!
    swiftyTesseract.performOCRPublisher(on: image)
      .assertNoFailure()
      .sink { actual in
        XCTAssertEqual("1234567890", actual.trimmingCharacters(in: .whitespacesAndNewlines))
      }
      .store(in: &cancellables)
  }
  
  @available(iOS 13.0, *)
  func test_performOCRPublisherFails_whenPerformedOnInvalidNSImage() {
    var cancellables = Set<AnyCancellable>()
    let image = UIImage()
    
    swiftyTesseract.performOCRPublisher(on: image)
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .finished:
            XCTFail("OCR should have failed")
          case .failure(let error):
            XCTAssertEqual(error, .imageConversionError)
          }
        },
        receiveValue: { _ in XCTFail("OCR should have failed") }
      )
      .store(in: &cancellables)
  }
  #endif
  #endif
  
  // MARK: - AppKit Specific Tests
  #if canImport(AppKit) && !targetEnvironment(macCatalyst)
  func test_OcrReturnsCorrectValue_whenPerformedOnNSImage() {
    let image = NSImage(data: getImageData(named: "image_sample", ofType: "jpg"))!
    let expected = "1234567890"
    guard case let .success(actual) = swiftyTesseract.performOCR(on: image) else {
      return XCTFail("OCR was unsuccessful")
    }
    
    XCTAssertEqual(expected, actual.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  func test_recognizedBlocksRunsAsExpected_whenPerformedWithNSImage() {
    let image = NSImage(data: getImageData(named: "image_sample", ofType: "jpg"))!
    let expected = "1234567890"
    
    guard case let .success((_, dict)) = swiftyTesseract.recognizedBlocks(from: image, for: [.symbol, .word]) else {
      return XCTFail("Failed getting OCR results and iterator")
    }
    
    XCTAssertEqual(expected.count, dict[.symbol]!.count)
    XCTAssertEqual(expected.map(String.init), dict[.symbol]!.map(\.text))
    XCTAssertEqual(1, dict[.word]!.count)
    XCTAssertEqual(expected, dict[.word]!.first!.text)
    
    guard case let .success((_, actualBlocks0)) = swiftyTesseract.recognizedBlocks(from: image, for: .symbol) else {
      return XCTFail("Failed getting OCR result and iterator")
    }
    
    XCTAssertEqual(expected.count, actualBlocks0.count)
    XCTAssertEqual(expected.map(String.init), actualBlocks0.map(\.text))
    
    guard case let .success((_, actualBlocks1)) = swiftyTesseract.recognizedBlocks(from: image, for: .word) else {
      return XCTFail("Failed getting OCR result and iterator")
    }
    
    XCTAssertEqual(1, actualBlocks1.count)
    XCTAssertEqual(expected, actualBlocks1.first!.text)
  }
  
  #if canImport(Combine)
  @available(OSX 10.15, *)
  func test_performOCRPublisherSucceeds_whenPerformedOnValidNSImage() {
    var cancellables = Set<AnyCancellable>()
    let image = NSImage(data: getImageData(named: "image_sample", ofType: "jpg"))!
    swiftyTesseract.performOCRPublisher(on: image)
      .assertNoFailure()
      .sink { actual in
        XCTAssertEqual("1234567890", actual.trimmingCharacters(in: .whitespacesAndNewlines))
      }
      .store(in: &cancellables)
  }
  
  @available(OSX 10.15, *)
  func test_performOCRPublisherFails_whenPerformedOnInvalidNSImage() {
    var cancellables = Set<AnyCancellable>()
    let image = NSImage()
    
    swiftyTesseract.performOCRPublisher(on: image)
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .finished:
            XCTFail("OCR should have failed")
          case .failure(let error):
            XCTAssertEqual(error, .imageConversionError)
          }
        },
        receiveValue: { _ in XCTFail("OCR should have failed") }
      )
      .store(in: &cancellables)
  }
  #endif
  #endif

  func getImageData(named name: String, ofType type: String) -> Data {
    let imagePath = Bundle.module.url(forResource: name, withExtension: type, subdirectory: "images")
    let data = try! Data(contentsOf: imagePath!)
    return data
  }
  
  func getString(from imageData: Data, file: StaticString = #filePath, line: UInt = #line) -> String {
    if case let .success(string) = swiftyTesseract.performOCR(on: imageData) {
      return string
    }
    
    XCTFail("OCR was unsuccessful", file: file, line: line)
    // We've already failed the test, this is here just to appease the compiler.
    return ""
  }
  
  static var allTests = [
    ("test_OcrReturnsCorrectValue_whenPerformedOnValidImageData", test_OcrReturnsCorrectValue_whenPerformedOnValidImageData),
    ("test_OcrDoesNotRecognizeCharactersOutsideOfAllowlist_whenAllowlistIsSet", test_OcrDoesNotRecognizeCharactersOutsideOfAllowlist_whenAllowlistIsSet),
    ("test_OcrDoesNotRecognizeCharactersInDisallowList_whenDisallowlistIsSet", test_OcrDoesNotRecognizeCharactersInDisallowList_whenDisallowlistIsSet),
    ("test_OcrPreservesMutipleSpaces_whenPreserveInterwordSpacesIsSet", test_OcrPreservesMutipleSpaces_whenPreserveInterwordSpacesIsSet),
    ("test_OcrDoesNotRecognizeCharactersBelowMinimumHeight_whenMinimumCharacterHeightIsSet", test_OcrDoesNotRecognizeCharactersBelowMinimumHeight_whenMinimumCharacterHeightIsSet),
    ("test_OcrRecognizesMultipleLanguages_whenMultipleLanguagesAreSet", test_OcrRecognizesMultipleLanguages_whenMultipleLanguagesAreSet),
    ("test_OcrFails_whenGivenInvalidImageData", test_OcrFails_whenGivenInvalidImageData),
    ("test_OcrRecognizesExpectedValueOfCustomLanguage_whenCustomLanguageIsSet", test_OcrRecognizesExpectedValueOfCustomLanguage_whenCustomLanguageIsSet),
    ("test_recognizedBlocksRunsAsExpected_whenProvidedValidImageData", test_recognizedBlocksRunsAsExpected_whenProvidedValidImageData)
  ]
}
