//
//  Constants.swift
//  NolaChat
//
//  Created by Bojan Jakus on 28.01.2026..
//
import Foundation

public enum ChatConstants {
    public private(set) static var timeDateFormat: String = "M/d/yyyy, h:mm"

    public static func setTimeDateFormat(_ format: String) {
        timeDateFormat = format
    }
}
