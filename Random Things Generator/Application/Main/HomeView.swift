//
//  HomeView.swift
//  HomeView
//
//  Created by Michael Horowitz on 8/25/21.
//

import SwiftUI

struct HomeView: View {
  let types = ["Number", "Card", "Dice", "Coin", "Color", "Date", "Map", "Lists"]
  @EnvironmentObject var preferences: UserPreferences
  @State private var settingsPresented = false
  let columns: [GridItem] = [GridItem(.adaptive(minimum: 140))]
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(0..<types.count) { num in
            HomeViewItem(item: types[num], color: preferences.themeColor, destinationView: typeToView(types[num]))
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
}

private struct HomeViewItem<Content: View>: View {
  let item: String
  let color: Color
  let destinationView: Content
  var body: some View {
    NavigationLink {
      destinationView
    } label: {
      ZStack {
//        VStack {
//          HStack {
//            Spacer()
//            Image(systemName: symbol)
//              .font(.title2)
//          }
//          Spacer()
//        }
//        .padding([.trailing, .top], 5)
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
