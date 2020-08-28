//
//  LanguageModelDataSource.swift
//  SwiftyTesseract
//
//  Created by Antonio Zaitoun on 17/04/2020.
//  Copyright © 2020 Steven Sherry. All rights reserved.
//

import Foundation

public protocol LanguageModelDataSource {
  var pathToTrainedData: String { get }
}

extension Bundle: LanguageModelDataSource {
  public var pathToTrainedData: String {
    #if os(macOS) || targetEnvironment(macCatalyst)
    let xcodePath = bundleURL
      .appendingPathComponent("Contents")
      .appendingPathComponent("Resources")
      .appendingPathComponent("tessdata")
      .path
    
    if FileManager.default.fileExists(atPath: xcodePath) {
      return xcodePath
    } else {
      return bundleURL.appendingPathComponent("tessdata").path
    }
    #else
    return bundleURL.appendingPathComponent("tessdata").path
    #endif
  }
}
