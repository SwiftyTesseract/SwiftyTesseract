//
//  CustomLanguage.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 4/30/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

/// To be used for loading custom Tesseract `.traineddata` files
public enum CustomLanguage {
  /// Available if existing language data needs to be used in tandem with
  /// customData
  case existingLanguage(RecognitionLanguage)
  /// Takes the filename of the `.traineddata` file as its value
  ///
  /// Example: if the `.traineddata` file is named klingon.traineddata
  /// then `customData` be defined as `.customData("klingon")`
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


