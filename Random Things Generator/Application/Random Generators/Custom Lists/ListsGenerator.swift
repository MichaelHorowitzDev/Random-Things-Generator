//
//  ListsGenerator.swift
//  ListsGenerator
//
//  Created by Michael Horowitz on 9/4/21.
//

import SwiftUI

struct ListsGenerator: View {
  @EnvironmentObject var preferences: UserPreferences
  @Environment(\.managedObjectContext) var moc
//  @AppStorage("currentList") var currentList: String = UUID().uuidString
  @FetchRequest(entity: GeneratorList.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \GeneratorList.dateCreated, ascending: false)], predicate: nil, animation: nil) var lists: FetchedResults<GeneratorList>
  var list: GeneratorList? {
    var list = lists.first { generatorList in
      generatorList.title == currentList
    }
    if list == nil {
      list = lists.first
      currentList = list?.title ?? ""
    }
    return list
  }
  @AppStorage("currentList") var currentList: String = ""
//  @FetchRequest var list: FetchedResults<GeneratorList>
//  init() {
//    if let currentList = UserDefaults.standard.string(forKey: "currentList") {
//      _list = FetchRequest(entity: GeneratorList.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \GeneratorList.dateCreated, ascending: false)], predicate: NSPredicate(format: "title == %@", currentList), animation: .default)
//    } else {
//      _list = FetchRequest(entity: GeneratorList.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \GeneratorList.dateCreated, ascending: false)], predicate: nil, animation: .default)
//    }
//    print("fgdsafdsa")
//    print(UserDefaults.standard.string(forKey: "currentList"))
//  }
  @State private var randomItem = "?"
  @State private var scale: CGFloat = 1
  @State private var showsAlert = false
  @State private var showsHistory = false
  @State private var showsSettings = false
  var body: some View {
    RandomGeneratorView(list?.title ?? "") {
      Text(randomItem)
        .font(.system(size: 100))
        .minimumScaleFactor(0.2)
        .lineLimit(1)
        .foregroundColor(preferences.textColor)
        .scaleEffect(scale)
        .padding(.horizontal, 30)
    }
    .onRandomTouchDown {
      scale = 0.9
    }
    .onRandomTouchUp {
      scale = 1
    }
    .onRandomPressed {
      guard let title = list?.title else { return }
      guard let item = (list?.items?.allObjects as? [ListItem])?.randomElement() else { return }
      guard let itemName = item.itemName else { return }
      randomItem = itemName
      let coreDataItem = Random(context: moc)
      coreDataItem.id = UUID()
      coreDataItem.randomType = title
      coreDataItem.timestamp = Date()
      coreDataItem.value = itemName
      item.lastShown = Date()
      item.timesShown += 1
      item.list?.totalTimes += 1
      try? moc.save()
    }
    .onSettingsPressed {
//      showsAlert = true
      showsHistory = true
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
      Button("Cancel", role: .cancel) {}
    }
    .sheet(isPresented: $showsHistory) {
      RandomHistory(randomType: list?.title ?? "", formatValue: nil)
        .settings {
          Section {
            NavigationLink {
              GeneratorLists()
            } label: {
              Text(list?.title ?? "")
            }
          } header: {
            Text("Selected List")
          }

        }
    }
    .sheet(isPresented: $showsSettings) {
      GeneratorLists()
    }
  }
}

struct ListsGenerator_Previews: PreviewProvider {
    static var previews: some View {
        ListsGenerator()
    }
}
