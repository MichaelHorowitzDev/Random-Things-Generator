//
//  BarChart.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/10/21.
//

import SwiftUI

struct BarChart<T>: View where T: Hashable {
  private let data: [T]
  private let mostCommon: [Common<T>]
  private let maximumNum: Int
  private let minimumNum: Int
  init(data: [T]) {
    self.data = data
    self.mostCommon = data.mostCommon()
    self.maximumNum = mostCommon.first?.num ?? 1
    self.minimumNum = mostCommon.last?.num ?? 0
  }
    var body: some View {
      GeometryReader { geo in
        HStack(alignment: .bottom, spacing: 3) {
          ForEach(mostCommon, id: \.self) { item in
            RoundedRectangle(cornerRadius: 10)
              .fill(.blue)
              .frame(height: geo.size.height*normalize(x: item.num))
          }
        }
        .padding(.horizontal)
      }
      .onAppear {
        print(mostCommon)
        mostCommon.forEach { item in
          print(normalize(x: item.num))
        }
      }
    }
  func normalize(x: Int) -> Double {
    normalizeValue(xMin: minimumNum, xMax: maximumNum, x: x)
  }
}

private func normalizeValue(xMin: Int, xMax: Int, x: Int) -> Double {
  let range = xMax - xMin
  let difference = x - xMin
  let normalizedValue = Double(difference) / Double(range)
  if normalizedValue.isNaN {
    return 1
  }
  return normalizedValue
}
