//
//  Group.swift
//  Meemo
//
//  Created by Phillip Ou on 5/3/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class Group: NSObject {
    var name:String? = nil
    var image:UIImage? = nil
    var imageURL:String? = nil
    var user_ids:[NSNumber] = []
    var members: [User] = []
    var object_id:NSNumber = -1
    var lastPostType:String? = nil
    var last_updated:String? = nil
    var visited_at:String? = nil
    var needs_viewing:Bool = true
    
   
}
