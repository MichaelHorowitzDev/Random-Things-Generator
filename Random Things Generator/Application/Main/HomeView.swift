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
            VStack {
                ForEach(0..<(types.count+1)/2) { num in
                    HStack(spacing: 20) {
                        HomeViewItem(item: types[num])
                        if num+1 < types.count {
                            HomeViewItem(item: types[num+1])
                        }
                    }
                    .padding([.leading, .trailing])
                }
                Spacer()
            }
            .navigationBarTitle("Random")
        }
    }
}

private struct HomeViewItem: View {
    let item: String
    var color: Color = .blue
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(color)
            .frame(height: 100)
            .overlay(
                Text(item)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(color.isLight ? .black : .white)
                
            )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
