//
//  TesseractResultIteratorLevel.swift
//  SwiftyTesseract
//
//  Created by Antonio Zaitoun on 17/04/2020.
//  Copyright © 2020 Steven Sherry. All rights reserved.
//

import Foundation
import libtesseract

/*
 RIL_BLOCK,
  RIL_PARA,
  RIL_TEXTLINE,
  RIL_WORD,
  RIL_SYMBOL
 */
public enum ResultIteratorLevel: Int{
    public typealias RawValue = Int


    case block
    case paragraph
    case textline
    case word
    case symbol

    public var asTessarctLevel: TessPageIteratorLevel {
        return TessPageIteratorLevel(rawValue: UInt32(self.rawValue))
    }
}

