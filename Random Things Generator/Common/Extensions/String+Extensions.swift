//
//  String+Extensions.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/22/21.
//

import Foundation

extension String {
  func maximumLength(_ length: Int) -> String {
    if length < 1 {
      return ""
    } else if length >= self.count {
      return self
    } else {
      return self.removingLast(self.count - length)
    }
  }
  /// Returns an array with the specified number of elements removed from the end.
  func removingLast(_ k: Int) -> String {
    self.dropLast(k).map { $0.description }.joined()
  }
}
