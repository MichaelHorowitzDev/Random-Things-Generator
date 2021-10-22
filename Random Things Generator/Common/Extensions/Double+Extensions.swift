//
//  Double+Extensions.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/21/21.
//

import Foundation

extension Double {
  func trim(fractionDigits: Int) -> String? {
    if fractionDigits < 0 { return nil }
    var numArray = self.description.split(separator: ".").map { String($0) }
    if numArray.count != 2 { return nil }
    numArray[1] = numArray[1].maximumLength(fractionDigits)
    return numArray.joined(separator: ".")
  }
}
