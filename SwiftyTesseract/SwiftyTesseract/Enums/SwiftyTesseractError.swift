//
//  TesseractError.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/24/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

enum SwiftyTesseractError: Error {
  case imageConversionError
  case unableToCreateRenderer
  case unableToBeginDocument
  case unableToProcessPage
  case unableToEndDocument
  
  static let noLanguagesErrorMessage = "SwiftyTesseract must be initialized with at least one language"
  static let initializationErrorMessage = "Initialization of SwiftyTesseract has failed. " +
  "Check that the tessdata folder has been added to the project as a folder reference " +
  "and contains the correct .traineddata files for the specified engine mode and language(s)."
}
