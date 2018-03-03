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

public enum CharacterGroup: String {
  case lowercase = "abcdefghijlkmnopqrstuvwxyz"
  case uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  case numbers = "1234567890"
  case specialCharacters = "~!@#$%^&*()_+`=-[]\\{}|;'\",./<>?"
  
  func filterOut(_ charsToRemove: String) -> String {
    return self.rawValue.filter { !charsToRemove.contains($0) }
  }
}

extension String {
  func appending(_ characterGroup: CharacterGroup) -> String {
    return self.appending(characterGroup.rawValue)
  }
}
