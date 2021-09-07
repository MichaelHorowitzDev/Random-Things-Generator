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
  }
}

struct ListsGenerator_Previews: PreviewProvider {
    static var previews: some View {
        ListsGenerator()
    }
}
