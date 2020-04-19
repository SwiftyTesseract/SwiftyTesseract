//
//  RecognizedBlock.swift
//  SwiftyTesseract
//
//  Created by Antonio Zaitoun on 17/04/2020.
//  Copyright © 2020 Steven Sherry. All rights reserved.
//

import Foundation

public struct RecognizedBlock {
  public var text: String
  public var boundingBox: CGRect
  public var confidence: Float
}
