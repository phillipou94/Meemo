//
//  User.swift
//  Meemo
//
//  Created by Phillip Ou on 4/21/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import Foundation

class User: NSObject {
    var name: String? = nil
    var email: String? = nil
    var phoneNumber: String? = nil
    var facebook_id: String? = nil
    var api_token: String? = nil
    var object_id: NSNumber? = -1
    var isUsingApp: Bool = true
    var number_of_groups: NSNumber? = 0
    var number_of_posts: NSNumber? = 0

    
    func getInitials() -> String {
        var initials = ""
        if let array = self.name?.componentsSeparatedByString(" ") {
            for string in array {
                 let str = string as NSString
                    if str.length > 0 {
                        initials += str.substringWithRange(NSMakeRange(0,1))
                    }
                    
                
                
            }
        }
        
        return initials
    }

}
