//
//  Collection+Extensions.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/24/21.
//

import Foundation

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
