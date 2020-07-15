//
//  BoundingBox.swift
//  SwiftyTesseract
//
//  Created by Antonio Zaitoun on 19/04/2020.
//  Copyright © 2020 Steven Sherry. All rights reserved.
//

public struct BoundingBox {
  public internal(set) var originX: Int32 = 0
  public internal(set) var originY: Int32 = 0
  public internal(set) var widthOffset: Int32 = 0
  public internal(set) var heightOffset: Int32 = 0
}

#if canImport(CoreGraphics)
import CoreGraphics

public extension BoundingBox {
  var cgRect: CGRect {
    return CGRect(
      x: .init(originX),
      y: .init(originY),
      width: .init(widthOffset - originX),
      height: .init(heightOffset - originY)
    )
  }
}
#endif
