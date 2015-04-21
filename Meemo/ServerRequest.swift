//
//  ServerRequest.swift
//  Meemo
//
//  Created by Phillip Ou on 4/20/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

private let _sharedInstance = ServerRequest()
private let baseURLString = "https://shrouded-tor-7022.herokuapp.com/api/"

class ServerRequest: NSObject {

    class var sharedManager: ServerRequest {
        return _sharedInstance
    }
    
    func post(path:String, parameters: [String:AnyObject]?, success:(json:JSON) -> Void, failure:(error:JSON) -> Void) {
        
        Alamofire.request(.POST, baseURLString+path, parameters: parameters)
            .responseJSON { (request, response, data, error) in
                let json = JSON(data!)
                let status = json["status"]
                if(status == 200) {
                    success(json: json)
                    
                }
                else {
                    failure(error: json)
                    //this is a comment
                }
        }
    }
    
    
    func loginUser(email:String, password:String, success:(wasSuccessful:Bool) -> Void) {
        let parameter = ["session":["email":email, "password":password]]
        
        post("login", parameters: parameter, success: { (json) -> Void in
            println(json)
            success(wasSuccessful:true)
            
        }, failure: { (error) -> Void in
            success(wasSuccessful:false)
        })
        
        
    }
    
    func signupUser(name:String , email:String, password:String,success:(wasSuccessful:Bool) -> Void) {
        let parameter = ["user":["name":name, "email":email, "password":password]]
        
        post("login", parameters: parameter, success: { (json) -> Void in
            println(json)
            success(wasSuccessful:true)
            }, failure: { (error) -> Void in
                println("Error: \(error)")
                success(wasSuccessful:false)
        })
    
    }
   
}
