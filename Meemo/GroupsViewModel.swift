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
    
    func getPosts(completion:(posts:[Post]) -> Void) {
        ServerRequest.sharedManager.getPosts { (result) -> Void in
            completion(posts:result)
        }
    }
    
    func getPostsFromGroup(group:Group,completion:(result:[Post]) -> Void) {
        ServerRequest.sharedManager.getPostsFromGroup(group, completion: { (result) -> Void in
            completion(result:result)
        })
        

    }
    
    func getAllFriends(completion:(friends:[String:[User]]) -> Void) {
        ServerRequest.sharedManager.getAllFriends { (friendsDict) -> Void in
            completion(friends:friendsDict)
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
