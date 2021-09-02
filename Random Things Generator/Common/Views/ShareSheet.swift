//
//  ShareSheet.swift
//  ShareSheet
//
//  Created by Michael Horowitz on 9/1/21.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
  
  let activityItems: [Any]
  let applicationActivities: [UIActivity]? = nil
  func makeUIViewController(context: Context) -> UIActivityViewController {
    let activity = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    activity.modalPresentationStyle = .pageSheet
    return activity
  }
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    
  }
}
