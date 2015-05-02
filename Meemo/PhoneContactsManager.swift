//
//  PhoneContactsManager.swift
//  Meemo
//
//  Created by Phillip Ou on 5/2/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import AddressBook

private let _sharedInstance = PhoneContactsManager()

class PhoneContactsManager: NSObject {
    
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    class var sharedManager: PhoneContactsManager {
        return _sharedInstance
    }
    
    func getPhoneContactsWithCompletion(completionHandler:(contacts:[String:[Contact]]) -> Void) {
        let status = ABAddressBookGetAuthorizationStatus()
        if status == .Denied || status == .Restricted {
            // user previously denied, to tell them to fix that in settings
            
        }
        
        // open it
        
        var error: Unmanaged<CFError>?
        let addressBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
        if addressBook == nil {
            println(error?.takeRetainedValue())
            
        }
        
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            granted, error in
            
            if !granted {
                // warn the user that because they just denied permission, this functionality won't work
                // also let them know that they have to fix this in settings
                return
            }
            var contacts:[Contact] = []
            if let people = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue() as? [ABRecord] {
                // now do something with the array of people
                
                for  person:ABRecord in people {
                    var name: String = ""
                    var phoneNumber:String? = ""
                    var email:String? = ""
                    
                    if let firstNameProperty = ABRecordCopyValue(person,kABPersonFirstNameProperty) {
                        if let firstName = firstNameProperty.takeRetainedValue() as? String {
                            name += firstName+" "
                        }
                    }
                    if let lastNameProperty = ABRecordCopyValue(person,kABPersonLastNameProperty) {
                        if let lastName = lastNameProperty.takeRetainedValue() as? String {
                            name += lastName
                        }
                        
                    }
                    
                    
                    let unmanagedPhones = ABRecordCopyValue(person, kABPersonPhoneProperty)
                    let phones: ABMultiValueRef =
                    Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue()
                        as NSObject as ABMultiValueRef
                    if let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, 0) {
                        phoneNumber = Unmanaged.fromOpaque(
                            unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as? String
                    }
                    
                    let unmanagedEmails = ABRecordCopyValue(person, kABPersonEmailProperty)
                    let emails: ABMultiValueRef = Unmanaged.fromOpaque(unmanagedEmails.toOpaque()).takeUnretainedValue()
                        as NSObject as ABMultiValueRef
                    if let unmanagedEmail = ABMultiValueCopyValueAtIndex(emails, 0) {
                        email = Unmanaged.fromOpaque(unmanagedEmail.toOpaque()).takeUnretainedValue() as NSObject as? String
                    }
                    
                    
                    let contact = Contact(name: name, email: email, phoneNumber: phoneNumber)
                    contacts.append(contact)
                    
                }
                
                var dictionary: [ String:[Contact] ]  = [:]
                for contact in contacts {
                    if let name = contact.name where count(name)>0{
                        var letter = String(name[name.startIndex]).uppercaseString
                        if !contains(self.alphabet, letter) {
                            letter = "#"
                        }
                        if dictionary[letter] != nil{
                            var array = dictionary[letter]! as [Contact]
                            array.append(contact)
                            dictionary[String(letter).uppercaseString] = array
                            
                        } else {
                            dictionary[letter] = [contact]
                        }
                        
                    }
                    
                }
                
                completionHandler(contacts: dictionary)
                
            }
            
        }
    }

    
    
   
}
