//
//  DateGenerator.swift
//  DateGenerator
//
//  Created by Michael Horowitz on 8/29/21.
//

import SwiftUI

struct DateGenerator: View {
  @State private var startingDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
  @State private var endingDate = Date()
  @State private var randomDate = ""
  @State private var animationAmount: CGFloat = 1
  @EnvironmentObject var preferences: UserPreferences
  @Environment(\.colorScheme) var colorScheme
    var body: some View {
      ZStack {
        VStack {
          Text(randomDate)
            .foregroundColor(preferences.textColor)
            .font(.system(size: 40, weight: .medium, design: .rounded))
            .minimumScaleFactor(0.3)
            .lineLimit(1)
            .padding(.top, 40)
            .scaleEffect(animationAmount)
          Spacer()
        }
        .zIndex(1)
        VStack(spacing: 30) {
          DatePicker("Start", selection: $startingDate, in: ...Calendar.current.date(byAdding: .day, value: -1, to: endingDate)!, displayedComponents: .date)
            .datePickerStyle(.wheel)
            .tint(Color(uiColor: .secondaryLabel))
            .padding(.leading)
            .background(
              RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
          DatePicker("End", selection: $endingDate, in: startingDate..., displayedComponents: .date)
            .datePickerStyle(.wheel)
            .tint(Color(uiColor: .secondaryLabel))
            .padding(.leading)
            .background(
              RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
        .padding()
        .zIndex(1)
        .navigationTitle("Date")
        RandomGeneratorView {}
        .onRandomTouchDown {
          animationAmount = 0.97
        }
        .onRandomTouchUp {
          animationAmount = 1
        }
        .onRandomPressed {
          guard let days = Calendar.current.dateComponents([.day], from: startingDate, to: endingDate).day else { return }
          let randomDay = Int.random(in: 0...days)
          let randomDate = Calendar.current.date(byAdding: .day, value: randomDay, to: startingDate)!
          let formatter = DateFormatter()
          formatter.dateFormat = "MMMM dd, y"
          let formattedDate = formatter.string(from: randomDate)
          self.randomDate = formattedDate
        }
      }
      
    }
}

struct DateGenerator_Previews: PreviewProvider {
    static var previews: some View {
        DateGenerator()
    }
}
