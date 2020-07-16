//
//  Tesseract+Combine.swift
//  
//
//  Created by Steven Sherry on 7/14/20.
//

#if canImport(Combine)
import Combine
import Foundation

extension Tesseract {
  /// Creates a *cold* publisher that performs OCR on a provided image upon subscription
  /// - Parameter image: The image to perform recognition on
  /// - Returns: A cold publisher that emits a single `String` on success or an `Error` on failure.
  @available(OSX 10.15, iOS 13.0, *)
  public func performOCRPublisher(on data: Data) -> AnyPublisher<String, Error> {
    Deferred {
      Future { [weak self] promise in
        promise(self?.performOCR(on: data) ?? .failure(Tesseract.Error.imageConversionError))
      }
    }
    .eraseToAnyPublisher()
  }
}
#endif
