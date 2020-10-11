//
//  Tesseract+Variable.swift
//  
//
//  Created by Steven Sherry on 7/15/20.
//

import Foundation

extension Tesseract {
  public struct Variable: RawRepresentable {
    public init(rawValue: String) {
      self.init(rawValue)
    }

    public init(_ rawValue: String) {
      self.rawValue = rawValue
    }

    public let rawValue: String
  }
}

public extension Tesseract.Variable {
  static let allowlist = Tesseract.Variable("tessedit_char_whitelist")
  static let disallowlist = Tesseract.Variable("tessedit_char_blacklist")
  static let preserveInterwordSpaces = Tesseract.Variable("preserve_interword_spaces")
  static let minimumCharacterHeight = Tesseract.Variable("textord_min_xheight")
  static let oldCharacterHeight = Tesseract.Variable("textord_old_xheight")
}
