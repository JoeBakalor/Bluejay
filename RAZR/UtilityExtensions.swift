//
//  UtilityExtensions.swift
//  RAZR
//
//  Created by Joe Bakalor on 3/15/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation



extension Date{
    var formatted: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'hh:mm:ss.SS' "//use HH for 24 hour scale and hh for 12 hour scale
        formatter.timeZone = TimeZone.autoupdatingCurrent//(forSecondsFromGMT: 4)
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}




extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

