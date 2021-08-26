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
        return luminance > 0.5
    }
}
