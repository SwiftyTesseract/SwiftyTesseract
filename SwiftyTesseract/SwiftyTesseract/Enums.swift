//
//  Enums.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/1/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation
import libtesseract

// TODO: - Add all languages supported by Tesseract
public enum RecognitionLanguage: String {
  case english = "eng"
}

public enum EngineMode: TessOcrEngineMode.RawValue {
  case tesseractOnly = 0
  case lstmOnly = 1
  case tesseractLstmCombined = 2
  case `default` = 3
}

// TODO: - This may need to be split into a different file with a top level enum of CharacterGroup with subgroups such as English, French, etc.
public enum CharacterGroup: String {
  case lowercase = "abcdefghijlkmnopqrstuvwxyz"
  case uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  case numbers = "1234567890"
  case specialCharacters = "~!@#$%^&*()_+`=-[]\\{}|;'\",./<>?"
  
  func filterOut(_ charsToRemove: String) -> String {
    return self.rawValue.filter { !charsToRemove.contains($0) }
  }
}

// TODO: - Move this extension into another file called String+appendingOverload.
// May need to change the signature to appending<T: RawRepresentable>(_:T) -> String
extension String {
  func appending<T: RawRepresentable>(_ rawRepresentable: T) -> String where T.RawValue == String {
    return self.appending(rawRepresentable.rawValue)
  }
  
  func appending(_ characterGroup: CharacterGroup) -> String {
    return self.appending(characterGroup.rawValue)
  }
}
