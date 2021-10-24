//
//  HomeView.swift
//  HomeView
//
//  Created by Michael Horowitz on 8/25/21.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject var preferences: UserPreferences
  @State private var settingsPresented = false
  let columns: [GridItem] = [GridItem(.adaptive(minimum: 140))]
  var onTypes: [String] {
    preferences.types.filter { preferences.typesOn[$0] == true }
  }
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(preferences.onTypes) {
            HomeViewItem(item: $0.type, symbol: typesToSymbol[$0.type] ?? "", color: preferences.themeColor, destinationView: typeToView($0.type))
              .padding(.horizontal, 5)
          }
        }
        .padding(.horizontal, 10)
      }
      .navigationBarTitle("Random")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            print("pressed")
            settingsPresented = true
          } label: {
            Image(systemName: "gear")
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(preferences.themeColor)
          }
          .sheet(isPresented: $settingsPresented) {
            SettingsMenu()
          }
        }
      }
    }
    .navigationViewStyle(.stack)
    .accentColor(preferences.themeColor)
  }
  @ViewBuilder
  func typeToView(_ type: String) -> some View {
    switch type {
    case "Number": NumberGenerator()
    case "Coin": CoinFlipper()
    case "Card": CardRandomizer()
    case "Date": DateGenerator()
    case "Map": MapGenerator()
    case "Lists": ListsGenerator()
    case "Color": ColorGenerator()
    case "Dice": DiceRandomizer()
    default: EmptyView()
    }
  }
  let typesToSymbol = [
    "Number": "number.square.fill",
    "Coin": "dollarsign.square.fill",
    "Card": "questionmark.square.fill",
    "Date": "calendar.badge.clock",
    "Map": "map.fill",
    "Lists": "list.bullet.rectangle.fill",
    "Color": "eyedropper.full",
    "Dice": "dice.fill"
  ]
}

private struct HomeViewItem<Content: View>: View {
  let item: String
  let symbol: String
  let color: Color
  let destinationView: Content
  var body: some View {
    NavigationLink {
      destinationView
    } label: {
      ZStack {
        VStack {
          HStack {
            Spacer()
            Image(systemName: symbol)
              .font(.title2)
          }
          Spacer()
        }
        .padding([.trailing, .top], 5)
        Text(item)
          .font(.title)
          .fontWeight(.semibold)
      }
      .foregroundColor(color.isLight ? .black : .white)
      .frame(height: 100)
      .frame(maxWidth: .infinity)
    }
    .background(color)
    .cornerRadius(10)
  }
}
