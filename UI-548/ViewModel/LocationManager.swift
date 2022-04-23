//
//  LocationManager.swift
//  UI-548
//
//  Created by nyannyan0328 on 2022/04/23.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

class LocationManager:NSObject,ObservableObject,MKMapViewDelegate,CLLocationManagerDelegate {
   
    @Published var searchText : String = ""
    
    @Published var showAlert : Bool = false
    
    @Published var mapView : MKMapView = .init()
    @Published var manager : CLLocationManager = .init()
    
    @Published var fetchPlaces : [CLPlacemark]?
    
    
    var caseleble : AnyCancellable?
    
    @Published var userLocations : CLLocation?
    
    @Published var pickedLocation : CLLocation?
    @Published var pickedPlaceMark : CLPlacemark?
    
        
    override init() {
        
        super.init()
        mapView.delegate = self
        manager.delegate = self
        
        manager.requestWhenInUseAuthorization()
        
        caseleble = $searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: {[self] value in
                
                
                if value != ""{
                    
                    fetchRequest(value: value)
                }
                
                else{
                    
                    fetchPlaces = nil
                    
                    
                }
            })
        
    }
    
    func fetchRequest(value : String){
        
        Task{
            
            do{
                
                
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()
                let responce = try await MKLocalSearch(request: request).start()
                await MainActor.run(body: {
                    
                    self.fetchPlaces = responce.mapItems.compactMap({ item -> CLPlacemark? in
                        
                        return item.placemark
                    })
                    
                })
                
            }
            catch{}
        }
        
        
    }
    
    
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let currentLocation = locations.last else{return}
        
        self.userLocations = currentLocation
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        switch manager.authorizationStatus{

        case .authorizedAlways : manager.requestLocation()
        case .authorizedWhenInUse : manager.requestLocation()
        case .denied : handleError()
        case .notDetermined : manager.requestWhenInUseAuthorization()
        default : ()
        }

    }
    
    func handleError(){
        
        showAlert.toggle()
    }
   
 
    func addDraggingPin(coordinate : CLLocationCoordinate2D){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "MAX"
        
        mapView.addAnnotation(annotation)
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let maker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "FINAL")
        
    
        maker.isDraggable = true
        maker.canShowCallout = false
        
        return maker
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        
        guard let newLocation = view.annotation?.coordinate else{return}
        
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        updatePlaceMark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude))
        
    }
    
    func updatePlaceMark(location : CLLocation){
        Task{
            
            do{
                
                guard let place = try await reserveLocationCoordinate(location: location) else{return}
                
                await MainActor.run(body: {
                    self.pickedPlaceMark = place
                })
                
            }
            catch{}
        }
        
    }
    
    
    
    func reserveLocationCoordinate(location : CLLocation) async throws->CLPlacemark?{
        
        
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        return place
        
    }
    
  
}


