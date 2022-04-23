//
//  SearchView.swift
//  UI-548
//
//  Created by nyannyan0328 on 2022/04/23.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @StateObject var locationManger : LocationManager = .init()
    @State var navigationTag : String?
    var body: some View {
        VStack{
            
            HStack{
                
                Button {
                    
                } label: {
                    
                    Image(systemName: "arrow.left")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.black)
                }
                
                Text("Search Locations")
                    .font(.subheadline.weight(.black))
                    .foregroundColor(.gray)

            }
            .lLeading()
            
            
            
            HStack{
                
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                TextField("Search Locations", text: $locationManger.searchText)
                
            }
            .padding(.vertical,15)
            .padding(.horizontal)
            .background{
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.blue,lineWidth: 2)
            }
            
            
            if let places = locationManger.fetchPlaces,!places.isEmpty{
                
                
                List{
                    
                    ForEach(places,id:\.self){place in
                        
                        Button {
                            
                            
                            if let coordinate = place.location?.coordinate{
                                
                                locationManger.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                locationManger.addDraggingPin(coordinate: coordinate)
                                locationManger.updatePlaceMark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                                navigationTag = "TABVIEW"
                                
                            }
                            locationManger.searchText = ""
                            
                            
                           
                            
                        } label: {
                            
                            HStack{
                                
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    
                                    Text(place.name ?? "")
                                        .font(.callout.weight(.semibold))
                                    
                                    Text(place.locality ?? "")
                                        .font(.subheadline.weight(.light))
                                }
                            }
                          
                        }

                        
                        
                    }
                    
                }
                .listStyle(.plain)
                
                
                
            }
            
            else{
               
                
                
                Button {
                    
                    if let coordinate = locationManger.userLocations?.coordinate{
                        
                        locationManger.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                        locationManger.addDraggingPin(coordinate: coordinate)
                        locationManger.updatePlaceMark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                       
                        
                    }
                    
                    navigationTag = "TABVIEW"
                    locationManger.searchText = ""
                        
                    
                } label: {
                    
                    Label {
                        
                        Text("Use Current Location")
                            .fontWeight(.black)
                        
                    } icon: {
                        
                        Image(systemName: "location.north.circle.fill")
                    }
                  
                    .foregroundColor(.green)
                    .lLeading()

                }
                .padding(.vertical)
                
            }
            
            
          
            

            
        }
        .padding()
        .maxTop()
       
        .background{
            
            NavigationLink(tag: "TABVIEW", selection: $navigationTag) {
                
                
                MapViewSelection()
                    .environmentObject(locationManger)
                    .navigationBarHidden(true)
                
            } label: {
            
            }
            .labelsHidden()

            
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MapViewSelection : View{
    
    @EnvironmentObject var locationManger : LocationManager
    @Environment(\.dismiss) var dissmiss
    var body: some View{
        
        ZStack{
            
            MapHelper()
                .environmentObject(locationManger)
                .ignoresSafeArea()
            
            
            Button {
                dissmiss()
            } label: {
                
                
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
            }
            .padding()
            .maxTopLeading()
            
            if let place = locationManger.pickedPlaceMark{
                
                VStack(spacing:15){
                    
                    Text("Confirm Location")
                        .font(.largeTitle)
                    
                    HStack{
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            
                            Text(place.name ?? "")
                                .font(.callout.weight(.semibold))
                            
                            Text(place.locality ?? "")
                                .font(.subheadline.weight(.light))
                        }
                        .lLeading()
                    }
                    
                    Button {
                        
                    } label: {
                        
                        Text("Confirm Location")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.vertical,17)
                            .padding(.horizontal)
                            .lCenter()
                            .background{
                                
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.green)
                            }
                            .overlay(alignment: .trailing) {
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                    .padding(.trailing,16)
                            }
                           
                    }

                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .ignoresSafeArea()
                
                )
               
                .maxBottom()
              
               
                
            }

            
        }
       
       
        .onDisappear {


        }
    }
}

struct MapHelper : UIViewRepresentable{
    
    @EnvironmentObject var locationManger : LocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        
        return locationManger.mapView
        
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
}
