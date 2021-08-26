//
//  HomeView.swift
//  HomeView
//
//  Created by Michael Horowitz on 8/25/21.
//

import SwiftUI

struct HomeView: View {
  let types = ["Number", "Word", "Card", "Coin", "Date", "Password"]
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          ForEach(0..<(types.count+1)/2) { num in
            HStack(spacing: 20) {
              HomeViewItem(item: types[num], destinationView: AnyView(typeToView[types[num]]))
              if num+1 < types.count {
                HomeViewItem(item: types[num+1], destinationView: AnyView(typeToView[types[num+1]]))
              }
            }
            .padding([.leading, .trailing])
          }
        }
      }
      .navigationBarTitle("Random")
    }
  }
  let typeToView = ["Number":NumberGenerator()]
}

private struct HomeViewItem: View {
  let item: String
  var color: Color = .blue
  let destinationView: AnyView
  var body: some View {
    NavigationLink {
      destinationView
    } label: {
      Text(item)
        .font(.title)
        .fontWeight(.semibold)
        .foregroundColor(color.isLight ? .black : .white)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
    .background(color)
    .cornerRadius(15)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
