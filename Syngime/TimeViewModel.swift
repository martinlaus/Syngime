//
//  TimeViewModel.swift
//  Syngime
//
//  Created by Martin Laus on 3/25/23.
//

import CoreLocation

extension Date {
    func toTimeZone(_ timeZone: TimeZone, from sourceTimeZone: TimeZone) -> Date {
        let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
        let sourceOffset = TimeInterval(sourceTimeZone.secondsFromGMT(for: self))
        return self.addingTimeInterval(targetOffset - sourceOffset)
    }
}


class TimeViewModel: ObservableObject {
    @Published var selectedCity: WorldCity?
    @Published var meetingRange: ClosedRange<Date> = Date()...Date()
    @Published var suggestedMeetings: [Date] = []

    func suggestMeetingTimes(deviceTimeZone: TimeZone?, cityTimeZone: TimeZone?, range: ClosedRange<Date>, interval: TimeInterval = 60 * 60) {
        guard let deviceTimeZone = deviceTimeZone, let cityTimeZone = cityTimeZone else { return }
        var suggestions: [Date] = []

        var currentDate = range.lowerBound
        while currentDate <= range.upperBound {
            let deviceTime = currentDate
            let cityTime = deviceTime.toTimeZone(cityTimeZone, from: deviceTimeZone)

            if Calendar.current.component(.hour, from: cityTime) >= 9 && Calendar.current.component(.hour, from: cityTime) <= 17 {
                suggestions.append(deviceTime)
            }

            currentDate = currentDate.addingTimeInterval(interval)
        }

        self.suggestedMeetings = suggestions
    }
}
