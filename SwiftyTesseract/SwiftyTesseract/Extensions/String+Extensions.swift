//
//  String+Extensions.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/24/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

extension String {
  init(tesseractString: TessString) {
    self.init(cString: tesseractString)
  }
  
  func droppingLast() -> String {
    return String(self.dropLast())
  }
  
}
