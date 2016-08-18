//
//  UserTableViewController.swift
//  RandomUser
//
//  Created by AJ Bronson on 8/17/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit
import CoreData

class UserTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, NSFetchedResultsControllerDelegate {

    var numberTextField: UITextField?
    @IBOutlet weak var numberPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserController.sharedController.fetchedResultsController.delegate = self
        
        //if there aren't any users saved to core data, fetch the default number of users users (10 users)
        guard let sections = UserController.sharedController.fetchedResultsController.sections where sections[0].numberOfObjects > 0 else { UserController.sharedController.fetchNewUsers(); return }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = UserController.sharedController.fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath)
        guard let user = UserController.sharedController.fetchedResultsController.objectAtIndexPath(indexPath) as? User else { return UITableViewCell() }
        
        //if the user already has their photo saved to core data, use it. otherwise, fetch the photo using the image controller, save it to the user
        if let imageData = user.photo {
            cell.imageView?.image = UIImage(data: imageData)
        } else if let imageURL = user.photoURL,
            let url = NSURL(string: imageURL) {
            ImageController.fetchImage(url, completion: { (image) in
                guard let image = image else { return }
                dispatch_async(dispatch_get_main_queue(), { 
                    cell.imageView?.image = image
                    user.photo = UIImageJPEGRepresentation(image, 0.8)
                    UserController.sharedController.save()
                })
            })
        }
        cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
        cell.detailTextLabel?.text = "\(user.phoneNumber) | \(user.email)"

        return cell
    }

    // Swipe to delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            guard let user = UserController.sharedController.fetchedResultsController.objectAtIndexPath(indexPath) as? User else { return }
            UserController.sharedController.deleteUser(user)
        }
    }
    
    //fetch results controller methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Left)
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Right)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        case .Insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Right)
        case .Move:
            guard let indexPath = indexPath,
                newIndexPath = newIndexPath else { return }
            tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
        case .Update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    //pull to refresh
    @IBAction func refreshControlWasPulled(sender: UIRefreshControl) {
        UserController.sharedController.deleteAllUsers()
        UserController.sharedController.fetchNewUsers()
        sender.endRefreshing()
    }
    
    //MARK: Picker View and Number of Users
    
    //Data Source
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    var numberOptions: [String] {
        var stringToReturn: [String] = []
        for i in 1...25 {
            stringToReturn += ["\(i)"]
        }
        return stringToReturn
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOptions.count
    }
    
    //Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numberOptions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let numberTextField = numberTextField else { return }
            numberTextField.text = numberOptions[row]
    }

    //alert popup requesting number of users to fetch
    @IBAction func configureButtonTapped(sender: UIBarButtonItem) {
        let numberToFetch = (UserController.sharedController.getNumberOfUsersToFetch() - 1)
        self.numberPicker.selectRow(numberToFetch >= 0 ? numberToFetch : 0, inComponent: 0, animated: true)
        let alertView = UIAlertController(title: "Select Number of Users to Return", message: nil, preferredStyle: .Alert)
        alertView.addTextFieldWithConfigurationHandler { (textField) in
            textField.inputView = self.numberPicker
            self.numberTextField = textField
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let doneAction = UIAlertAction(title: "Done", style: .Default) { (_) in
            guard let numberTextField = self.numberTextField,
                let numberText = numberTextField.text,
                let number = Int(numberText) else { return }
            UserController.sharedController.setNumberOfUsersToFetch(number)
        }
        numberTextField?.text = "\(numberToFetch + 1)"
        alertView.addAction(cancelAction)
        alertView.addAction(doneAction)
        presentViewController(alertView, animated: true, completion: nil)
    }
}
