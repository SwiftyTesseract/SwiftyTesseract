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
  /// in your Xcode project as a folder reference (blue folder icon, not yellow) and be named
  /// "tessdata"
  ///
  /// - Parameters:
  ///   - languages: Languages of the text to be recognized
  ///   - bundle: The bundle that contains the tessdata folder - default is .main
  ///   - engineMode: The tesseract engine mode - default is .lstmOnly
  public init(languages: [RecognitionLanguage],
              bundle: Bundle = .main,
              engineMode: EngineMode = .lstmOnly) {
    
    let stringLanguages = RecognitionLanguage.createLanguageString(from: languages)
  
    setenv("TESSDATA_PREFIX", bundle.pathToTrainedData, 1)
    guard TessBaseAPIInit2(tesseract,
                           bundle.pathToTrainedData,
                           stringLanguages,
                           TessOcrEngineMode(rawValue: engineMode.rawValue)) == 0
    else { fatalError("Unable to initialize SwiftyTesseract") }
    
  }
  
  /// Convenience initializer for creating an instance of SwiftyTesseract with one language to avoid having to
  /// input an array with one value (e.g. [.english]) for the languages parameter
  ///
  /// - Parameters:
  ///   - language: The language of the text to be recognized
  ///   - bundle: The bundle that contains the tessdata folder - default is .main
  ///   - engineMode: The tesseract engine mode - default is .lstmOnly
  public convenience init(language: RecognitionLanguage,
                          bundle: Bundle = .main,
                          engineMode: EngineMode = .lstmOnly) {
    
    self.init(languages: [language], bundle: bundle, engineMode: engineMode)
  }
  
  deinit {
    // Release the tesseract instance from memory
    TessBaseAPIEnd(tesseract)
    TessBaseAPIDelete(tesseract)
  }
  
  /// Takes a UIImage and passes resulting recognized text into completion handler
  ///
  /// - Parameters:
  ///   - image: The image to perform recognition on
  ///   - completionHandler: The action to be performed on the recognized string
  ///
  
  public func performOCR(on image: UIImage, completionHandler: @escaping (String?) -> ()) {
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
      completionHandler(nil)
      return
    }
    
    defer {
      // Release the Pix instance from memory
      pixDestroy(&pixImage)
      // Release the Tesseract string from memory
      TessDeleteText(tesseractString)
    }
    
    let swiftString = String(tesseractString: tesseractString)
    completionHandler(swiftString)
  }
  
  
  
  // MARK: - Helper functions
  
  private func createPix(from image: UIImage) -> Pix {
    let filename = save(image: image).path
    return pixRead(filename)
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
