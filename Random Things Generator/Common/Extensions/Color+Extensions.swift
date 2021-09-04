//
//  Color+Extensions.swift
//  Color+Extensions
//
//  Created by Michael Horowitz on 8/25/21.
//

import SwiftUI

extension Color {
  var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var o: CGFloat = 0
    UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
    return (r, g, b, o)
  }
  var isLight: Bool {
    let components = components
    let luminance = (0.299*components.red*255 + 0.587*components.green*255 + 0.114*components.blue*255)/255
    return luminance > 0.65
  }
  var hexWithOpacity: Int {
    let components = self.components
    let r = Int(components.red*255) << 24
    let g = Int(components.green*255) << 16
    let b = Int(components.blue*255) << 8
    let o = Int(components.opacity*255)
    return r+g+b+o
  }
  var hex: Int {
    let components = self.components
    let r = Int(components.red*255) << 16
    let g = Int(components.green*255) << 8
    let b = Int(components.blue*255)
    return r+b+g
  }
  init(hex: Int, includesOpacity: Bool = false) {
    if includesOpacity {
      let r = CGFloat((hex & 0xff000000) >> 24) / 255
      let g = CGFloat((hex & 0x00ff0000) >> 16) / 255
      let b = CGFloat((hex & 0x0000ff00) >> 8) / 255
      let o = CGFloat(hex & 0x000000ff) / 255
      self.init(.sRGB, red: r, green: g, blue: b, opacity: o)
    } else {
      let r = CGFloat((hex & 0xff0000) >> 16) / 255
      let g = CGFloat((hex & 0x00ff00) >> 8) / 255
      let b = CGFloat((hex & 0x0000ff)) / 255
      self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
  }
    var data: Data {
      try! NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false)
    }
    static func withData(_ data: Data) -> Color? {
      guard let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor else { return nil }
      return Color(uiColor)
    }
  enum html {
    static let dodgerBlue = Color(hex: 0x1E90FF)
    static let crimson = Color(hex: 0xDC143C)
    static let hotPink = Color(hex: 0xFF69B4)
    static let darkOrange = Color(hex: 0xFF8C00)
    static let gold = Color(hex: 0xFFD700)
    static let mediumPurple = Color(hex: 0x9370DB)
    static let mediumSeaGreen = Color(hex: 0x3CB371)
    static let rosyBrown = Color(hex: 0xBC8F8F)
    static let mintBlue = Color(hex: 0x48ABA9)
  }
}
