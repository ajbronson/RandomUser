//
//  UserController.swift
//  RandomUser
//
//  Created by AJ Bronson on 8/17/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation
import CoreData


class UserController {
    
    static let sharedController = UserController()
    private let keyNumberOfUsers = "users"
    let moc = Stack.sharedStack.managedObjectContext
    let fetchedResultsController: NSFetchedResultsController
    
    init() {
        let request = NSFetchRequest(entityName: "User")
        let sortDescriptor1 = NSSortDescriptor(key: "dateCreated", ascending: true)
        request.sortDescriptors = [sortDescriptor1]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        _ = try? fetchedResultsController.performFetch()
    }
    
    func fetchNewUsers() {
        guard let url = NSURL(string: "https://randomuser.me/api/") else { return }
        for _ in 1...getNumberOfUsersToFetch() {
            NetworkController.performURLRequest(url, method: NetworkController.HTTPMethod.Get) { (data, error) in
                if error == nil {
                    guard let data = data,
                        let rawJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
                        let json = rawJSON as? [String: AnyObject],
                        let jsonDict = json["results"] as? [[String: AnyObject]] else { return }
                        let _ = User(jsonDictionary: jsonDict[0])
                        self.save()
                }
            }
        }
    }
    
    func save() {
        do {
            try moc.save()
        } catch let error as NSError {
            print("Error saving object - \(error)")
        }
    }
    
    func deleteUser(user: User) {
        user.managedObjectContext?.deleteObject(user)
        save()
    }
    
    func deleteAllUsers() {
        guard let sections = fetchedResultsController.sections,
            let users = sections[0].objects as? [User] else { return }
        for user in users {
            user.managedObjectContext?.deleteObject(user)
        }
        save()
    }
    
    func setNumberOfUsersToFetch(count: Int) {
        NSUserDefaults.standardUserDefaults().setObject(count, forKey: keyNumberOfUsers)
    }
    
    func getNumberOfUsersToFetch() -> Int {
        guard let numberOfUsersToFetch = NSUserDefaults.standardUserDefaults().objectForKey(keyNumberOfUsers) as? Int else { return 10 }
        return numberOfUsersToFetch
    }
}
