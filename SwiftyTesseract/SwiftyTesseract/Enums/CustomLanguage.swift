//
//  CustomLanguage.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 4/30/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

/// To be used for loading custom Tesseract `.traineddata` files
public enum CustomLanguage {
  case existingLanguage(RecognitionLanguage)
  case customData(String)
}

extension CustomLanguage: LanguageStringConverter {
  static func createLanguageString(from languages: [CustomLanguage]) -> String {
    let languageString = languages.reduce("") { baseString, customLanguage in
      switch customLanguage {
      case .existingLanguage(let existing):
        return baseString.appending("\(existing.rawValue)+")
      case .customData(let custom):
        return baseString.appending("\(custom)+")
      }
    }
    
    return languageString.droppingLast()
  }
}


