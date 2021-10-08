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
//  var list: GeneratorList? {
//    var list = lists.first { generatorList in
//      generatorList.title == currentList
//    }
//    if list == nil {
//      list = lists.first
//      currentList = list?.title ?? ""
//    }
//    return list
//  }
  var selectedLists: [GeneratorList] {
    lists.filter { generatorList in
      if let id = generatorList.id {
        return currentLists.contains(id)
      }
      return false
    }
  }
//  @AppStorage("currentList") var currentList: String = ""
  @State var currentLists = [UUID]()
  init() {
    if let currentLists = UserDefaults.standard.array(forKey: "currentLists") as? [String] {
      var uuids = [UUID]()
      for string in currentLists {
        if let uuid = UUID(uuidString: string) {
          uuids.append(uuid)
        }
      }
      self._currentLists = State(initialValue: uuids)
    }
  }
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
    RandomGeneratorView("Lists") {
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
      guard let list = selectedLists.randomElement() else { return }
      guard let title = list.title else { return }
      guard let item = (list.items?.allObjects as? [ListItem])?.randomElement() else { return }
      guard let itemName = item.itemName else { return }
      randomItem = itemName
      let coreDataItem = Random(context: moc)
      coreDataItem.id = list.id
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
    .onChange(of: currentLists, perform: { newValue in
      UserDefaults.standard.set(newValue.map({$0.uuidString}), forKey: "currentLists")
    })
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
      
      RandomHistory(randomType: "Lists", customPredicate: idPredicate, isCustomList: true, formatValue: nil)
        .settings {
          Section {
            NavigationLink {
              GeneratorLists(currentLists: $currentLists)
            } label: {
              Text("Selected List")
            }
            NavigationLink {
              HatPicker(items: allItemsInLists)
            } label: {
              Text("Pick from hat")
            }
          } header: {
            Text("Options")
          }
        }
    }
    .sheet(isPresented: $showsSettings) {
      GeneratorLists(currentLists: $currentLists)
    }
  }
  var allItemsInLists: [String] {
    var items = [String]()
    selectedLists.forEach { generatorList in
      let list = generatorList.items?.allObjects as? [ListItem]
      list?.forEach({ listItem in
        if let itemName = listItem.itemName {
          items.append(itemName)
        }
      })
    }
    return items
  }
  var idPredicate: NSPredicate {
    var predicates = [NSPredicate]()
    for id in currentLists {
      let predicate = NSPredicate(format: "id == %@", id as CVarArg)
      predicates.append(predicate)
    }
    let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    return compoundPredicate
  }
//  var selectedListNames: String {
//    let selectedListNames: [String] = selectedLists.map { generatorList in
//      if let title = generatorList.title {
//        return title
//      }
//      return "
//    }
//    return selectedListNames.joined(separator: "\n")
//  }
}
