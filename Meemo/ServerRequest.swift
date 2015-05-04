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
    
    func getAllFriends(completion:(friendsDict:[String:[User]]) -> Void) {
        PhoneContactsManager.sharedManager.getPhoneContactsWithCompletion { (contacts:[String:[User]]) -> Void in
            var userArray: [User] = []
            for key in contacts.keys {
                userArray += contacts[key]!
            }
            var friends = contacts as [String:[User]]
            self.getFacebookFriends({ (friends) -> Void in
                userArray += friends
                
                userArray.sort({ $0.name < $1.name })
                
                let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
                var dictionary: [ String:[User] ]  = [:]
                for person in userArray {
                    if let name = person.name where count(name)>0{
                        var letter = String(name[name.startIndex]).uppercaseString
                        if !contains(alphabet, letter) {
                            letter = "#"
                        }
                        if dictionary[letter] != nil{
                            var array = dictionary[letter]! as [User]
                            array.append(person)
                            dictionary[String(letter).uppercaseString] = array
                            
                        } else {
                            dictionary[letter] = [person]
                        }
                        
                    }
                    
                }
                
                completion(friendsDict:dictionary)
            })
            
            
            
        }
        
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
    
    func createGroup(group:Group) {
       /* let parameters = ["group":["name":group.name, "user_ids":group.user_ids, "facebook_ids":group.facebook_ids]]
        let token = CoreDataRequest.sharedManager.getAPIToken()
        post("groups", parameters: parameters, token: token, success: { (json) -> Void in
            //
            
            }, failure: { (error) -> Void in
            //
        })*/
        
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
    
    func getFacebookFriends(completion:(friends:[User]) -> Void) {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends",parameters: nil)
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
                
                if ((error) != nil) {
                    // Process error
                    println("Error: \(error)")
                }
                else {
                    //get Facebook ID
                    var users: [User] = []
                    let friendsList = result.objectForKey("data") as! NSArray
                    for object in friendsList {
                        let friend = object as! NSDictionary
                        var user = User()
                        user.name = friend.objectForKey("name") as? String
                        user.facebook_id = friend.objectForKey("id") as? String
                        users.append(user)
                    }
                    
                    completion(friends:users)
                    
                }
                
            }

        }
    }
    
    //MARK: - FILE UPLOADS
    func generateRandomString() -> String {
        let length = 12
        let letters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var result = ""
        for (var i = 0; i < length; i++) {
            let index = arc4random_uniform(UInt32(letters.count))
            result += String(letters[Int(index)])
        }
        return result
    }
    
    func uploadPhoto(image:UIImage, completion:(url:String) -> Void) {
        let compressionScale = 0.75 as CGFloat
        let token = CoreDataRequest.sharedManager.getAPIToken()
        
        var body = NSMutableData()
        if let imageData = UIImageJPEGRepresentation(image, compressionScale) {
           
            let a = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            let parameters = ["file":["encoded_string":a,"extension":"jpg", "content_type":"multipart/form-data"]]
            post("upload_file", parameters: parameters, token: token, success: { (json) -> Void in
                //let jsonObject = JSON(json)
                
                if let url = json["response"]["url"].string {
                    let urlString = url.stringByReplacingOccurrencesOfString("\\", withString: "")
                    
                    completion(url:urlString)
                }
                
            }, failure: { (error) -> Void in
                println(error)
            })
            
            
        }
    }
    

    
    /*



- (void)uploadPhoto:(UIImage*)image withCompletionHandler:(void (^)(NSString *fileID))completion{

float compressionScale = 0.75;

NSString *boundary = [self generateRandomString];
NSURL *requestURL = [NSURL URLWithString: @"https://rocky-spire-3961.herokuapp.com/files/"];
NSString *FileParamConstant = @"photo";
UserCredentials *credentials =[[CoreDataRequest sharedManager] getUserCredentials];
// create request
NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
[request setHTTPShouldHandleCookies:NO];
[request setTimeoutInterval:30];
[request setHTTPMethod:@"POST"];

//set HTTP Headers
[request addValue:@"application/json" forHTTPHeaderField:@"Application"];
[request addValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
[request addValue:[NSString stringWithFormat:@"Bearer %@",credentials.user_token] forHTTPHeaderField:@"Authorization"];

// post body
NSMutableData *body = [NSMutableData data];

// add image data
NSData *imageData = UIImageJPEGRepresentation(image, compressionScale);
if (imageData) {
[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
[body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
[body appendData:imageData];
[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

[body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

// setting the body of the post to the reqeust
[request setHTTPBody:body];

// set URL
[request setURL:requestURL];

[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
if ([httpResponse statusCode] == 200) {
NSLog(@"success");
NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: nil];
NSString *pictureID = serializedData[@"id"];
dispatch_async(dispatch_get_main_queue(), ^{
completion(pictureID);
});

} else {
NSLog(@"Error: %@", error);
}

}];
}
*/

}
