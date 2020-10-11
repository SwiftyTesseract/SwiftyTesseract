//
//  Tesseract+UIKit.swift
//  
//
//  Created by Steven Sherry on 7/14/20.
//

#if canImport(UIKit)
import UIKit
import libtesseract

extension UIImage {
  var data: Result<Data, Tesseract.Error> {
    guard let data = pngData() else { return .failure(.imageConversionError) }
    return .success(data)
  }
}

extension Tesseract {
  /// Performs OCR on a `UIImage`
  /// - Parameter image: The image to perform recognition on
  /// - Returns: A result containing the recognized `String `or an `Error` if recognition failed
  public func performOCR(on image: UIImage) -> Result<String, Error> {
    image.data
      .flatMap { performOCR(on: $0) }
  }

  /// Performs OCR on an image and identifies the regions recognized in the coordinate space of the _image_
  /// - Parameters:
  ///   - image: The `UIImage` to perform recognition on
  ///   - levels: The levels which correspond to the granularity of the desired recognized blocks
  /// - Returns: On success, a `(String, [PageIteratorLevel: [RecognizedBlock]])` that contains
  /// the recognized string and a dictionary of `[RecognizedBlock]` keyed by the provided `PageIteratorLevel`s
  public func recognizedBlocks(
    from image: UIImage,
    for levels: [PageIteratorLevel]
  ) -> Result<(String, [PageIteratorLevel: [RecognizedBlock]]), Error> {
    image.data
      .flatMap { recognizedBlocks(from: $0, for: levels) }
  }

  /// Performs OCR on an image and identifies the regions recognized in the coordinate space of the image
  /// - Parameters:
  ///   - image: The `UIImage` to perform recognition on
  ///   - level: The level which corresponds to the granularity of the desired recognized block
  /// - Returns: On success, a tuple of the recognized string and an array of `RecognizedBlock`s in
  ///  the coordinate space of the _image_.
  public func recognizedBlocks(
    from image: UIImage,
    for level: PageIteratorLevel
  ) -> Result<(String, [RecognizedBlock]), Error> {
    image.data
      .flatMap { recognizedBlocks(from: $0, for: level) }
  }
}

#if canImport(Combine)
import Combine
extension Tesseract {
  /// Creates a *cold* publisher that performs OCR on a provided image upon subscription
  /// - Parameter image: The image to perform recognition on
  /// - Returns: A cold publisher that emits a single `String` on success or an `Error` on failure.
  @available(iOS 13.0, *)
  public func performOCRPublisher(on image: UIImage) -> AnyPublisher<String, Error> {
    Deferred {
      Future { [weak self] promise in
        promise(self?.performOCR(on: image) ?? .failure(.imageConversionError))
      }
    }
    .eraseToAnyPublisher()
  }
}
#endif

#endif
