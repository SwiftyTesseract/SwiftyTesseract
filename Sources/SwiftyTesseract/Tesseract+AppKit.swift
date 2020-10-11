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

  public func recognizedBlocks(
    from image: NSImage,
    for levels: [PageIteratorLevel]
  ) -> Result<(String, [PageIteratorLevel: [RecognizedBlock]]), Error> {
    image.data
      .flatMap { recognizedBlocks(from: $0, for: levels) }
  }

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
