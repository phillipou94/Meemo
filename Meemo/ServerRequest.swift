//
//  ServerRequest.swift
//  Meemo
//
//  Created by Phillip Ou on 4/20/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Alamofire
import Parse
import SwiftyJSON

private let _sharedInstance = ServerRequest()
private let baseURLString = "https://shrouded-tor-7022.herokuapp.com/api/"

class ServerRequest: NSObject {

    class var sharedManager: ServerRequest {
        return _sharedInstance
    }
    
    // MARK: - Helpers
    
    func post(path:String, parameters: [String:AnyObject]?, token:String?, success:(json:JSON) -> Void, failure:(error:JSON) -> Void) {
        
        var manager = Manager.sharedInstance
        
        if let api_token = token {
            manager.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/json",
                "Accept":"application/json", "API-TOKEN": api_token]

        } else {
            manager.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/json",
                "Accept":"application/json"]
        }
        
        Alamofire.request(.POST, baseURLString+path, parameters: parameters) .responseJSON { (request, response, data, error) in
            let json = JSON(data!)
            let status = json["status"]
            if(status == 200) {
                success(json: json)
            } else {
                failure(error: json)
            }
        }
    }
    
    func get(path:String, parameters: [String:AnyObject]?, token:String?, success:(json:JSON) -> Void, failure:(error:JSON) -> Void) {
        
        var manager = Manager.sharedInstance
        
        if let api_token = token {
            manager.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/json",
                "Accept":"application/json", "API-TOKEN": api_token]
            
        } else {
            manager.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/json",
                "Accept":"application/json"]
        }
        
        Alamofire.request(.GET, baseURLString+path, parameters: parameters) .responseJSON { (request, response, data, error) in
            let json = JSON(data!)
            let status = json["status"]
            if (status == 200) {
                success(json: json)
            } else {
                println("Error: \(json)")
                failure(error:json)
            }
            
        }
    }
    
    // MARK: - User Authentication
    
    func loginUser(email:String, password:String, success:(wasSuccessful:Bool) -> Void) {
        let parameter = ["session":["email":email, "password":password]]
        
        post("login", parameters: parameter, token:nil, success: { (json) -> Void in
            println(json)
            var user = User()
            user.email = json["response"]["email"].string
            user.name = json["response"]["name"].string!
            user.api_token = json["response"]["authentication_token"].string!
            if let object_id = json["response"]["id"].number {
                user.object_id = object_id
                CoreDataRequest.sharedManager.updateUserCredentials(user)
            }
            
            success(wasSuccessful:true)
            
        }, failure: { (error) -> Void in
            success(wasSuccessful:false)
        })
        
        
    }
    
    func signupUser(name:String , email:String, password:String,success:(wasSuccessful:Bool) -> Void) {
        let parameter = ["user":["name":name, "email":email, "password":password]]
        
        post("users", parameters: parameter, token:nil, success: { (json) -> Void in
            println(json)
            
            var user = User()
            user.email = json["response"]["email"].string
            if let name = json["response"]["name"].string {
                user.name = name
            }
            if let api_token = json["response"]["authentication_token"].string {
                user.api_token = api_token
            }
            if let facebook_id = json["response"]["facebook_id"].string {
                user.facebook_id = facebook_id
            }
            if let object_id = json["response"]["id"].number {
                user.object_id = object_id
                CoreDataRequest.sharedManager.updateUserCredentials(user)
            }
            
            success(wasSuccessful:true)
            }, failure: { (error) -> Void in
                println("Error: \(error)")
                success(wasSuccessful:false)
        })
    
    }
    
    //MARK: - Groups
    
    func getGroups() {
        let token = CoreDataRequest.sharedManager.getAPIToken()
        
    }
    
    func getGroupsWithPhoneNumber(number:String, success:(wasSuccessful:Bool) -> Void) {
        let token = CoreDataRequest.sharedManager.getAPIToken()
        
        self.get("groups?phone=\(number)", parameters: nil, token: token, success: { (json) -> Void in
            
            success(wasSuccessful: true)
            
            
            }, failure: { (json) -> Void in
                success(wasSuccessful:false)
        
        })
    }
    
    //MARK: - Facebook
    
    func signInWithFacebook(user:PFUser,success:(wasSuccessful:Bool) -> Void) {
        
        let name = user.username! as String
        let facebook_id = user.objectId! as String
        let parameter = ["user":["name":name, "facebook_id":facebook_id]]
        
        post("login/fb", parameters: parameter, token:nil, success: { (json) -> Void in
            println(json)
            
            var user = User()
            user.email = json["response"]["email"].string
            if let name = json["response"]["name"].string {
                user.name = name
            }
            if let api_token = json["response"]["authentication_token"].string {
                user.api_token = api_token
            }
            if let facebook_id = json["response"]["facebook_id"].string {
                user.facebook_id = facebook_id
            }
            if let object_id = json["response"]["id"].number {
                user.object_id = object_id
                CoreDataRequest.sharedManager.updateUserCredentials(user)
            }
            success(wasSuccessful:true)
            }, failure: { (error) -> Void in
                println("Error: \(error)")
                success(wasSuccessful:false)
                
        })
        
    }
    
    func getFacebookFriends(completion:(friends:NSArray) -> Void) {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends",     parameters: nil)
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                //get Facebook ID
                let friendsList = result.objectForKey("data") as! NSArray
                completion(friends:friendsList)
                
            }
            
        }
    }

   
}
