//
//  ContentView.swift
//  Syngime
//
//  Created by Martin Laus on 3/25/23.
//

import SwiftUI
import CoreLocation
import Combine

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var worldCities = WorldCities()
    @StateObject private var timeViewModel = TimeViewModel()

//    @State private var meetingRange: ClosedRange<Date> = Date()...Date()
//
    @State private var meetingStart: Date = Date()
    @State private var meetingEnd: Date = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Section(header: Text("Your Location and Time")) {
                        if let location = locationManager.location,
                           let timeZone = locationManager.timeZone {
                            Text("Latitude: \(location.coordinate.latitude)")
                            Text("Longitude: \(location.coordinate.longitude)")
                            Text("Time Zone: \(timeZone.identifier)")
                            Text("Current Time: \(Date().formatted(date: .abbreviated, time: .shortened))")
                        } else {
                            Text("Retrieving location and time...")
                        }
                    }
                    
                    Section(header: Text("Select a City")) {
                        Picker("City", selection: $timeViewModel.selectedCity) {
                            ForEach(worldCities.cities) { city in
                                Text(city.name).tag(city as WorldCity?)
                            }
                        }
                    }
                    
                    if let selectedCity = timeViewModel.selectedCity {
                        Text("Selected City Time: \(Date().toTimeZone(selectedCity.timeZone, from: locationManager.timeZone ?? TimeZone.current).formatted(date: .abbreviated, time: .shortened))")
                    }
                    
                    Section(header: Text("Meeting Time Range")) {
                        DatePicker("From", selection: $meetingStart, displayedComponents: .hourAndMinute)
                        DatePicker("To", selection: $meetingEnd, displayedComponents: .hourAndMinute)
                    }
                    
                    Button("Find Suitable Meeting Times") {
                        if meetingStart <= meetingEnd {
                            let range = meetingStart...meetingEnd
                            timeViewModel.suggestMeetingTimes(deviceTimeZone: locationManager.timeZone, cityTimeZone: timeViewModel.selectedCity?.timeZone, range: range)
                        } else {
                            // Handle the invalid range case, e.g., show an alert to the user
                        }
                    }

                    
                    Section(header: Text("Suggested Meeting Times")) {
                        ForEach(timeViewModel.suggestedMeetings, id: \.self) { meetingTime in
                            VStack(alignment: .leading) {
                                Text("Your Time: \(meetingTime.formatted(date: .abbreviated, time: .shortened))")
                                if let selectedCity = timeViewModel.selectedCity {
                                    Text("\(selectedCity.name) Time: \(meetingTime.toTimeZone(selectedCity.timeZone, from: locationManager.timeZone ?? TimeZone.current).formatted(date: .abbreviated, time: .shortened))")
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Meeting Planner")
        }
        .onAppear {
                   locationManager.requestLocationAccess()
               }
        
    }
}
