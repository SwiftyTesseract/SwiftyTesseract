//
//  Bundle+pathToTrainedData.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/24/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation

extension Bundle {
  var pathToTrainedData: String {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    return documentsURL!.appendingPathComponent("tessdata").path
  }
}
