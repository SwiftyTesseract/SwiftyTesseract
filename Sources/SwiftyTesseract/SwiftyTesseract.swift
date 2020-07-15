//
//  SwiftyTesseract.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 2/28/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import libtesseract

public typealias TessBaseAPI = OpaquePointer
typealias Pix = UnsafeMutablePointer<PIX>?

@_functionBuilder
public struct ConfigurationBuilder {
  static func buildBlock(_ configurations: (TessBaseAPI) -> Void...) -> (TessBaseAPI) -> Void {
    return { tessPointer in
      configurations.forEach { $0(tessPointer) }
    }
  }
}

public func set(_ variableName: TesseractVariableName, value: String) -> (TessBaseAPI) -> Void {
  return { tessPointer in
    TessBaseAPISetVariable(tessPointer, variableName.rawValue, value)
  }
}

public extension String {
  static let `true` = "1"
  static let `false` = "0"
  static func integer<A: BinaryInteger>(_ value: A) -> String {
    String(value)
  }
}

/// A class that performs optical character recognition with the open-source Tesseract library
public class SwiftyTesseract {

  // MARK: - Properties
  let tesseract: TessBaseAPI = TessBaseAPICreate()

  private let dataSource: LanguageModelDataSource

  /// Required to make OCR operations thread safe.
  internal let semaphore = DispatchSemaphore(value: 1)

  /// Sets a `String` of characters that will **only** be recognized. This does **not** filter values.
  ///
  /// Example: setting a whiteList of "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  /// with an image containing digits may result in "1" being recognized as "I" and "2" being
  /// recognized as "Z". Set this value **only** if it is 100% certain the characters that are
  /// defined will **only** be present during recognition.
  ///
  /// **This may cause unpredictable recognition results if characters not defined in whiteList**
  /// **are present**. If **removal** and not **replacement** is desired, filtering the recognition
  /// string is a better option.
//  public var whiteList: String? {
//    didSet {
//      guard let whiteList = whiteList else { return }
//      setTesseractVariable(.whitelist, value: whiteList)
//    }
//  }

  /// Sets a `String` of characters that will **not** be recognized. This does **not** filter values.
  ///
  /// Example: setting a blackList of "0123456789" with an image containing digits may result in
  /// "1" being recognized as "I" and "2" being recognized as "Z". Set this value **only** if it
  /// is 100% certain that the characters defined will **not** be present during recognition.
  ///
  /// **This may cause unpredictable recognition results if characters defined in blackList are**
  /// **present**. If **removal** and not **replacement** is desired, filtering the recognition
  /// string is a better option
//  public var blackList: String? {
//    didSet {
//      guard let blackList = blackList else { return }
//      setTesseractVariable(.blacklist, value: blackList)
//    }
//  }

  /// Preserve multiple interword spaces
//  public var preserveInterwordSpaces: Bool? {
//    didSet {
//      guard let preserveInterwordSpaces = preserveInterwordSpaces else { return }
//      setTesseractVariable(.preserveInterwordSpaces, value: preserveInterwordSpaces ? "1" : "0")
//    }
//  }

  /// Minimum character height
//  public var minimumCharacterHeight: Int? {
//    didSet {
//      guard let minimumCharacterHeight = minimumCharacterHeight else { return }
//      setTesseractVariable(.oldCharacterHeight, value: "1")
//      setTesseractVariable(.minimumCharacterHeight, value: String(minimumCharacterHeight))
//    }
//  }

  /// The current version of the underlying Tesseract library
  lazy public private(set) var version: String? = {
    guard let tesseractVersion = TessVersion() else { return nil }
    return String(cString: tesseractVersion)
  }()

  private init(
    languageString: String,
    dataSource: LanguageModelDataSource,
    engineMode: EngineMode,
    @ConfigurationBuilder _ configure: () -> (TessBaseAPI) -> Void
  ) {
    // save input bundle
    self.dataSource = dataSource

    setEnvironmentVariable(.tessDataPrefix, value: dataSource.pathToTrainedData)

    // This variable's value somehow persists between deinit and init, default value should be set
    setTesseractVariable(.oldCharacterHeight, value: "0")

    guard TessBaseAPIInit2(tesseract,
                           dataSource.pathToTrainedData,
                           languageString,
                           TessOcrEngineMode(rawValue: engineMode.rawValue)) == 0
    else { fatalError(SwiftyTesseract.Error.initializationErrorMessage) }
    
    configure()(tesseract)
  }

  // MARK: - Initialization
  /// Creates an instance of SwiftyTesseract using standard RecognitionLanguages. The tessdata
  /// folder MUST be in your Xcode project as a folder reference (blue folder icon, not yellow)
  /// and be named "tessdata"
  ///
  /// - Parameters:
  ///   - languages: Languages of the text to be recognized
  ///   - dataSource: The LanguageModelDataSource that contains the tessdata folder - default is Bundle.main
  ///   - engineMode: The tesseract engine mode - default is .lstmOnly
  public convenience init(
    languages: [RecognitionLanguage],
    dataSource: LanguageModelDataSource = Bundle.main,
    engineMode: EngineMode = .lstmOnly,
    @ConfigurationBuilder _ configure: () -> (TessBaseAPI) -> Void = { { _ in } }
  ) {
    let stringLanguages = RecognitionLanguage.createLanguageString(from: languages)
    
    self.init(
      languageString: stringLanguages,
      dataSource: dataSource,
      engineMode: engineMode,
      configure
    )
  }

  /// Convenience initializer for creating an instance of SwiftyTesseract with one language to avoid having to
  /// input an array with one value (e.g. [.english]) for the languages parameter
  ///
  /// - Parameters:
  ///   - language: The language of the text to be recognized
  ///   - dataSource: The LanguageModelDataSource that contains the tessdata folder - default is Bundle.main
  ///   - engineMode: The tesseract engine mode - default is .lstmOnly
  public convenience init(
    language: RecognitionLanguage,
    dataSource: LanguageModelDataSource = Bundle.main,
    engineMode: EngineMode = .lstmOnly,
    @ConfigurationBuilder _ configure: () -> (TessBaseAPI) -> Void = { { _ in } }
  ) {
    self.init(
      languages: [language],
      dataSource: dataSource,
      engineMode: engineMode,
      configure
    )
  }

  deinit {
    // Releases the tesseract instance from memory
    TessBaseAPIEnd(tesseract)
    TessBaseAPIDelete(tesseract)
  }

  private func setTesseractVariable(_ variableName: TesseractVariableName, value: String) {
    TessBaseAPISetVariable(tesseract, variableName.rawValue, value)
  }

  private func setEnvironmentVariable(_ variableName: TesseractVariableName, value: String) {
    setenv(variableName.rawValue, value, 1)
  }
}

// MARK: - OCR
extension SwiftyTesseract {
  public func performOCR(on data: Data) -> Result<String, Swift.Error> {
    _ = semaphore.wait(timeout: .distantFuture)
    defer { semaphore.signal() }
    
    let pixResult = Result { try createPix(from: data) }
    defer { pixResult.destroy() }
    
    return pixResult.flatMap { pix in
      TessBaseAPISetImage2(tesseract, pix)
      
      if TessBaseAPIGetSourceYResolution(tesseract) < 70 {
        TessBaseAPISetSourceResolution(tesseract, 300)
      }

      guard let cString = TessBaseAPIGetUTF8Text(tesseract)
        else { return .failure(SwiftyTesseract.Error.unableToExtractTextFromImage) }

      defer { TessDeleteText(cString) }

      return .success(String(cString: cString) )
    }
  }
  
  internal func createPix(from data: Data) throws -> Pix {
    data.withUnsafeBytes { bytePointer in
      let uint8Pointer = bytePointer.bindMemory(to: UInt8.self)
      return pixReadMem(uint8Pointer.baseAddress, data.count)
    }
  }
}

extension SwiftyTesseract {
  /// This method must be called *after* `performOCR(on:)`. Otherwise calling this method will result in failure.
  /// - Parameter level: The level which corresponds to the granularity of the desired recognized block
  /// - Returns: On success, an array of `RecognizedBlock`s in the coordinate space of the _image_.
  public func recognizedBlocks(for level: ResultIteratorLevel) -> Result<[RecognizedBlock], Swift.Error> {
    guard let resultIterator = TessBaseAPIGetIterator(tesseract)
      else { return .failure(SwiftyTesseract.Error.unableToRetrieveIterator) }

    defer { TessPageIteratorDelete(resultIterator) }

    var results = [RecognizedBlock]()

    repeat {
      if let block = block(from: resultIterator, for: level.tesseractLevel) {
        results.append(block)
      }
    } while (TessPageIteratorNext(resultIterator, level.tesseractLevel) > 0)

    return .success(results)
  }

  private func block(from iterator: OpaquePointer, for level: TessPageIteratorLevel) -> RecognizedBlock? {
    guard let cString = TessResultIteratorGetUTF8Text(iterator, level) else { return nil }
    defer { TessDeleteText(cString) }

    let boundingBox = makeBoundingBox(from: iterator, for: level)
    let text = String(cString: cString)
    let confidence = TessResultIteratorConfidence(iterator, level)

    return RecognizedBlock(text: text, boundingBox: boundingBox, confidence: confidence)
  }

  private func makeBoundingBox(from iterator: OpaquePointer, for level: TessPageIteratorLevel) -> BoundingBox {
    var box = BoundingBox()
    TessPageIteratorBoundingBox(iterator, level, &box.originX, &box.originY, &box.widthOffset, &box.heightOffset)
    return box
  }
}

private extension Result where Success == Pix {
  func destroy() {
    guard case var .success(pix) = self else { return }
    pixDestroy(&pix)
  }
}
