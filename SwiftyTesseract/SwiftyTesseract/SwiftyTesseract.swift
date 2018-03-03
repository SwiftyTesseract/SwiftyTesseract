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
  
  private static var tesseract: TessBaseAPI = TessBaseAPICreate()
  
  public var version: String? {
    guard let tesseractVersion = TessVersion() else { return nil }
    return String(tesseractString: tesseractVersion)
  }
  
  public var apiReturnCode: Int32
  
  public var whiteList: String?
  public var blackList: String?
  
  // Works - Trying to figure out the best way to make the initializer "Swifty"

  public init(with language: RecognitionLanguage = .english,
              bundle: Bundle,
              engineMode: EngineMode = .tesseractOnly) {
    
    setenv("TESSDATA_PREFIX", bundle.pathToTrainedData, 1)
    apiReturnCode = TessBaseAPIInit2(SwiftyTesseract.tesseract,
                                     bundle.pathToTrainedData,
                                     language.rawValue,
                                     TessOcrEngineMode(rawValue: engineMode.rawValue))
    
  }
  
  deinit {
    TessBaseAPIClear(SwiftyTesseract.tesseract)
  }
  
  public func performOCR(from image: UIImage, completionHandler: @escaping (String) -> ()) {
    let pixImage = pixFrom(image: image)
  
    TessBaseAPISetImage2(SwiftyTesseract.tesseract, pixImage)
    guard TessBaseAPIRecognize(SwiftyTesseract.tesseract, nil) == 0 else { fatalError("Error in recognition") }
    
    defer {
      print("in defer")
      pixImage.deinitialize()
    }
    
    guard let cString = TessBaseAPIGetUTF8Text(SwiftyTesseract.tesseract) else { fatalError("No return string") }
    var returnString = String(cString: cString)
    
    if let blackList = blackList {
      returnString = returnString.filter { !blackList.contains($0) }
    }
    
    if let whiteList = whiteList {
      returnString = returnString.filter { whiteList.contains($0) }
    }
    
    completionHandler(returnString)
  }
  
  private func pixFrom(image: UIImage) -> Pix {
    let filename = save(image: image).path
    return pixRead(filename)
  }
  
  private func save(image: UIImage) -> URL {
    guard let data = UIImagePNGRepresentation(image) else { fatalError("Unable to convert to PNG") }
    let filename = getDocumentsDirectory().appendingPathComponent("temp.png")
    do {
      try data.write(to: filename)
    } catch let e {
      print(e.localizedDescription)
      fatalError("Unable to write PNG data to disk")
    }
    return filename
  }
  
  private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
}

extension String {
  init(tesseractString: TessString) {
    self.init(cString: tesseractString)
  }
}

extension Bundle {
  var pathToTrainedData: String {
    let intermediatePath = self.bundleURL.appendingPathComponent("tessdata").absoluteString
    let subString = intermediatePath[(String.Index(encodedOffset: 7))..<String.Index(encodedOffset: intermediatePath.count - 1)]
    return String(subString)
  }
}
