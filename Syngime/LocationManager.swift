//
//  LocationManager.swift
//  Syngime
//
//  Created by Martin Laus on 3/25/23.
//

import CoreLocation
import Combine

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
    private var locationUpdateTimer: Timer?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
        scheduleLocationUpdates()
    }
    
    func scheduleLocationUpdates() {
        self.locationManager.startUpdatingLocation()
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { _ in
            self.locationManager.startUpdatingLocation()
            print("UpdatingLocation...")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let location = locations.last else { return }
        self.location = location
        fetchTimeZone(for: location) { timeZone in
            self.timeZone = timeZone
        }
    }
}
