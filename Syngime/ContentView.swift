//
//  ContentView.swift
//  Syngime
//
//  Created by Martin Laus on 3/25/23.
//

import SwiftUI
import CoreLocation
import Combine
import EventKit

func saveMeetingToCalendar(title: String, startDate: Date, endDate: Date, completion: @escaping (Bool, Error?) -> Void) {
    let eventStore = EKEventStore()
    
    eventStore.requestAccess(to: .event) { (granted, error) in
        if granted {
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
                try eventStore.save(event, span: .thisEvent)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        } else {
            completion(false, error)
        }
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var worldCities = WorldCities()
    @StateObject private var timeViewModel = TimeViewModel()
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var meetingStart: Date = Date()
    @State private var meetingEnd: Date = Date()
    @State private var showCoordinates = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Section(header: Text("Your Location and Time").font(.headline)) {
                        HStack {
                            Text("Your Location")
                            Spacer()
                            Button(action: {
                                showCoordinates.toggle()
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if showCoordinates, let location = locationManager.location {
                            Text("Latitude: \(location.coordinate.latitude)")
                            Text("Longitude: \(location.coordinate.longitude)")
                        }
                        
                        if let timeZone = locationManager.timeZone {
                            Text("Time Zone: \(timeZone.identifier)")
                            Text("Your Time: \(Date().formatted(date: .abbreviated, time: .shortened))")
                        } else {
                            Text("Retrieving location and time...")
                        }
                    }
                    
                    Divider()
                    
                    Section(header: Text("Select a City").font(.headline)) {
                        Picker("City", selection: $timeViewModel.selectedCity) {
                            ForEach(worldCities.cities) { city in
                                Text(city.name).tag(city as WorldCity?)
                            }
                        }
                    }
                    
                    if let selectedCity = timeViewModel.selectedCity {
                        Text("\(Date().toTimeZone(selectedCity.timeZone, from: locationManager.timeZone ?? TimeZone.current).formatted(date: .abbreviated, time: .shortened))")
                    }
                    
                    Divider()
                    
                    Section(header: Text("Meeting Time Range")) {
                        DatePicker("From", selection: $meetingStart, displayedComponents: .hourAndMinute)
                        DatePicker("To", selection: $meetingEnd, displayedComponents: .hourAndMinute)
                    }
                    
                    Divider()
                    
                    Button("Find Suitable Meeting Times") {
                        if meetingStart <= meetingEnd {
                            let range = meetingStart...meetingEnd
                            timeViewModel.suggestMeetingTimes(deviceTimeZone: locationManager.timeZone, cityTimeZone: timeViewModel.selectedCity?.timeZone, range: range)
                        } else {
                            print("Invalid Range")
                            // Handle the invalid range case, e.g., show an alert to the user
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Section(header: Text("Suggested Meeting Times")) {
                        ForEach(timeViewModel.suggestedMeetings, id: \.self) { meetingTime in
                            Button(action: {
                                timeViewModel.selectedMeeting = meetingTime
                            }) {
                                VStack(alignment: .leading) {
                                    Text("Your Time: \(meetingTime.formatted(date: .abbreviated, time: .shortened))")
                                    if let selectedCity = timeViewModel.selectedCity {
                                        Text("\(selectedCity.name) Time: \(meetingTime.toTimeZone(selectedCity.timeZone, from: locationManager.timeZone ?? TimeZone.current).formatted(date: .abbreviated, time: .shortened))")
                                    }
                                    Spacer()
                                    if timeViewModel.selectedMeeting == meetingTime {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    
                    if let selectedMeeting = timeViewModel.selectedMeeting {
                        Button("Add to Calendar") {
                            let meetingTitle = "Meeting with \(timeViewModel.selectedCity?.name ?? "Unknown City")"
                            let startDate = selectedMeeting
                            let endDate = startDate.addingTimeInterval(3600) // Assuming 1-hour meeting
                            
                            saveMeetingToCalendar(title: meetingTitle, startDate: startDate, endDate: endDate) { success, error in
                                if success {
                                    alertTitle = "Success"
                                    alertMessage = "Meeting added to your calendar."
                                } else {
                                    alertTitle = "Error"
                                    alertMessage = "Failed to add the meeting to your calendar."
                                }
                                showAlert = true
                            }
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
