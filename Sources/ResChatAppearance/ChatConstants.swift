//
//  Constants.swift
//  NolaChat
//
//  Created by Bojan Jakus on 28.01.2026..
//
import Foundation

public enum ChatConstants {
    public private(set) static var timeDateFormat: String = "M/d/yyyy, h:mm"
    public private(set) static var timeZone: TimeZone = .current

    public static func setTimeDateFormat(_ format: String) {
        timeDateFormat = format
    }

    public static func setTimeZone(_ timeZone: TimeZone) {
        self.timeZone = timeZone
    }

    public static func setTimeZoneId(_ timeZoneId: String) {
        timeZone = TimeZone(identifier: timeZoneId) ?? .current
    }
}
