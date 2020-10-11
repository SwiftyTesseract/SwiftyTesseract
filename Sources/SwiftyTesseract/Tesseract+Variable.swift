//
//  Tesseract+Variable.swift
//  
//
//  Created by Steven Sherry on 7/15/20.
//

import Foundation

extension Tesseract {

  /// A representation of variables that can be set to the underlying Tesseract library
  public struct Variable: RawRepresentable {
    public init(rawValue: String) {
      self.init(rawValue)
    }

    public init(_ rawValue: String) {
      self.rawValue = rawValue
    }

    /// The variable name that corresponds to the underlying Tesseract variable
    public let rawValue: String
  }
}

extension Tesseract.Variable: ExpressibleByStringLiteral {
  public typealias StringLiteralType = String

  public init(stringLiteral value: String) {
    self.init(value)
  }
}

public extension Tesseract.Variable {
  static let allowlist: Tesseract.Variable = "tessedit_char_whitelist"
  static let disallowlist: Tesseract.Variable = "tessedit_char_blacklist"
  static let preserveInterwordSpaces: Tesseract.Variable = "preserve_interword_spaces"
  static let minimumCharacterHeight: Tesseract.Variable = "textord_min_xheight"
  static let oldCharacterHeight: Tesseract.Variable = "textord_old_xheight"
}
