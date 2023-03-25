//
//  WorldCities.swift
//  Syngime
//
//  Created by Martin Laus on 3/25/23.
//

import Foundation

struct WorldCity: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let timeZone: TimeZone
}

class WorldCities: ObservableObject {
    @Published var cities: [WorldCity] = [
        WorldCity(name: "New York", timeZone: TimeZone(identifier: "America/New_York")!),
        WorldCity(name: "Los Angeles", timeZone: TimeZone(identifier: "America/Los_Angeles")!),
        WorldCity(name: "London", timeZone: TimeZone(identifier: "Europe/London")!),
        WorldCity(name: "Tokyo", timeZone: TimeZone(identifier: "Asia/Tokyo")!),
        WorldCity(name: "Tallinn", timeZone: TimeZone(identifier: "Europe/Tallinn")!),
        WorldCity(name: "Frankfurt", timeZone: TimeZone(identifier: "Europe/Paris")!),
        // Add more cities here
    ]
}
