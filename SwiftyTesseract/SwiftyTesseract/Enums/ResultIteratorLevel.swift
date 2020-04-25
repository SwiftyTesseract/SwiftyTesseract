//
//  TesseractResultIteratorLevel.swift
//  SwiftyTesseract
//
//  Created by Antonio Zaitoun on 17/04/2020.
//  Copyright © 2020 Steven Sherry. All rights reserved.
//

import Foundation
import libtesseract

public enum ResultIteratorLevel: TessPageIteratorLevel.RawValue {
  /// RIL_BLOCK
  case block
  /// RIL_PARA
  case paragraph
  /// RIL_TEXTLINE
  case textline
  /// RIL_WORD
  case word
  /// RIL_SYMBOL
  case symbol

  public var tesseractLevel: TessPageIteratorLevel {
    return TessPageIteratorLevel(rawValue: self.rawValue)
  }
}
