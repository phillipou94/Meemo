//
//  GroupsViewModel.swift
//  Meemo
//
//  Created by Phillip Ou on 5/6/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class GroupsViewModel: NSObject {
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z", "#"]
    
    func getGroups(completion:(groups:[Group]) -> Void) {
        ServerRequest.sharedManager.getGroups { (result) -> Void in
            completion(groups:result)
        }
    }
    
    func getPosts(page:Int,completion:(posts:[Post]) -> Void) {
        ServerRequest.sharedManager.getPosts(page, completion: { (result) -> Void in
            completion(posts:result)
        })
    }
    
    func getPostsFromGroup(page:Int,group:Group,completion:(result:[Post]) -> Void) {
        ServerRequest.sharedManager.getPostsFromGroup(page,group: group, completion: { (result) -> Void in
            completion(result:result)
        })
        

    }
    
    func getAllFriends(completion:(friends:[String:[User]]) -> Void) {
        ServerRequest.sharedManager.getAllFriends { (friendsDict) -> Void in
            completion(friends:friendsDict)
        }

    }
    
    /*func formatDate(dateString:String?) -> String? {
        
        if let string = dateString {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            if let date = dateFormatter.dateFromString(string) {
                return determineRelativeTime(date)
            }
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
            hour = 24-hour
        }
        if minute < 10 {
            return "\(hour):0\(minute) \(suffix)"
        }
        return "\(hour):\(minute) \(suffix)"

        
    }
    
    func conventionalDate(dateString:String?) -> String? {
        if let string = dateString {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            if let date = dateFormatter.dateFromString(string) {
                dateFormatter.dateStyle = .MediumStyle
                let result = dateFormatter.stringFromDate(date)
                return result
            }
        }
        
        return nil
    }*/
    
   
}
