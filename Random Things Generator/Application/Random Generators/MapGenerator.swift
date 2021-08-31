//
//  MapGenerator.swift
//  MapGenerator
//
//  Created by Michael Horowitz on 8/30/21.
//

import SwiftUI
import MapKit

struct MapGenerator: View {
  @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30))
  @State private var annotations = [MapPoint]()
  var body: some View {
    ZStack {
      Map(coordinateRegion: $region, annotationItems: annotations) {
        MapMarker(coordinate: $0.coordinate, tint: nil)
      }
        .ignoresSafeArea()
      VStack {
        Spacer()
        RandomizeButton("Randomize") {
          updateMap()
        }
      }
    }
  }
  func updateMap() {
      let longitude = Double.random(in: -179.9...179.9)
      let latitude = Double.random(in: -89.9...89.9)
      let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      let geoCoder = CLGeocoder()
      print(geoCoder)
      geoCoder.reverseGeocodeLocation(location) { placemarks, error in
        if error != nil {
          updateInterface()
          return
        }
        if placemarks?.count == 0 { updateMap(); return }
        for placemark in placemarks ?? [] {
          if placemark.ocean != nil { updateMap(); return }
        }
        updateInterface()
      }
    func updateInterface() {
      DispatchQueue.main.async {
        region.center = coordinate
        annotations = [MapPoint(coordinate: coordinate)]
      }
    }
  }
}
private struct MapPoint: Identifiable {
  let id = UUID()
  let coordinate: CLLocationCoordinate2D
}

struct MapGenerator_Previews: PreviewProvider {
    static var previews: some View {
        MapGenerator()
    }
}
