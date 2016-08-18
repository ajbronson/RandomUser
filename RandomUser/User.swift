//
//  User.swift
//  RandomUser
//
//  Created by AJ Bronson on 8/17/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class User: NSManagedObject {
    
    convenience init(jsonDictionary: [String: AnyObject], dateCreated: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context) else { fatalError("Core data failed to create entity") }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        guard let names = jsonDictionary["name"] as? [String: AnyObject],
            let firstName = names["first"] as? String,
            let lastName = names["last"] as? String,
            let email = jsonDictionary["email"] as? String,
            let phoneNumber = jsonDictionary["phone"] as? String,
            let pictures = jsonDictionary["picture"] as? [String: AnyObject],
            let photoURL = pictures["thumbnail"] as? String else { return }
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
        self.dateCreated = dateCreated
    }

}
