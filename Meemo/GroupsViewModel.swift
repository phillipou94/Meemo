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
    
    func createGroup(group:Group,users:[User], completion:() -> Void) {
        let currentUser = CoreDataRequest.sharedManager.getUserCredentials()
        group.user_ids = []
        group.members = users
        ServerRequest.sharedManager.createGroup(group, completion: { (success) -> Void in
            completion()
        
        })

    }
    
    func leaveGroup(group:Group) {
        ServerRequest.sharedManager.leaveGroup(group)
    }
    
    func inviteUsersToGroup(group:Group, users:[User], completion:() -> Void) {
        
        ServerRequest.sharedManager.inviteUsers(users, group: group, completion: { () -> Void in
            
            completion()
        })
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
    
    
   
}
