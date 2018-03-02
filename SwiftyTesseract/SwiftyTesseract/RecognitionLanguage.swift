//
//  RecognitionLanguage.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/1/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation
import libtesseract

public enum RecognitionLanguage: String {
  case english = "eng"
}

public enum EngineMode: TessOcrEngineMode.RawValue {
  case tesseractOnly = 0
  case lstmOnly = 1
  case tesseractLstmCombined = 2
  case `default` = 3
}
