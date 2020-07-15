//
//  Bundle+pathToTrainedData.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/24/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation

extension Bundle: LanguageModelDataSource {
  public var pathToTrainedData: String {
    #if os(macOS)
    return bundleURL
      .appendingPathComponent("Contents")
      .appendingPathComponent("Resources")
      .appendingPathComponent("tessdata")
      .path
    #else
    return bundleURL.appendingPathComponent("tessdata").path
    #endif
  }
}
