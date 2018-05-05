//
//  LanguageStringConverter.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 4/30/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

protocol LanguageStringConverter {
  associatedtype LanguageType
  
  static func createLanguageString(from languages: [LanguageType]) -> String
}
