//
//  BoundingBox.swift
//  SwiftyTesseract
//
//  Created by Antonio Zaitoun on 19/04/2020.
//  Copyright © 2020 Steven Sherry. All rights reserved.
//

import Foundation

struct BoundingBox {
  var originX: Int32 = 0
  var originY: Int32 = 0
  var widthOffset: Int32 = 0
  var heightOffset: Int32 = 0

  var cgRect: CGRect {
    return CGRect(
      x: .init(originX),
      y: .init(originY),
      width: .init(widthOffset - originX),
      height: .init(heightOffset - originY)
    )
  }
}
