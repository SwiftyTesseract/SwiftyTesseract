//
//  SwiftyTesseract+UIKit.swift
//  
//
//  Created by Steven Sherry on 7/14/20.
//

#if canImport(UIKit)
import UIKit
import libtesseract

extension SwiftyTesseract {
  /// Performs OCR on a `UIImage`
  /// - Parameter image: The image to perform recognition on
  /// - Returns: A result containing the recognized `String `or an `Error` if recognition failed
  public func performOCR(on image: UIImage) -> Result<String, Swift.Error> {
    guard let data = image.pngData() else { return .failure(SwiftyTesseract.Error.imageConversionError) }
    return performOCR(on: data)
  }

  private func createPix(from image: UIImage) throws -> Pix {
    guard let data = image.pngData() else { throw SwiftyTesseract.Error.imageConversionError }
    return try createPix(from: data)
  }
  
//  /// Takes an array UIImages and returns the PDF as a `Data` object.
//  /// If using PDFKit introduced in iOS 11, this will produce a valid
//  /// PDF Document.
//  ///
//  /// - Parameter images: Array of UIImages to perform OCR on
//  /// - Returns: PDF `Data` object
//  /// - Throws: SwiftyTesseractError
//  public func createPDF(from images: [UIImage]) throws -> Data {
//    _ = semaphore.wait(timeout: .distantFuture)
//    defer { semaphore.signal() }
//
//    let filepath = try processPDF(images: images)
//    let data = try Data(contentsOf: filepath)
//    try FileManager.default.removeItem(at: filepath)
//
//    return data
//  }
//
//  private func processPDF(images: [UIImage]) throws -> URL {
//    let filepath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
//
//    let renderer = try makeRenderer(at: filepath)
//    defer { TessDeleteResultRenderer(renderer) }
//
//    try render(images, with: renderer)
//
//    return filepath.appendingPathExtension("pdf")
//  }
//
//  private func render(_ images: [UIImage], with renderer: OpaquePointer) throws {
//    let pixImages = try images.map(createPix)
//
//    defer { for var pix in pixImages { pixDestroy(&pix) } }
//
//    try pixImages.enumerated().forEach { [weak self] pageNumber, pix in
//      guard let self = self else { return }
//      guard TessBaseAPIProcessPage(
//        self.tesseract,
//        pix,
//        Int32(pageNumber),
//        "page.\(pageNumber)",
//        nil,
//        30000,
//        renderer
//      ) == 1 else {
//        throw SwiftyTesseract.Error.unableToProcessPage
//      }
//    }
//
//    guard TessResultRendererEndDocument(renderer) == 1 else { throw SwiftyTesseract.Error.unableToEndDocument }
//  }
}

#if canImport(Combine)
import Combine
extension SwiftyTesseract {
  /// Creates a *cold* publisher that performs OCR on a provided image upon subscription
  /// - Parameter image: The image to perform recognition on
  /// - Returns: A cold publisher that emits a single `String` on success or an `Error` on failure.
  @available(iOS 13.0, *)
  public func performOCRPublisher(on image: UIImage) -> AnyPublisher<String, Swift.Error> {
    Deferred {
      Future { [weak self] promise in
        promise(self?.performOCR(on: image) ?? .failure(SwiftyTesseract.Error.imageConversionError))
      }
    }
    .eraseToAnyPublisher()
  }
}
#endif

#endif
