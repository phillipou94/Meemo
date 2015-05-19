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
        
        Alamofire.request(.POST, baseURLString+path, parameters: parameters) .responseJSON { (request, response, dataObject, error) in
            if let data: AnyObject = dataObject {
                let json = JSON(data)
                let status = json["status"]
                if(status == 200) {
                    success(json: json)
                } else {
                    failure(error: json)
                }
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
        
        Alamofire.request(.GET, baseURLString+path, parameters: parameters) .responseJSON { (request, response, dataResponse, error) in
            if let data: AnyObject = dataResponse as AnyObject?{
                let json = JSON(data)
                let status = json["status"]
                if (status == 200) {
                    success(json: json)
                } else {
                    println("Error: \(json)")
                    failure(error:json)
                }

            }
        }
    }
    
    // MARK: - User Authentication
    
    func loginUser(email:String, password:String, success:(wasSuccessful:Bool) -> Void) {
        let parameter = ["session":["email":email, "password":password]]
        
        post("login", parameters: parameter, token:nil, success: { (json) -> Void in
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
            if let facebook_id = CoreDataRequest.sharedManager.getUserCredentials()?.facebook_id {
                self.getFacebookFriends({ (friends) -> Void in
                    userArray += friends
                    
                    userArray.sort({ $0.name < $1.name })
                    
                    let dictionary = self.userArrayToDictionary(userArray)
                    
                    completion(friendsDict:dictionary)
                })
            } else {
                let dictionary = self.userArrayToDictionary(userArray)
                completion(friendsDict: dictionary)
            }
           
            
        }
        
    }
    
    //MARK: - Groups
    
    func getGroups(completion:(result:[Group]) -> Void) {
        let token = CoreDataRequest.sharedManager.getAPIToken()
        var result: [Group] = []
        self.get("groups", parameters: nil, token: token, success: { (json) -> Void in
            
            for dict in json["response"].arrayValue {
                
                let group = self.groupModel(dict)
                result.append(group)
                
            }
           
            completion(result: result)
            
            
        }, failure: { (error) -> Void in
            println("Error:\(error)")
            
        })
        
    }
    
    func getGroupsWithPhoneNumber(number:String, success:(wasSuccessful:Bool) -> Void) {
        let token = CoreDataRequest.sharedManager.getAPIToken()
        
        self.get("phone?phone=\(number)", parameters: nil, token: token, success: { (json) -> Void in
            
            success(wasSuccessful: true)
            
            
            }, failure: { (json) -> Void in
                success(wasSuccessful:false)
        
        })
    }
    
    func createGroup(group:Group, completion:(json:JSON) -> Void) {
        var facebook_ids:[String] = []
        var invited_users: [User] = []
        
        for user:User in group.members {
            if let facebook_id = user.facebook_id{
                facebook_ids.append(facebook_id)
            } else if user.phoneNumber != nil {
                invited_users.append(user)
            }
        }
        
        if let image = group.image {
           
            uploadPhoto(image, completion: { (url) -> Void in
                let payload :NSDictionary = ["name":group.name!,"user_ids":group.user_ids, "facebook_ids":facebook_ids, "file_url" : url]
                let parameters = ["group":payload]

                let token = CoreDataRequest.sharedManager.getAPIToken()
                self.post("groups", parameters: parameters, token: token, success: { (json) -> Void in
                    let groupID = json["response"]["id"].number!
                    self.inviteWithPhoneNumbers(groupID, invited_users: invited_users)
                    
                    completion(json: json)
                    
                    }, failure: { (error) -> Void in
                        println("Error:\(error)")
                })
            })

        } else {
            let payload :NSDictionary = ["name":group.name!,"user_ids":group.user_ids, "facebook_ids":facebook_ids]
            let parameters = ["group":payload]
            
            let token = CoreDataRequest.sharedManager.getAPIToken()
            self.post("groups", parameters: parameters, token: token, success: { (json) -> Void in
                let groupID = json["response"]["id"].number!
                 self.inviteWithPhoneNumbers(groupID, invited_users: invited_users)
                
                completion(json:json)
                
                }, failure: { (error) -> Void in
                    println("Error:\(error)")
            })

            
        }
        
       
        
    }
    
    func leaveGroup(group:Group) {
        let parameter:[String:AnyObject] = ["group":["group_id":group.object_id]]
        let token = CoreDataRequest.sharedManager.getAPIToken()
        self.post("groups/leave", parameters: parameter, token: token, success: { (json) -> Void in
            
            }, failure: { (error) -> Void in
                println("Invite User Error: \(error)")
        })
        
    }
    
    func inviteUsers(users:[User], group:Group, completion:() -> Void) {
        
        let token = CoreDataRequest.sharedManager.getAPIToken()
        for user in users {
            var parameter:[String:AnyObject] = [:]
            
            if user.object_id != -1 || user.facebook_id != nil {
                if user.object_id != -1 {
                    parameter = ["invitation":["group_id":group.object_id,"user_id":("\(user.object_id)") ]]
                } else if let facebook_id = user.facebook_id {
                    parameter = ["invitation":["group_id":group.object_id,"facebook_id":facebook_id]]
                }
                
                self.post("groups/invite", parameters: parameter, token: token, success: { (json) -> Void in
                
                    }, failure: { (error) -> Void in
                    println("Invite User Error: \(error)")
                })
            }
        }
        inviteWithPhoneNumbers(group.object_id, invited_users: users)
        completion()
        
    }
    
    func inviteWithPhoneNumbers(group_id:NSNumber,invited_users:[User]) {
        var people:[ [String: String] ] = []
        for user:User in invited_users {
            var dict:[String:String] = [:]
            if user.object_id == -1 && user.facebook_id == nil {
                dict["name"] = user.name!
                if let phoneNumber = user.phoneNumber {
                    dict["phone"] = phoneNumber
                    people.append(dict)
                }
                
            
                let payload:NSDictionary = ["group_id":group_id, "people":people]
                let parameters = ["invite":payload]
                let token = CoreDataRequest.sharedManager.getAPIToken()
                self.post("phone_invite", parameters: parameters, token: token, success: { (json) -> Void in
                    
                }, failure: { (error) -> Void in
                    println("Phone Invite Error:\(error)")
                })
            }
        }
    }
    
    //MARK: - Posts
    
    func createPost(post:Post, completion:(finished:Bool) -> Void) {
        var payload:NSMutableDictionary = [:]
        let token = CoreDataRequest.sharedManager.getAPIToken()
        var facebook_ids: [String] = []
        var phone_numbers: [[String:String]] = []
        for user in post.tagged_users {
            if let facebook_id = user.facebook_id {
                facebook_ids.append(facebook_id)
            }else if let phone_number = user.phoneNumber {
                if let name = user.name {
                    phone_numbers.append(["name":name, "phone":phone_number])
                }
                
            }
        }

        if post.post_type == "text" {
            if let group_id = post.group_id {
                payload = ["post_type":"text", "content":post.content!, "group_id":group_id]
            } else {
                payload = ["post_type":"text", "content":post.content!, "facebook_ids":facebook_ids]
            }
            let parameter = ["post":payload]
            self.post("posts", parameters: parameter, token: token, success: { (json) -> Void in
                    completion(finished: true)
                }, failure: { (error) -> Void in
                    println("Error:\(error)")
            })
            
            
        } else {
            uploadPhoto(post.image!, completion: { (url) -> Void in
                if let group_id = post.group_id {
                    payload = ["post_type":"photo", "content":post.content!, "title":post.title!, "file_url":url,"group_id":group_id]
                } else {
                    payload = ["post_type":"text", "content":post.content!,"title":post.title!, "file_url":url, "facebook_ids":facebook_ids]
                }
                
                let parameter = ["post":payload]
                self.post("posts", parameters: parameter, token: token, success: { (json) -> Void in
                    
                    }, failure: { (error) -> Void in
                        println("Error:\(error)")
                })
            })
        }
        


    }
    
    func getPostsFromGroup(page:Int,group:Group,completion:(result:[Post]) -> Void) {
        let token = CoreDataRequest.sharedManager.getAPIToken()
        let path = "groups/\(group.object_id)/posts?page=\(page)"
        self.get(path, parameters: nil, token: token, success: { (json) -> Void in
            var result:[Post] = []
            for dict in json["response"].arrayValue {
                let post = self.postModel(dict)
                result.append(post)
            }
            completion(result:result)
            }, failure: { (error) -> Void in
                println("Error:\(error)")
        })
    }
    
    func getPosts(page:Int,completion:(result:[Post]) -> Void) {
        let token = CoreDataRequest.sharedManager.getAPIToken()
        let path = "posts?page=\(page)"
        self.get(path, parameters: nil, token: token, success: { (json) -> Void in
            var result:[Post] = []
            for dict in json["response"].arrayValue {
                let post = self.postModel(dict)
                result.append(post)
            }
            completion(result:result)
            },failure: { (error) -> Void in
            println("Error:\(error)")
        })
    }
    
    //MARK: - Facebook
    
    func signInWithFacebook(user:User,success:(wasSuccessful:Bool) -> Void) {
        
        var payload:NSDictionary = ["name":user.name!, "facebook_id":user.facebook_id!, "email":user.email!]
        let parameter = ["user":payload]
    
        post("login/fb", parameters: parameter, token:nil, success: { (json) -> Void in
            
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
    
    func linkFacebookAccount() {
        
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
    
    
    //MARK: - HELPERS
    
    func removeBackSlashes(string:String?) -> String? {
        if let stringTerm = string {
            return stringTerm.stringByReplacingOccurrencesOfString("\\", withString: "")
        }
        return nil
    }
    
    func wakeUp(completion:(awake:Bool)-> Void) {
        self.get("wake_up", parameters: nil, token: nil, success: { (json) -> Void in
            completion(awake:true)
            }, failure: { (error) -> Void in
                println("Error: \(error)")
        })
        
    }
    
    func userArrayToDictionary(userArray:[User]) -> [String:[User]]{
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
        return dictionary

        
    }
    
    func groupModel(dict:JSON) -> Group {
        var group = Group()
        group.last_updated = dict["updated_at"].string
        group.name =  dict["name"].string
        group.object_id = dict["id"].number!
        group.lastPostType = dict["last_post_type"].string
        group.imageURL = self.removeBackSlashes(dict["file_url"].string)
        if let has_seen = dict["seen_last_post"].bool {
            group.has_seen = has_seen
        } else {
            group.has_seen = false
        }
        
        
        return group
    }
    
    func postModel(dict:JSON) -> Post {
        let post = Post()
        post.post_type = dict["post_type"].string
        post.content = dict["content"].string
        post.title = dict["title"].string
        post.file_url = self.removeBackSlashes(dict["file_url"].string)
        post.object_id = dict["id"].number
        post.group_id = dict["group_id"].number
        post.user_id = dict["user_id"].number
        post.user_name = dict["user_name"].string
        post.created_at = dict["created_at"].string
        return post
    }
    
    
    
}
