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
    
    func post(path:String, parameters: [String:AnyObject]?, completionHandler:(json:JSON) -> Void) {
        
        Alamofire.request(.POST, baseURLString+path, parameters: parameters)
            .responseJSON { (request, response, data, error) in
                if(error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                }
                else {
                    let json = JSON(data!)
                    completionHandler(json: json)
                    //this is a comment
                }
        }
    }
    
    
    func loginUser(email:String, password:String) {
        let parameter = ["session":["email":email, "password":password]]
        post("login", parameters: parameter) { (json) -> Void in
            println(json)
        }
        
    }
    
    func signupUser(name:String , email:String, password:String) {
        let parameter = ["user":["name":name, "email":email, "password":password]]
        post("users", parameters: parameter) { (json) -> Void in
            println(json)
        }
    }
   
}
