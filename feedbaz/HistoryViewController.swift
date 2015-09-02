//
//  HistoryViewController.swift
//  feedbaz
//
//  Created by Nicole De La Feld on 01/09/2015.
//  Copyright (c) 2015 nicky1525. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    var historyDict: NSMutableDictionary!
    var selectedUrl: NSString!
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyDict = NSMutableDictionary()
                // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("history") as? NSData {
            historyDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableDictionary
            tableview.reloadData()
        }
        if historyDict.allKeys.count == 0 {
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
        var keys = historyDict.allKeys
        var key:String = keys[section] as! String
        var blogsForSections:NSArray = historyDict.objectForKey(key) as! NSArray
        return blogsForSections.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return historyDict.allKeys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let blogs: NSArray = historyDict.allKeys
        var key: String = blogs.objectAtIndex(indexPath.section) as! String
        var blogForSection = historyDict.objectForKey(key) as! NSMutableArray
        var blog = blogForSection.objectAtIndex(indexPath.row) as! NSDictionary
        
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
        
        var time = cell.viewWithTag(3) as! UILabel
        time.text = (blog.valueForKey("time") as! String)
        if time.text == "" {
            descr.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
       // setBlogPost(blogPosts[indexPath.row] as! MWFeedItem)
        let blogs: NSArray = historyDict.allKeys
        var key: String = blogs.objectAtIndex(indexPath.section) as! String
        var blogForSection = historyDict.objectForKey(key) as! NSMutableArray
        var blog = blogForSection.objectAtIndex(indexPath.row) as! NSDictionary
        selectedUrl = blog.valueForKey("link") as! String
        performSegueWithIdentifier("showHistoryDetails", sender: self)
        return indexPath
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return historyDict.allKeys[section] as? String
    }
    
    func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            let blogs: NSArray = historyDict.allKeys
            var key: String = blogs.objectAtIndex(indexPath.section) as! String
            var blogForSection = historyDict.objectForKey(key) as! NSMutableArray
            var blog = blogForSection.objectAtIndex(indexPath.row) as! NSDictionary
            switch editingStyle {
            case .Delete:
                // remove the deleted item from the model
                blogForSection.removeObject(blog)
                let data = NSKeyedArchiver.archivedDataWithRootObject(historyDict)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: "history")
                NSUserDefaults.standardUserDefaults().synchronize()
                
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
        if historyDict.allKeys.count == 0 {
            navigationItem.rightBarButtonItem?.enabled = false
        }
        else {
            navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    func clearAllPressed() {
        var alert = UIAlertController(title:nil, message: "Are you sure you want to clear all the history?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            self.clearAllHistory()
        }))
        alert.addAction(UIAlertAction (title: "CANCEL", style: UIAlertActionStyle.Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func clearAllHistory() {
        historyDict = NSMutableDictionary()
        let data = NSKeyedArchiver.archivedDataWithRootObject(historyDict)
        NSUserDefaults.standardUserDefaults().removeObjectForKey("history")
        NSUserDefaults.standardUserDefaults().synchronize()
        tableview.reloadData()
        navigationItem.leftBarButtonItem = nil
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    

    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
