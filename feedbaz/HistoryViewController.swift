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
    var selectedArticle: NSDictionary!
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyDict = NSMutableDictionary()
        self.title = "History"
                // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        historyDict = PreferenceManager.sharedInstance.getHistory()
        if (historyDict == nil) {
            historyDict = NSMutableDictionary()
        }
        tableview.reloadData()
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
        let key:String = keys[section] as! String
        let blogsForSections:NSArray = historyDict.objectForKey(key) as! NSArray
        return blogsForSections.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return historyDict.allKeys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let blogs: NSArray = historyDict.allKeys
        let key: String = blogs.objectAtIndex(indexPath.section) as! String
        let blogForSection = historyDict.objectForKey(key) as! NSMutableArray
        let blog = blogForSection.objectAtIndex(indexPath.row) as! NSDictionary
        
        let title = cell.viewWithTag(1) as! UILabel
        title.text = (blog.valueForKey("blogTitle") as! String)
        if title.text == "" {
            title.hidden = true
        }
        
        let descr = cell.viewWithTag(2) as! UILabel
        descr.text = (blog.valueForKey("title") as! String)
        if descr.text == "" {
            descr.hidden = true
        }
        
        let time = cell.viewWithTag(3) as! UILabel
        time.text = (blog.valueForKey("time") as! String)
        if time.text == "" {
            descr.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
       // setBlogPost(blogPosts[indexPath.row] as! MWFeedItem)
        let blogs: NSArray = historyDict.allKeys
        let key: String = blogs.objectAtIndex(indexPath.section) as! String
        let blogForSection = historyDict.objectForKey(key) as! NSMutableArray
        let blog = blogForSection.objectAtIndex(indexPath.row) as! NSDictionary
        selectedArticle = blog
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
            let key: String = blogs.objectAtIndex(indexPath.section) as! String
            let blogForSection = historyDict.objectForKey(key) as! NSMutableArray
            let blog = blogForSection.objectAtIndex(indexPath.row) as! NSDictionary
            switch editingStyle {
            case .Delete:
                // remove the deleted item from the model
                blogForSection.removeObject(blog)
                PreferenceManager.sharedInstance.saveHistory(historyDict)
                
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
    
    // MARK: IBActions
    @IBAction func editButtonPressed(sender: AnyObject) {
        let button:UIBarButtonItem = sender as! UIBarButtonItem
        if tableview.editing {
            tableview.setEditing(false, animated: true)
            button.title = "Edit"
            navigationItem.leftBarButtonItem = nil
        }
        else {
            tableview.setEditing(true, animated: true)
            button.title = "Done"
            let clearButton = UIBarButtonItem(title: "Clear All", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(HistoryViewController.clearAllPressed))
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
        let alert = UIAlertController(title:nil, message: "Are you sure you want to clear all the history?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            self.clearAllHistory()
        }))
        alert.addAction(UIAlertAction (title: "CANCEL", style: UIAlertActionStyle.Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func clearAllHistory() {
        historyDict = NSMutableDictionary()
        PreferenceManager.sharedInstance.clearHistory()
        tableview.reloadData()
        navigationItem.leftBarButtonItem = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showHistoryDetails" {
            let controller: DetailViewController = segue.destinationViewController as! DetailViewController
            controller.article = selectedArticle
        }
    }
}
