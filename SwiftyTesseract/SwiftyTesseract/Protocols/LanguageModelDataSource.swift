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
