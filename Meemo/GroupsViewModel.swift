//
//  GroupsViewModel.swift
//  Meemo
//
//  Created by Phillip Ou on 5/6/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class GroupsViewModel: NSObject {
    var groups: [Group] = []
    
    func getGroups(completion:() -> Void) {
        ServerRequest.sharedManager.getGroups { (result) -> Void in
            self.groups = result
            completion()
        }
    }
    
    func formatDate(dateString:String?) -> String? {
        
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
        
    }
    
   
}
