//
//  Contact.swift
//  Meemo
//
//  Created by Phillip Ou on 5/2/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class Contact: NSObject {
    var name:String? = ""
    var email:String? = ""
    var phoneNumber:String? = ""
    init(name:String?, email:String?, phoneNumber:String?) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}
