//
//  Tesseract+Error.swift
//  
//
//  Created by Steven Sherry on 7/15/20.
//

import Foundation

extension Tesseract {
  public struct Error: Swift.Error, Equatable {
    public let message: String

    public init(_ message: String) {
      self.message = message
    }

    public static let imageConversionError = Error(
      "The image provided was unable to " +
      "be converted to it's Data representation"
    )
    public static let unableToExtractTextFromImage = Error(
      "Tesseract was unable to extract any text from the image. " +
      "Make sure you have provided a valid image."
    )

    public static let unableToRetrieveIterator = Error(
      "A result iterator was unable to be retrieved"
    )

    static let noLanguagesErrorMessage = "SwiftyTesseract must be initialized with at least one language"
    static let initializationErrorMessage = "Initialization of SwiftyTesseract has failed. " +
    "Check that the tessdata folder has been added to the project as a folder reference " +
    "and contains the correct .traineddata files for the specified engine mode and language(s)."
  }
}
