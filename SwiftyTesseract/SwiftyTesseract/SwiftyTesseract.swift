//
//  SwiftyTesseract.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 2/28/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import UIKit
import libtesseract
import libleptonica

typealias TessBaseAPI = OpaquePointer
public typealias TessString = UnsafePointer<Int8>
typealias Pix = UnsafeMutablePointer<PIX>


public class SwiftyTesseract {
  
  private var tesseract: TessBaseAPI = TessBaseAPICreate()
  
  public var version: String? {
    guard let tesseractVersion = TessVersion() else { return nil }
    return String(tesseractString: tesseractVersion)
  }
  
  public var apiReturnCode: Int32
  
  public func performOCR(from image: UIImage) -> String {
    let width = Int32(image.size.width)
    let height = Int32(image.size.height)
    print("Height and width of image: \(height), \(width)")
    let cgImage = image.cgImage
    let bitsPerPixel = max(1, Int32(cgImage!.bitsPerPixel))
    let imageAsPngData = UIImagePNGRepresentation(image)
    let imageBase64String = imageAsPngData?.base64EncodedString()
    let imageAsPngDataSize = UIImagePNGRepresentation(image)?.count
    let pixImage: Pix = pixRead("/Users/stevensherry/Downloads/image_sample.jpg")
    print("bitsPerPixel = \(bitsPerPixel)")
    print("Pix X Res: \(pixGetXRes(pixImage))")
    print("Pix Y Res: \(pixGetYRes(pixImage))")
    TessBaseAPISetImage2(tesseract, pixImage)
    guard TessBaseAPIRecognize(tesseract, nil) == 0 else { fatalError("Error in recognition") }
    defer {
      print("in defer")
      pixImage.deinitialize()
    }
    
    guard let cString = TessBaseAPIGetUTF8Text(tesseract) else { fatalError("No return string") }
    return String(cString: cString)
  }
  
  // Works - Trying to figure out the best way to make the initializer "Swifty"

  public init(with language: RecognitionLanguage = .english,
              dataPath: String,
              engineMode: EngineMode = .tesseractOnly) {
    setenv("TESSDATA_PREFIX", dataPath, 1)
    apiReturnCode = TessBaseAPIInit2(tesseract, dataPath,
                                     language.rawValue, TessOcrEngineMode(rawValue: engineMode.rawValue))
  }
  
  deinit {
    TessBaseAPIClear(tesseract)
  }
  
}

extension String {
  init(tesseractString: TessString) {
    self.init(cString: tesseractString)
  }
}
