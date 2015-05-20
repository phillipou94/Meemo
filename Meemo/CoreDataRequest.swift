//
//  CoreDataRequest.swift
//  Meemo
//
//  Created by Phillip Ou on 4/21/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import CoreData
private let _sharedInstance = CoreDataRequest()

class CoreDataRequest: NSObject {
    
    class var sharedManager: CoreDataRequest {
        return _sharedInstance
    }
    
    func updateUserCredentials(user:User) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context = appDelegate.managedObjectContext!
        
        if let credentials = getUserCredentials() {
            
            credentials.setValue(user.name, forKey:"name")
            credentials.setValue(user.api_token, forKey:"api_token")
            credentials.setValue(user.object_id, forKey:"object_id")
            if let email = user.email {
                credentials.setValue(email, forKey: "email")
            }
            if let facebook_id = user.facebook_id {
                credentials.setValue(facebook_id, forKey:"facebook_id")
            }
            
            context.save(nil)
            
        } else {
            
            var newCredentials = NSEntityDescription.insertNewObjectForEntityForName("UserCredentials", inManagedObjectContext: context) as! UserCredentials
            newCredentials.setValue(user.name, forKey:"name")
            newCredentials.setValue(user.api_token, forKey:"api_token")
            newCredentials.setValue(user.object_id, forKey:"object_id")
            if let email = user.email {
                newCredentials.setValue(email, forKey:"email")
            }
            if let facebook_id = user.facebook_id {
                newCredentials.setValue(facebook_id, forKey:"facebook_id")
            }
            
            context.save(nil)
            
        }
        
        
    }
    
    func getUserCredentials() -> UserCredentials? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context = appDelegate.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "UserCredentials")
        if let credentials = context.executeFetchRequest(request, error: nil)?.first as? UserCredentials {
            return credentials
        } else {
            return nil
        }
        
    }
    
    func updateFacebookID(facebook_id:String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context = appDelegate.managedObjectContext!
        if let credentials = getUserCredentials() {
            credentials.setValue(facebook_id, forKey: "facebook_id")
            context.save(nil)
        }
        
    }
    
    func getAPIToken() -> String? {
        return getUserCredentials()?.api_token
    }
    
    func eraseUserCredentials() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context = appDelegate.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "UserCredentials")
        if let credentials = context.executeFetchRequest(request, error: nil) as? [UserCredentials] {
            for credential in credentials {
                context.deleteObject(credential)
                context.save(nil)
            }
        }
        
    }

}
