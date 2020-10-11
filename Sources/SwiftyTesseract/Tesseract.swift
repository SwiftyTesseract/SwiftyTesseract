//
//  Tesseract.swift
//  Tesseract
//
//  Created by Steven Sherry on 2/28/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation
import libtesseract

public typealias TessBaseAPI = OpaquePointer
typealias Pix = UnsafeMutablePointer<PIX>?

/// A class that performs optical character recognition with the open-source Tesseract library
public class Tesseract {
  private let tesseract: TessBaseAPI = TessBaseAPICreate()

  /// Required to make OCR operations thread safe.
  private let semaphore = DispatchSemaphore(value: 1)

  private init(
    languageString: String,
    dataSource: LanguageModelDataSource,
    engineMode: EngineMode,
    @ConfigurationBuilder configure: () -> (TessBaseAPI) -> Void
  ) {
    let initReturnCode = TessBaseAPIInit2(
      tesseract,
      dataSource.pathToTrainedData,
      languageString,
      engineMode
    )

    guard initReturnCode == 0 else { fatalError(Tesseract.Error.initializationErrorMessage) }

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
  ///   - configure: The configuration to apply to Tesseract - default is a no-op
  public convenience init(
    languages: [RecognitionLanguage],
    dataSource: LanguageModelDataSource = Bundle.main,
    engineMode: EngineMode = .lstmOnly,
    @ConfigurationBuilder configure: () -> (TessBaseAPI) -> Void = { { _ in } }
  ) {
    let stringLanguages = RecognitionLanguage.createLanguageString(from: languages)
    self.init(
      languageString: stringLanguages,
      dataSource: dataSource,
      engineMode: engineMode,
      configure: configure
    )
  }

  /// Convenience initializer for creating an instance of SwiftyTesseract with one language to avoid having to
  /// input an array with one value (e.g. [.english]) for the languages parameter
  ///
  /// - Parameters:
  ///   - language: The language of the text to be recognized
  ///   - dataSource: The LanguageModelDataSource that contains the tessdata folder - default is Bundle.main
  ///   - engineMode: The tesseract engine mode - default is .lstmOnly
  ///   - configure: The configuration to apply to Tesseract - default is a no-op
  public convenience init(
    language: RecognitionLanguage,
    dataSource: LanguageModelDataSource = Bundle.main,
    engineMode: EngineMode = .lstmOnly,
    @ConfigurationBuilder configure: () -> (TessBaseAPI) -> Void = { { _ in } }
  ) {
    self.init(
      languages: [language],
      dataSource: dataSource,
      engineMode: engineMode,
      configure: configure
    )
  }

  deinit {
    // Releases the tesseract instance from memory
    TessBaseAPIEnd(tesseract)
    TessBaseAPIDelete(tesseract)
  }

  /// Perform an action using the Tesseract pointer crated during initialization. This operation is thread-safe
  /// - Parameter action: A function that operates on the tessearct pointer to produce a value.
  /// - Returns: The value returned from `action`
  public func perform<A>(action: (TessBaseAPI) -> A) -> A {
    _ = semaphore.wait(timeout: .distantFuture)
    defer { semaphore.signal() }

    return action(tesseract)
  }

  /// Configure `Tesseract` post-initialization. This operation is thread-safe.
  /// - Parameter configure: A `ConfigurationBuilder` to apply the desired configuration to Tesseract
  public func configure(@ConfigurationBuilder _ configure: () -> (TessBaseAPI) -> Void) {
    perform { tessBaseApi in
      configure()(tessBaseApi)
    }
  }
}

/// Specifically determines the underlying method that Tesseract uses to perforn OCR
public typealias EngineMode = TessOcrEngineMode

public extension EngineMode {
  /// The legacy Tesseract engine. This can only use training data from the
  /// [tessdata](https://github.com/tesseract-ocr/tessdata) repository
  static let tesseractOnly = OEM_TESSERACT_ONLY
  /// Utilizes a long short-term memory recurrent neural network. This can use training data from
  /// [tessdata](https://github.com/tesseract-ocr/tessdata),
  /// [tessdata_best](https://github.com/tesseract-ocr/tessdata_best),
  /// or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) respositories
  static let lstmOnly = OEM_LSTM_ONLY
  /// A combination of the legacy Tesseract engine and a long short-term memory
  /// recurrent neural network. This can only use training data from the
  /// [tessdata](https://github.com/tesseract-ocr/tessdata) repository
  static let tesseractLstmCombined = OEM_TESSERACT_LSTM_COMBINED
  static let `default` = OEM_DEFAULT
}
