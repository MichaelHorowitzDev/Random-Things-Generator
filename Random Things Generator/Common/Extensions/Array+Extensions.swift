//
//  Array+Extensions.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/10/21.
//

import Foundation

extension Array where Element: Hashable {
  func mostCommon() -> [Common<Element>] {
    var dictionary: [Self.Element:Int] = [:]
    self.forEach { element in
      dictionary[element, default: 0] += 1
    }
    let sortedDict = dictionary.sorted { first, second in
      first.value > second.value
    }
    let sorted = sortedDict.map { item in
      Common(item: item.key, num: item.value)
    }
    return sorted
  }
  func leastCommon() -> [Common<Element>] {
    var dictionary: [Self.Element:Int] = [:]
    self.forEach { element in
      dictionary[element, default: 0] += 1
    }
    let sortedDict = dictionary.sorted { first, second in
      second.value > first.value
    }
    let sorted = sortedDict.map { item in
      Common(item: item.key, num: item.value)
    }
    return sorted
  }
}

struct Common<T: Hashable>: Hashable {
  let item: T
  let num: Int
}
