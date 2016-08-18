//
//  User+CoreDataProperties.swift
//  RandomUser
//
//  Created by AJ Bronson on 8/17/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var photo: NSData?
    @NSManaged var dateCreated: NSDate
    @NSManaged var phoneNumber: String
    @NSManaged var email: String
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var photoURL: String?

}
