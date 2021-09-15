//
//  GeneratorLists.swift
//  GeneratorLists
//
//  Created by Michael Horowitz on 9/4/21.
//

import SwiftUI

struct GeneratorLists: View {
  @FetchRequest(entity: GeneratorList.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \GeneratorList.dateCreated, ascending: false)], predicate: nil, animation: nil) var lists: FetchedResults<GeneratorList>
  @State private var addList = false
  @State private var changeSelectedList = false
  @Environment(\.managedObjectContext) var moc
  @EnvironmentObject var preferences: UserPreferences
  
  var selectedList: GeneratorList? {
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
  
  var body: some View {
    List {
      if selectedList != nil {
        Section {
          ForEach([selectedList!]) {_ in
            NavigationLink {
              EditList(list: selectedList!)
            } label: {
              GeometryReader { geo in
                HStack {
                  Circle()
                    .fill(Color.withData(selectedList!.color ?? Color.clear.data)!)
                    .frame(width: geo.size.height, height: geo.size.height)
                  Text(selectedList!.title ?? "Unknown")
                  Spacer()
                }
              }
            }
            .disabled(changeSelectedList)
          }
          .onDelete { indexSet in
            for index in indexSet {
              let item = lists[index]
              moc.delete(item)
              try? moc.save()
            }
          }
          
        } header: {
          Text("Selected List")
        }
      }
      ForEach(lists, id: \.self) { list in
        if list != selectedList {
          if changeSelectedList {
            GeometryReader { geo in
              Button {
                currentList = list.title ?? ""
                changeSelectedList = false
              } label: {
                HStack {
                  Circle()
                    .fill(Color.withData(list.color ?? Color.clear.data)!)
                    .frame(width: geo.size.height, height: geo.size.height)
                  Text(list.title ?? "Unknown")
                  Spacer()
                }
              }
            }
            
          } else {
            NavigationLink {
              EditList(list: list)
            } label: {
              GeometryReader { geo in
                HStack {
                  Circle()
                    .fill(Color.withData(list.color ?? Color.clear.data)!)
                    .frame(width: geo.size.height, height: geo.size.height)
                  Text(list.title ?? "Unknown")
                  Spacer()
                }
              }
            }
          }
        }
      }
      .onDelete { indexSet in
        for index in indexSet {
          let item = lists[index]
          moc.delete(item)
          try? moc.save()
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          addList = true
        } label: {
          Image(systemName: "plus")
        }
      }
      ToolbarItem(placement: .bottomBar) {
        Button {
          changeSelectedList.toggle()
        } label: {
          Text(changeSelectedList ? "Cancel" : "Change Selected List")
        }
      }
    }
    .sheet(isPresented: $addList) {
      AddList()
    }
    .navigationTitle("Lists")
    .accentColor(preferences.themeColor)
  }
}
struct EditList: View {
  @FetchRequest var items: FetchedResults<ListItem>
  let list: GeneratorList
  let title: String
  let color: Color?
  init(list: GeneratorList) {
    self.list = list
    let predicate = NSPredicate(format: "list == %@", list)
    _items = FetchRequest(entity: ListItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ListItem.dateCreated, ascending: false)], predicate: predicate, animation: .default)
    self.title = list.title ?? "Unknown"
    if let data = list.color {
      self.color = Color.withData(data)
    } else {
      color = nil
    }
  }
  @State private var showsTextField = false
  @State private var textString = ""
  @Environment(\.managedObjectContext) var moc
  @State private var duplicateItem = false
  var body: some View {
    ZStack {
      if showsTextField {
        TextFieldAlert(show: $showsTextField, title: "Add Item", message: nil, placeholder: "Name", onSubmit: { string in
          if items.contains(where: { $0.itemName == string }) {
            duplicateItem = true
          } else {
            if string != nil && string != "" {
              let listItem = ListItem(context: moc)
              listItem.list = list
              listItem.itemName = string
              listItem.dateCreated = Date()
              listItem.id = UUID()
              try? moc.save()
            }
          }
        })
      }
      List {
        ForEach(items, id: \.self) { item in
          NavigationLink {
            ListItemDetail(listItem: item)
          } label: {
            if item.itemName != nil {
              Text(item.itemName ?? "")
            } else {
              Image(systemName: "xmark.circle.fill")
                .tint(.red)
            }
          }
        }
        .onDelete { indexSet in
          for index in indexSet {
            let item = items[index]
            moc.delete(item)
            try? moc.save()
          }
        }
      }
      .alert("Error", isPresented: $duplicateItem) {
        Button("OK", role: .cancel) {}
      } message: {
        Text("An Item with this title already exists.")
      }
      .navigationTitle(title)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showsTextField = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
    }
  }
}
