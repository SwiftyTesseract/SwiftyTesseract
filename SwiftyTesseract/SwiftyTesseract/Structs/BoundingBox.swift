//
//  BoundingBox.swift
//  SwiftyTesseract
//
//  Created by Antonio Zaitoun on 19/04/2020.
//  Copyright © 2020 Steven Sherry. All rights reserved.
//

import Foundation

struct BoundingBox {
  var x1: Int32 = 0
  var x2: Int32 = 0
  var y1: Int32 = 0
  var y2: Int32 = 0

  var cgRect: CGRect {
    return CGRect(
      x: .init(x1),
      y: .init(y1),
      width: .init(x2 - x1),
      height: .init(y2 - y1)
    )
  }
}
