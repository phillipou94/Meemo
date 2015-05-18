//
//  UserCredentials.swift
//  Meemo
//
//  Created by Phillip Ou on 4/21/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import Foundation
import CoreData

class UserCredentials: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var email: String?
    @NSManaged var facebook_id: String?
    @NSManaged var api_token: String?
    @NSManaged var object_id: NSNumber

}
