//
//  UIColor+Extensions.swift
//  UIColor+Extensions
//
//  Created by Michael Horowitz on 8/30/21.
//

import Foundation
import UIKit

extension UIColor {
  var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var o: CGFloat = 0
    self.getRed(&r, green: &g, blue: &b, alpha: &o)
    return (r, g, b, o)
  }
  var hex: Int {
    let components = self.components
    let r = Int(components.red*255) << 16
    let g = Int(components.green*255) << 8
    let b = Int(components.blue*255)
    return r+g+b
  }
  var hexWithOpacity: Int {
    let components = self.components
    let r = Int(components.red*255) << 24
    let g = Int(components.green*255) << 16
    let b = Int(components.blue*255) << 8
    let o = Int(components.opacity*255)
    return r+g+b+o
  }
  convenience init(hex: Int, includesOpacity: Bool = false) {
    if includesOpacity {
      let r = CGFloat((hex & 0xff000000) >> 24) / 255
      let g = CGFloat((hex & 0x00ff0000) >> 16) / 255
      let b = CGFloat((hex & 0x0000ff00) >> 8) / 255
      let o = CGFloat(hex & 0x000000ff) / 255
      self.init(red: r, green: g, blue: b, alpha: o)
    } else {
      let r = CGFloat((hex & 0xff0000) >> 16) / 255
      let g = CGFloat((hex & 0x00ff00) >> 8) / 255
      let b = CGFloat((hex & 0x0000ff)) / 255
      self.init(red: r, green: g, blue: b, alpha: 1)
    }
  }
}
