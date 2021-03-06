//
//  ListsGenerator.swift
//  ListsGenerator
//
//  Created by Michael Horowitz on 9/4/21.
//

import SwiftUI

class CurrentLists: ObservableObject {
  @Published var lists = [UUID]() {
    didSet {
      UserDefaults.standard.set(lists.map({$0.uuidString}), forKey: "currentLists")
    }
  }
  
  init() {
    if let currentLists = UserDefaults.standard.array(forKey: "currentLists") as? [String] {
      var uuids = [UUID]()
      for string in currentLists {
        if let uuid = UUID(uuidString: string) {
          uuids.append(uuid)
        }
      }
      self.lists = uuids
    }
  }
}

struct ListsGenerator: View {
  @EnvironmentObject var preferences: UserPreferences
  @Environment(\.managedObjectContext) var moc
  @FetchRequest(entity: GeneratorList.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \GeneratorList.dateCreated, ascending: false)], predicate: nil, animation: nil) var lists: FetchedResults<GeneratorList>
  var selectedLists: [GeneratorList] {
    lists.filter { generatorList in
      if let id = generatorList.id {
        return currentLists.lists.contains(id)
      }
      return false
    }
  }
  @ObservedObject var currentLists = CurrentLists()
  @State private var randomItem = "?"
  @State private var scale: CGFloat = 1
  @State private var showsAlert = false
  @State private var showsHistory = false
  @State private var showsSettings = false
  var body: some View {
    RandomGeneratorView("Lists", isCustomList: true) {
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
//    .onRandomPressed {
//      guard let list = selectedLists.randomElement() else { return }
//      guard let title = list.title else { return }
//      guard let item = (list.items?.allObjects as? [ListItem])?.randomElement() else { return }
//      guard let itemName = item.itemName else { return }
//      randomItem = itemName
//      let coreDataItem = Random(context: moc)
//      coreDataItem.id = list.id
//      coreDataItem.randomType = title
//      coreDataItem.timestamp = Date()
//      coreDataItem.value = itemName
//      item.lastShown = Date()
//      item.timesShown += 1
//      item.list?.totalTimes += 1
//      try? moc.save()
//    }
    .customHistoryPredicate(idPredicate)
    .settingsPresentedContent({
      Section {
        NavigationLink {
          GeneratorLists(currentLists: $currentLists.lists)
        } label: {
          Text("Selected List")
        }
        let allItems = allItemsInLists
        if !allItems.isEmpty {
          NavigationLink {
            HatPicker(items: allItems)
          } label: {
            Text("Pick from hat")
          }
        }
      } header: {
        Text("Options")
      }
    })
    .generateRandom({
      let allItems = allItemsInLists
      if allItems.isEmpty {
        return nil
      } else {
        return {
          allItems.randomElement()!
        }
      }
    })
    .generateRandomArray({
      return { allItemsInLists }
    })
    .onRandomSuccess({ result in
      let allItems = allItemsWithParent
      let filteredLists = allItems.filter({ $0.0 == result })
      guard let list = filteredLists.randomElement()?.1 else { return }
      guard let title = list.title else { return }
      guard let item = (list.items?.allObjects as? [ListItem])?.first(where: { $0.itemName == result }) else { return }
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
    })
  }
  var allItemsWithParent: [(String, GeneratorList)] {
    var items = [(String, GeneratorList)]()
    selectedLists.forEach { generatorList in
      let list = generatorList.items?.allObjects as? [ListItem]
      list?.forEach({ listItem in
        guard let itemName = listItem.itemName else { return }
        guard let parentList = listItem.list else { return }
        items.append((itemName, parentList))
      })
    }
    return items
//    selectedLists.compactMap { list in
//      (list.items?.allObjects as? [ListItem])?.compactMap({ listItem in
//        return (listItem.itemName ?? "", listItem.list ?? GeneratorList())
//      })
//        listItemArray.map { listItem in
//          if let itemName = listItem.itemName {
//            return (itemName, itemName.parent)
//          }
//        }
//    }
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
    for id in currentLists.lists {
      let predicate = NSPredicate(format: "id == %@", id as CVarArg)
      predicates.append(predicate)
    }
    let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    return compoundPredicate
  }
}
