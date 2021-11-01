//
//  GeneratorLists.swift
//  GeneratorLists
//
//  Created by Michael Horowitz on 9/4/21.
//

import SwiftUI

struct GeneratorLists: View {
  @FetchRequest(entity: GeneratorList.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \GeneratorList.dateCreated, ascending: false)], predicate: nil, animation: .linear(duration: 0.4)) var lists: FetchedResults<GeneratorList>
  @State private var coreDataRefreshID = UUID()
  @State private var addList = false
  @State private var editList: GeneratorList?
  @State private var changeItemSelected = false
  @State private var changeItem: GeneratorList?
  @Environment(\.managedObjectContext) var moc
  @EnvironmentObject var preferences: UserPreferences
  
  var selectedLists: [GeneratorList] {
    let generatorLists = lists.filter({ currentLists.contains($0.id ?? UUID()) })
    return generatorLists
  }
  var unselectedLists: [GeneratorList] {
    let generatorLists = lists.filter({ !(selectedLists.contains($0)) })
    return generatorLists
  }
  @Binding var currentLists: [UUID]
  @State var deleteList: GeneratorList?
  init(currentLists: Binding<[UUID]>) {
    _currentLists = currentLists
  }
  
  var body: some View {
    List {
      if selectedLists.count > 0 {
        Section {
          ForEach(selectedLists) { selectedList in
            SelectedListItem(selectedList: selectedList, editList: $editList, currentLists: $currentLists)
          }
          .onDelete { indexSet in
            for index in indexSet {
              let item = lists[index]
              moc.delete(item)
              try? moc.save()
            }
          }
        } header: {
          Text("Selected Lists")
        }
      }
      Section {
        ForEach(unselectedLists, id: \.self) { unselectedList in
          UnselectedListItem(unselectedList: unselectedList, editList: $editList, deleteList: $deleteList, currentLists: $currentLists)
        }
      } footer: {
        if #available(iOS 15, *) {
          Text("Swipe to the left to select the list or edit the list. Swipe to the right to delete the list.")
        } else {
//          Text("Hold for options")
        }
      }
    }
    .id(coreDataRefreshID)
    .environment(\.editMode, Binding.constant(EditMode.inactive))
    .sheet(item: $changeItem, content: { item in
      VStack {
        Button {
          if let id = item.id {
            withAnimation {
              if changeItemSelected {
                currentLists = currentLists.filter({ $0 != id })
              } else {
                currentLists.append(id)
              }
            }
          }
        } label: {
          Text(changeItemSelected ? "Unselect" : "Select")
        }
        Button {
          editList = item
        } label: {
          Text("Edit")
        }
        if !changeItemSelected {
          Button {
            deleteList = item
          } label: {
            Text("Delete")
              .padding(.horizontal)
              .padding(5)
          }

        }
      }
    })
//    .alert(isPresented: $changeItem, content: {
//      alert(<#T##titleKey: LocalizedStringKey##LocalizedStringKey#>, isPresented: <#T##Binding<Bool>#>, actions: <#T##() -> View#>)
//    })
    .alert(item: $deleteList) { item in
      Alert(title: Text("Delete List"), message: Text("Are you sure you want to delete this list?"), primaryButton: Alert.Button.destructive(Text("Delete"), action: {
        withAnimation {
          moc.delete(item)
          try? moc.save()
        }
      }), secondaryButton: Alert.Button.cancel(Text("Cancel"), action: {
        deleteList = nil
      }))
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          print("add list")
          addList = true
        } label: {
          Image(systemName: "plus")
        }
        .sheet(isPresented: $addList) {
          AddList()
            .environmentObject(preferences)
        }
      }
    }
    
    .sheet(item: $editList, onDismiss: {
      coreDataRefreshID = UUID()
    }) { item in
      EditListTitle(list: item)
        .environmentObject(preferences)
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
                .foregroundColor(.red)
//                .tint(.red)
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
      .alert(isPresented: $duplicateItem, content: {
        Alert(title: Text("Error"), message: Text("An item with this title already exists."), dismissButton: .cancel(Text("OK")))
      })
//      .alert("Error", isPresented: $duplicateItem) {
//        Button("OK", role: .cancel) {}
//      } message: {
//        Text("An Item with this title already exists.")
//      }
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

private struct SelectedListItem: View {
  let selectedList: GeneratorList
  @Binding var editList: GeneratorList?
  @Binding var currentLists: [UUID]
  var body: some View {
    if #available(iOS 15.0, *) {
      NavigationLink {
        EditList(list: selectedList)
      } label: {
        GeometryReader { geo in
          HStack {
            Circle()
              .fill(Color.withData(selectedList.color ?? Color.clear.data)!)
              .frame(width: geo.size.height, height: geo.size.height)
            Text(selectedList.title ?? "Unknown")
            Spacer()
          }
        }
      }
      .swipeActions(edge: .leading, allowsFullSwipe: true) {
        Button {
          if let id = selectedList.id {
            withAnimation {
              currentLists = currentLists.filter({ $0 != id })
            }
          }
        } label: {
          Text("Deselect")
        }
        .tint(.green)
        Button {
          editList = selectedList
        } label: {
          Text("Edit")
        }
      }
    } else {
      NavigationLink {
        EditList(list: selectedList)
      } label: {
        GeometryReader { geo in
          HStack {
            Circle()
              .fill(Color.withData(selectedList.color ?? Color.clear.data)!)
              .frame(width: geo.size.height, height: geo.size.height)
            Text(selectedList.title ?? "Unknown")
            Spacer()
          }
        }
      }
    }
  }
}

private struct UnselectedListItem: View {
  let unselectedList: GeneratorList
  @Binding var editList: GeneratorList?
  @Binding var deleteList: GeneratorList?
  @Binding var currentLists: [UUID]
  var body: some View {
    if #available(iOS 15.0, *) {
      NavigationLink (destination: {
        EditList(list: unselectedList)
      }, label: {
        GeometryReader { geo in
          HStack {
            Circle()
              .fill(Color.withData(unselectedList.color ?? Color.clear.data)!)
              .frame(width: geo.size.height, height: geo.size.height)
            Text(unselectedList.title ?? "Unknown")
            Spacer()
          }
          
        }
      })
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
          Button {
            if let id = unselectedList.id {
              withAnimation {
                currentLists.append(id)
              }
            }
          } label: {
            Text("Select")
          }
          .tint(.green)
          Button {
            editList = unselectedList
          } label: {
            Text("Edit")
          }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          Button {
            deleteList = unselectedList
          } label: {
            Text("Delete")
          }
          .tint(.red)
        }
    } else {
      NavigationLink (destination: {
        EditList(list: unselectedList)
      }, label: {
        GeometryReader { geo in
          HStack {
            Circle()
              .fill(Color.withData(unselectedList.color ?? Color.clear.data)!)
              .frame(width: geo.size.height, height: geo.size.height)
            Text(unselectedList.title ?? "Unknown")
            Spacer()
          }
        }
      })
    }
  }
}
