//
//  File.swift
//  
//
//  Created by Steven Sherry on 7/14/20.
//

#if canImport(AppKit)
import AppKit

extension SwiftyTesseract {
  public func performOCR(on image: NSImage) -> Result<String, Swift.Error> {
    guard let data = image.tiffRepresentation
    else { return .failure(SwiftyTesseract.Error.imageConversionError) }
    
    return performOCR(on: data)
  }
}

#if canImport(Combine)
import Combine

extension SwiftyTesseract {
  @available(OSX 10.15, *)
  public func performOCRPublisher(on image: NSImage) -> AnyPublisher<String, Swift.Error> {
    guard let data = image.tiffRepresentation else {
      return Fail(error: SwiftyTesseract.Error.imageConversionError)
        .eraseToAnyPublisher()
    }
    
    return performOCRPublisher(on: data)
  }
}
#endif

#endif
