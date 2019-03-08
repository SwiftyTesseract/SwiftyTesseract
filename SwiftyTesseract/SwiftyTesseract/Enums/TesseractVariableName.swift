//
//  TesseractVariableName.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/24/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

enum TesseractVariableName: String {
  case whiteList = "tessedit_char_whitelist"
  case blackList = "tessedit_char_blacklist"
  case tessDataPrefix = "TESSDATA_PREFIX"
  case preserveInterwordSpaces = "preserve_interword_spaces"
  case minimumCharacterHeight = "textord_min_xheight"
  case oldCharacterHeight = "textord_old_xheight"
}
