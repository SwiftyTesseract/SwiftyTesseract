//
//  Tesseract+OCR.swift
//  
//
//  Created by Steven Sherry on 7/15/20.
//

import Foundation
import libtesseract

public extension Tesseract {
  /// Performs OCR on an image
  /// - Parameter image: The `Data` representation of an image (e.g. `UIImage.pngData()`)
  /// - Returns: A result containing the recognized `String `or an `Error` if recognition failed
  func performOCR(on data: Data) -> Result<String, Error> {
    perform { tessPointer in
      var pix = createPix(from: data)
      defer { pixDestroy(&pix) }

      TessBaseAPISetImage2(tessPointer, pix)

      if TessBaseAPIGetSourceYResolution(tessPointer) < 70 {
        TessBaseAPISetSourceResolution(tessPointer, 300)
      }

      guard let cString = TessBaseAPIGetUTF8Text(tessPointer)
        else { return .failure(Tesseract.Error.unableToExtractTextFromImage) }

      defer { TessDeleteText(cString) }

      return .success(String(cString: cString))
    }
  }

  internal func createPix(from data: Data) -> Pix {
    data.withUnsafeBytes { bytePointer in
      let uint8Pointer = bytePointer.bindMemory(to: UInt8.self)
      return pixReadMem(uint8Pointer.baseAddress, data.count)
    }
  }
}
