//
//  Tesseract+AppKit.swift
//  
//
//  Created by Steven Sherry on 7/14/20.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSImage {
  var data: Result<Data, Tesseract.Error> {
    guard let data = tiffRepresentation else { return .failure(.imageConversionError) }
    return .success(data)
  }
}

extension Tesseract {
  public func performOCR(on image: NSImage) -> Result<String, Error> {
    image.data
      .flatMap { performOCR(on: $0) }
  }

  /// Performs OCR on an image and identifies the regions recognized in the coordinate space of the _image_
  /// - Parameters:
  ///   - image: The `NSImage` to perform recognition on
  ///   - levels: The levels which correspond to the granularity of the desired recognized blocks
  /// - Returns: On success, a `(String, [PageIteratorLevel: [RecognizedBlock]])` that contains
  /// the recognized string and a dictionary of `[RecognizedBlock]` keyed by the provided `PageIteratorLevel`s
  public func recognizedBlocks(
    from image: NSImage,
    for levels: [PageIteratorLevel]
  ) -> Result<(String, [PageIteratorLevel: [RecognizedBlock]]), Error> {
    image.data
      .flatMap { recognizedBlocks(from: $0, for: levels) }
  }

  /// Performs OCR on an image and identifies the regions recognized in the coordinate space of the image
  /// - Parameters:
  ///   - image: The `NSImage` to perform recognition on
  ///   - level: The level which corresponds to the granularity of the desired recognized block
  /// - Returns: On success, a tuple of the recognized string and an array of `RecognizedBlock`s in
  ///  the coordinate space of the _image_.
  public func recognizedBlocks(
    from image: NSImage,
    for level: PageIteratorLevel
  ) -> Result<(String, [RecognizedBlock]), Error> {
    image.data
      .flatMap { recognizedBlocks(from: $0, for: level) }
  }
}

#if canImport(Combine) && !targetEnvironment(macCatalyst)
import Combine

extension Tesseract {
  @available(OSX 10.15, *)
  /// Creates a *cold* publisher that performs OCR on a provided image upon subscription
  /// - Parameter image: The image to perform recognition on
  /// - Returns: A cold publisher that emits a single `String` on success or an `Error` on failure.
  public func performOCRPublisher(on image: NSImage) -> AnyPublisher<String, Error> {
    guard let data = image.tiffRepresentation else {
      return Fail(error: Tesseract.Error.imageConversionError)
        .eraseToAnyPublisher()
    }
    return performOCRPublisher(on: data)
  }
}
#endif

#endif
