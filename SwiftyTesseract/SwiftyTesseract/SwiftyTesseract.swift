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
typealias Pix = UnsafeMutablePointer<PIX>?


public class SwiftyTesseract {
  
  private let tesseract: TessBaseAPI = TessBaseAPICreate()
  
  public var whiteList: String?
  public var blackList: String?
  
  lazy public private(set) var version: String? = {
    guard let tesseractVersion = TessVersion() else { return nil }
    return String(tesseractString: tesseractVersion)
  }()
  

  /// Initializer to create an instance of SwiftyTesseract. The tessdata folder MUST be
  ///  in your Xcode project as a folder reference (blue folder icon, not yellow) and be named
  ///  "tessdata"
  ///
  /// - Parameters:
  ///   - language: Language of text to be recognized
  ///   - bundle: The bundle that contains the tessdata folder
  ///   - engineMode: The tesseract engine mode
  public init(language: RecognitionLanguage,
              bundle: Bundle = .main,
              engineMode: EngineMode = .tesseractOnly) {
    
    setenv("TESSDATA_PREFIX", bundle.pathToTrainedData, 1)
    guard TessBaseAPIInit2(tesseract,
                           bundle.pathToTrainedData,
                           language.rawValue,
                           TessOcrEngineMode(rawValue: engineMode.rawValue)) == 0 else { fatalError("Unable to initialize SwiftyTesseract") }
    
  }
  
  deinit {
    // Release the tesseract instance from memory
    TessBaseAPIEnd(tesseract)
    TessBaseAPIDelete(tesseract)
  }
  
  /// Takes a UIImage and passes resulting recognized text into completion handler to provide the
  /// developer the option to choose whether or not the string is handled on a background thread or not.
  ///
  /// - Parameters:
  ///   - image: The image to perform recognition on
  ///   - completionHandler: The action to be performed on the recognized string
  ///
  
  public func performOCR(from image: UIImage, completionHandler: @escaping (Bool, String?) -> ()) {
    /*
     pixImage is a var because it has to be passed as an inout paramter to pixDestroy to
     release the memory allocation
    */
    var pixImage = createPix(from: image)
    TessBaseAPISetImage2(tesseract, pixImage)
    
    if TessBaseAPIGetSourceYResolution(tesseract) < 70 {
      TessBaseAPISetSourceResolution(tesseract, 300)
    }
  
    guard
      TessBaseAPIRecognize(tesseract, nil) == 0,
      let tesseractString = TessBaseAPIGetUTF8Text(tesseract)
    else {
      completionHandler(false, nil)
      return
    }
    
    defer {
      // Release the Pix instance from memory
      pixDestroy(&pixImage)
      // Release the Tesseract string from memory
      TessDeleteText(tesseractString)
    }
    
    let swiftString = convert(tesseractString: tesseractString)
    completionHandler(true, swiftString)
  }
  
  
  
  // MARK: - Helper functions
  
  private func createPix(from image: UIImage) -> Pix {
    let filename = save(image: image).path
    return pixRead(filename)
  }
  
  private func convert(tesseractString: TessString) -> String {
    var convertedString = String(tesseractString: tesseractString)
    
    if let blacklist = blackList {
      convertedString = convertedString.filter { !blacklist.contains($0) }
    }

    if let whitelist = whiteList {
      convertedString = convertedString.filter { whitelist.contains($0) }
    }

    return convertedString
  }
  
  private func save(image: UIImage) -> URL {
    guard let data = UIImagePNGRepresentation(image) else { fatalError("Unable to convert to PNG") }
    let url = getDocumentsDirectory().appendingPathComponent("temp.png")
    do {
      try data.write(to: url)
    } catch let e {
      print(e.localizedDescription)
      fatalError("Unable to write PNG data to disk")
    }
    return url
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
