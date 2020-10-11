//
//  Tesseract+ConfigurationBuilder.swift
//  
//
//  Created by Steven Sherry on 7/15/20.
//

import Foundation
import libtesseract

extension Tesseract {
  @_functionBuilder
  public struct ConfigurationBuilder {
    public static func buildBlock(_ configurations: (TessBaseAPI) -> Void...) -> (TessBaseAPI) -> Void {
      return { tessPointer in
        configurations.forEach { $0(tessPointer) }
      }
    }
  }
}

/// For use in tadem with a `Tesseract.ConfigurationBuilder`. Used for setting `Tesseract` variables on initialization
/// or in it's configuration method.
/// - Parameters:
///   - variable: The Tesseract.Variable to set
///   - value: The value to set
/// - Returns: A function that takes a pointer to the  Tesseract instance and returns `Void`
public func set(_ variable: Tesseract.Variable, value: String) -> (TessBaseAPI) -> Void {
  return { tessPointer in
    TessBaseAPISetVariable(tessPointer, variable.rawValue, value)
  }
}

public extension String {
  /// Helper static extension on `String` for `true` for setting `Boolean` values on Tesseract variables
  static let `true` = "1"
  /// Helper static extension on `String` for `false` for setting `Boolean` values on Tesseract variables
  static let `false` = "0"
  /// Helper static extension on `String` for  setting integer values on Tesseract variables
  static func integer<A: BinaryInteger>(_ value: A) -> String {
    String(value)
  }
  /// Helper static extension on `String` for  setting double values on Tesseract variables
  static func double(_ value: Double) -> String {
    String(value)
  }
}
