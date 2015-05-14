//
//  String+DateFormatter.swift
//  Meemo
//
//  Created by Phillip Ou on 5/13/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import Foundation

extension String {
    func formatDate() -> String? {

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.dateFromString(self) {
            return determineRelativeTime(date)
        }
        
        return nil
        
    }
    
    func determineRelativeTime(date:NSDate) -> String {
        let now = NSDate()
        let seconds = abs(date.timeIntervalSinceDate(now))
        let minutes = seconds/60.0
        if seconds < 60 {
            return "Just Now"
        } else if seconds < 120 {
            return "A Minute Ago"
        } else if minutes < (60) {
            return "\(Int(minutes)) minutes ago"
        } else if minutes < (120) {
            return "an Hour ago"
        } else if minutes < (60 * 10) {
            return "\(Int(minutes/60)) hours ago"
        }else if minutes < (60*24){
            return "Today at \(getTime(date))"
        } else if minutes < (60 * 24 * 2) {
            return "Yesterday at \(getTime(date))"
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            let result = dateFormatter.stringFromDate(date)
            return result+" at \(getTime(date))"
            
        }
        
    }
    
    func getTime(date:NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components((.CalendarUnitHour | .CalendarUnitMinute), fromDate: date)
        var hour = comp.hour
        let minute = comp.minute
        var suffix = "am"
        if hour >= 12 {
            suffix = "pm"
            hour = hour - 12
        }
        if minute < 10 {
            return "\(hour):0\(minute) \(suffix)"
        }
        return "\(hour):\(minute) \(suffix)"
        
        
    }
    
    func conventionalDate() -> String? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.dateFromString(self) {
            dateFormatter.dateStyle = .MediumStyle
            let result = dateFormatter.stringFromDate(date)
            return result
        }
        
        return nil
    }

    
}
