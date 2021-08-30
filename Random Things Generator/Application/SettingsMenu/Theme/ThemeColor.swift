//
//  ThemeColor.swift
//  ThemeColor
//
//  Created by Michael Horowitz on 8/27/21.
//

import SwiftUI

struct ThemeColor: View {
  let columns = [
    GridItem(.adaptive(minimum: 100), spacing: 20)
  ]
  let colors: [Color] = [.blue, .green, .red, .orange, .purple, .pink, .brown, .yellow, .mint, Color(uiColor: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1))]
  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 20) {
        ForEach(colors, id: \.self) {
          ThemeColorItem(color: $0)
        }
      }
      .padding(.horizontal)
      .navigationTitle("Theme")
    }
  }
}

private struct ThemeColorItem: View {
  let color: Color
  @EnvironmentObject var preferences: UserPreferences
  private var selectedColor: Bool {
    preferences.themeColor.hex == color.hex
  }
  var body: some View {
    RoundedRectangle(cornerRadius: 15)
      .fill(color)
      .aspectRatio(1, contentMode: .fit)
      .scaleEffect(selectedColor ? 1.05 : 1)
      .shadow(color: selectedColor ? Color(uiColor: .label).opacity(0.2) : .clear, radius: 10, x: 10, y: 10)
      .shadow(color: selectedColor ? Color(uiColor: .systemBackground).opacity(0.7) : .clear, radius: 10, x: -5, y: -5)
      .overlay(
        VStack {
          HStack {
            Spacer()
            if selectedColor {
              Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
                .padding([.top, .trailing], 8)
            }
          }
          Spacer()
        })
      .onTapGesture {
        withAnimation(.easeIn(duration: 0.1)) {
          preferences.themeColor = color
        }
      }
  }
}
