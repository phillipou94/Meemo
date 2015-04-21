//
//  ServerRequest.swift
//  Meemo
//
//  Created by Phillip Ou on 4/20/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Alamofire

private let _sharedInstance = ServerRequest()
class ServerRequest: NSObject {

    class var sharedInstance: ServerRequest {
        return _sharedInstance
    }
    
    func loginUser(email:String, password:String) {
        
    }
   
}
