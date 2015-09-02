//
//  FavouritesViewController.swift
//  feedbaz
//
//  Created by Nicole De La Feld on 02/09/2015.
//  Copyright (c) 2015 nicky1525. All rights reserved.
//

import UIKit

class FavouritesViewController: UIViewController {

    var favouritesArray: NSMutableArray!
    var selectedUrl: NSString!
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favouritesArray = NSMutableArray()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        favouritesArray = PreferenceManager.sharedInstance.getFavourites()
        tableview.reloadData()
        if favouritesArray.count == 0 {
            navigationItem.rightBarButtonItem?.enabled = false
        }
        else {
            navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return favouritesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        var blog = favouritesArray.objectAtIndex(indexPath.row) as! NSDictionary
        
        var title = cell.viewWithTag(1) as! UILabel
        title.text = (blog.valueForKey("title") as! String)
        if title.text == "" {
            title.hidden = true
        }
        
        var descr = cell.viewWithTag(2) as! UILabel
        descr.text = (blog.valueForKey("description") as! String)
        if descr.text == "" {
            descr.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // setBlogPost(blogPosts[indexPath.row] as! MWFeedItem)
        var blog = favouritesArray.objectAtIndex(indexPath.row) as! NSDictionary
        selectedUrl = blog.valueForKey("link") as! String
        performSegueWithIdentifier("showHistoryDetails", sender: self)
        return indexPath
    }
    
    func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            var blog = favouritesArray.objectAtIndex(indexPath.row) as! NSDictionary
            switch editingStyle {
            case .Delete:
                // remove the deleted item from the model
                favouritesArray.removeObject(blog)
                PreferenceManager.sharedInstance.saveFavourites(favouritesArray)
                
                // remove the deleted item from the `UITableView`
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            default:
                return
            }
    }
    
    func tableView(tableView: UITableView,
        editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
            return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView,
        canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showHistoryDetails" {
            var controller: HomeController = segue.destinationViewController as! HomeController
            controller.strUrl = selectedUrl as! String
        }
    }
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        var button:UIBarButtonItem = sender as! UIBarButtonItem
        if tableview.editing {
            tableview.setEditing(false, animated: true)
            button.title = "Edit"
            navigationItem.leftBarButtonItem = nil
        }
        else {
            tableview.setEditing(true, animated: true)
            button.title = "Done"
            var clearButton = UIBarButtonItem(title: "Clear All", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("clearAllPressed"))
            navigationItem.leftBarButtonItem = clearButton
        }
        if favouritesArray.count == 0 {
            navigationItem.rightBarButtonItem?.enabled = false
        }
        else {
            navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    func clearAllPressed() {
        var alert = UIAlertController(title:nil, message: "Are you sure you want to clear all your favourites?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            self.clearAllFavourites()
        }))
        alert.addAction(UIAlertAction (title: "CANCEL", style: UIAlertActionStyle.Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func clearAllFavourites() {
        favouritesArray = NSMutableArray()
        PreferenceManager.sharedInstance.clearFavourites()
        tableview.reloadData()
        navigationItem.leftBarButtonItem = nil
    }
}
