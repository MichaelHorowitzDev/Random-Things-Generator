//
//  ColorGenerator.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/9/21.
//

import SwiftUI

struct ColorGenerator: View {
  @State private var hex = "?"
  @State private var scale: CGFloat = 1
  @State private var currentColor = Color.clear
  @Environment(\.managedObjectContext) var moc
    var body: some View {
      RandomGeneratorView("Color") {
        currentColor.ignoresSafeArea(.all, edges: .bottom)
        VStack {
          Text(hex)
            .font(.system(size: 50))
            .minimumScaleFactor(0.2)
            .lineLimit(1)
            .foregroundColor(currentColor.isLight ? .black : .white)
            .scaleEffect(scale)
            .padding(.horizontal, 30)
            .padding(.top, 20)
          Spacer()
        }
      }
      .onRandomTouchDown {
        scale = 0.9
      }
      .onRandomTouchUp {
        scale = 1
      }
      .onRandomPressed {
        currentColor = .random
        let hex = "#" + String(currentColor.hex, radix: 16, uppercase: true)
        self.hex = hex
        let coreDataItem = Random(context: moc)
        coreDataItem.randomType = "Color"
        coreDataItem.timestamp = Date()
        coreDataItem.value = hex
        try? moc.save()
      }
      .generateMultipleTimes({
        return {
          "#" + String(Color.random.hex, radix: 16, uppercase: true)
        }
      })
      .formatHistoryValue { value in
        if let hex = Int(value.filter {$0 != "#"}, radix: 16) {
          let color = Color(hex: hex)
          return AnyView(
            HStack {
              GeometryReader { geo in
                Circle()
                  .fill(color)
                  .frame(width: geo.size.height, height: geo.size.height)
              }
              .fixedSize(horizontal: true, vertical: false)
              Text(value)
                .font(.title2)
                .padding(.leading, 35)
            }
          )
        }
        return AnyView(Color.clear)
      }
    }
}

struct ColorGenerator_Previews: PreviewProvider {
    static var previews: some View {
        ColorGenerator()
    }
}
