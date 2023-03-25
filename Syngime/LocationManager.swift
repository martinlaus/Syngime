//
//  LocationManager.swift
//  Syngime
//
//  Created by Martin Laus on 3/25/23.
//

import CoreLocation
import Combine

//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let locationManager = CLLocationManager()
//    @Published var location: CLLocation?
//    @Published var timeZone: TimeZone?
//
//    override init() {
//        super.init()
//        self.locationManager.delegate = self
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.startUpdatingLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        self.location = location
//
//        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//            if let placemark = placemarks?.first {
//                self.timeZone = placemark.timeZone
//            }
//        }
//    }
//}
private func fetchTimeZone(for location: CLLocation, completion: @escaping (TimeZone?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { placemarks, error in
        guard let placemark = placemarks?.first,
              let timeZone = placemark.timeZone else {
            completion(nil)
            return
        }
        completion(timeZone)
    }
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var timeZone: TimeZone?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        fetchTimeZone(for: location) { timeZone in
            self.timeZone = timeZone
        }
    }
}
