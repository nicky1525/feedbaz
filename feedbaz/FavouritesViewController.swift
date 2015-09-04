//
//  FavouritesViewController.swift
//  feedbaz
//
//  Created by Nicole De La Feld on 02/09/2015.
//  Copyright (c) 2015 nicky1525. All rights reserved.
//

import UIKit

class FavouritesViewController: UIViewController {

    var favouritesArray:[NSDictionary]!
    var selectedUrl: NSString!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var selectorView: UIView!
    @IBOutlet weak var btnArticles: UIButton!
    @IBOutlet weak var btnBlogs: UIButton!
    var selectedArticle: NSDictionary!
    var isBlogs:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favouritesArray = [NSDictionary]()
        isBlogs = true
        self.title = "Favourites"
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        selectArray()
    }
    
    func selectArray() {
        if (isBlogs == true) {
            favouritesArray = PreferenceManager.sharedInstance.getFavourites()
        }
        else {
            favouritesArray = PreferenceManager.sharedInstance.getArticles()
        }
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
        return favouritesArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
       
        var title = cell.viewWithTag(1) as! UILabel
        var descr = cell.viewWithTag(2) as! UILabel
        var author = cell.viewWithTag(3) as! UILabel
        if (isBlogs == true) {
             var blog = favouritesArray[indexPath.row] as NSDictionary
            title.text = (blog.valueForKey("title") as! String)
            if title.text == "" {
                title.hidden = true
            }
            
            author.hidden = true
            
            descr.text = (blog.valueForKey("description") as! String)
            if descr.text == "" {
                descr.hidden = true
            }
        }
        else {
            var blogPost = favouritesArray[indexPath.row] as NSDictionary
            title.text = (blogPost.valueForKey("title") as! String)
            if title.text == "" {
                title.hidden = true
            }
            
            var formatter = NSDateFormatter()
            formatter.dateFormat = "dd MMMM yy"
            descr.text = formatter.stringFromDate(blogPost.valueForKey("update") as! NSDate) as String
            if descr.text == "" {
                descr.hidden = true
            }
            
            author.hidden = false
            author.text = (blogPost.valueForKey("author") as! String)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if isBlogs == true {
            var blog = favouritesArray[indexPath.row] as NSDictionary
            selectedUrl = blog.valueForKey("link") as! String
            performSegueWithIdentifier("showFavouritesDetails", sender: self)
        }
        else {
            selectedArticle = favouritesArray[indexPath.row] as NSDictionary
            performSegueWithIdentifier("showArticlesDetails", sender: self)
        }

                return indexPath
    }
    
    func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            var blog = favouritesArray[indexPath.row] as NSDictionary
            switch editingStyle {
            case .Delete:
                // remove the deleted item from the model
                favouritesArray.removeAtIndex(indexPath.row)
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
        if segue.identifier == "showFavouritesDetails" {
            var controller: HomeController = segue.destinationViewController as! HomeController
            controller.strUrl = selectedUrl as! String
        }
        else if segue.identifier == "showArticlesDetails" {
            var controller: DetailViewController = segue.destinationViewController as! DetailViewController
            controller.article = selectedArticle
        }
    }
    
    //MARK: IBAction
    @IBAction func btnArticlesPressed(sender: AnyObject) {
        isBlogs = false
        selectArray()
        animateLineUnderButton(sender as! UIButton)
    }
    
    @IBAction func btnBlogsPressed(sender: AnyObject) {
        isBlogs = true
        selectArray()
        animateLineUnderButton(sender as! UIButton)
    }
    
    func animateLineUnderButton(sender: UIButton) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.userInteractionEnabled = false
            self.selectorView.frame = CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y + sender.frame.size.height, width: self.selectorView.frame.size.width, height: self.selectorView.frame.size.height)
        }) { (Bool) -> Void in
            self.view.userInteractionEnabled = true
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
        if (self.isBlogs == true) {
            PreferenceManager.sharedInstance.clearFavourites()
        }
        else {
           PreferenceManager.sharedInstance.clearArticles()
        }
        tableview.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem?.title = "Edit"
        navigationItem.rightBarButtonItem?.enabled = false
        favouritesArray = [NSDictionary]()
        tableview.reloadData()
        navigationItem.leftBarButtonItem = nil
    }
}
