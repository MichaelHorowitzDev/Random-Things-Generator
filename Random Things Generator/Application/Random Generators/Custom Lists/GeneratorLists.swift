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
  var body: some View {
    List {
      ForEach(lists, id: \.self) { list in
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
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          addList = true
        } label: {
          Image(systemName: "plus")
        }
      }
    }
    .sheet(isPresented: $addList) {
      AddList()
    }
    .navigationTitle("Lists")
  }
}
struct EditList: View {
  var items: [ListItem]
  let title: String
  let color: Color?
  init(list: GeneratorList) {
    self.items = list.wrappedItems
    self.title = list.title ?? "Unknown"
    if let data = list.color {
      self.color = Color.withData(data)
    } else {
      color = nil
    }
  }
  var body: some View {
    List {
      ForEach(items, id: \.self) { item in
        if item.itemName != nil {
          Text(item.itemName ?? "")
        } else {
          Image(systemName: "xmark.circle.fill")
            .tint(.red)
        }
      }
    }
    .navigationTitle(title)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          
        } label: {
          Image(systemName: "plus")
        }
      }
    }
  }
}
