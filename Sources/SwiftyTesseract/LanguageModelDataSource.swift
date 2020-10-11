//
//  LanguageModelDataSource.swift
//  SwiftyTesseract
//
//  Created by Antonio Zaitoun on 17/04/2020.
//  Copyright © 2020 Steven Sherry. All rights reserved.
//

import Foundation

/// Defines a way for Tesseract to locate the language training files to be consume
public protocol LanguageModelDataSource {

  /// Path for Tesseract to search for available languages
  var pathToTrainedData: String { get }
}

extension Bundle: LanguageModelDataSource {

  /// Path to `tessdata` folder in `Bundle`. Assumes `tessdata` folder is located at the `Bundle` root.
  public var pathToTrainedData: String {
    if let resourceUrl = resourceURL {
      // This means we're in a Mac app or Mac Catalyst app
      return resourceUrl.appendingPathComponent("tessdata").path
    } else {
      return bundleURL.appendingPathComponent("tessdata").path
    }
  }
}
