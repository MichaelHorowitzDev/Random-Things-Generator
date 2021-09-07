//
//  ListsGenerator.swift
//  ListsGenerator
//
//  Created by Michael Horowitz on 9/4/21.
//

import SwiftUI

struct ListsGenerator: View {
  @EnvironmentObject var preferences: UserPreferences
  @AppStorage("currentList") var currentList: String = UUID().uuidString
  @FetchRequest var list: FetchedResults<GeneratorList>
  init() {
    if let currentList = UserDefaults.standard.string(forKey: "currentList") {
      _list = FetchRequest(entity: GeneratorList.entity(), sortDescriptors: [], predicate: NSPredicate(format: "title == %@", currentList), animation: .default)
    } else {
      _list = FetchRequest(entity: GeneratorList.entity(), sortDescriptors: [], predicate: nil, animation: .default)
    }
  }
  @State private var randomItem = "?"
  @State private var scale: CGFloat = 1
  @State private var showsAlert = false
  @State private var showsHistory = false
  @State private var showsSettings = false
  var body: some View {
    RandomGeneratorView(list.first?.title ?? "") {
      Text(randomItem)
        .font(.system(size: 100))
        .minimumScaleFactor(0.2)
        .lineLimit(1)
        .foregroundColor(preferences.textColor)
        .scaleEffect(scale)
        .padding()
    }
    .onRandomTouchDown {
      scale = 0.9
    }
    .onRandomTouchUp {
      scale = 1
    }
    .onRandomPressed {
      randomItem = (list.first?.items?.allObjects as? [ListItem])?.randomElement()?.itemName ?? "?"
    }
    .onSettingsPressed {
      showsAlert = true
    }
    .alert("Select an Action", isPresented: $showsAlert) {
      Button("History", role: nil) {
        showsHistory = true
        print("ok")
        print("shows history")
        print(showsHistory)
      }
      Button("Settings", role: nil) {
        showsSettings = true
      }
    }
    .sheet(isPresented: $showsHistory) {
      RandomHistory(randomType: list.first?.title ?? "", formatValue: nil)
    }
    .sheet(isPresented: $showsSettings) {
      GeneratorLists()
    }

//    .presentsSettings(true)
  }
}

struct ListsGenerator_Previews: PreviewProvider {
    static var previews: some View {
        ListsGenerator()
    }
}
