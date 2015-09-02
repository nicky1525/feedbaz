//
//  HomeController.swift
//  feedbaz
//
//  Created by Mockingjay on 04/12/2014.
//  Copyright (c) 2014 nicky1525. All rights reserved.
//

import UIKit

class HomeController: UIViewController, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource, MWFeedParserDelegate {
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblBlogTitle: UILabel!
    var strUrl: String!
    var post: MWFeedItem?
    var blogPosts : NSMutableArray!
    var blogTitle: String!
    var blogDescr: String!
    var reachability:Reachability!
    var hasShownConnectionError:Bool!
    var historyDict: NSMutableDictionary!

    func setBlogPost(post:MWFeedItem) {
        self.post = post
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blogPosts = NSMutableArray()
        hasShownConnectionError = false
        historyDict = NSMutableDictionary()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
            var feedParser = MWFeedParser(feedURL: NSURL(string: strUrl))
            feedParser.delegate = self
            feedParser.feedParseType = ParseTypeFull
            feedParser.connectionType = ConnectionTypeAsynchronously
            feedParser.parse();
        
        reachability = Reachability.reachabilityForInternetConnection()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        
        reachability.startNotifier()
        
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("history") as? NSData {
            historyDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableDictionary
        }

    }
    
    // MARK: MWFeedParserDelegate
    func feedParser(parser: MWFeedParser!, didFailWithError error: NSError!) {
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        blogPosts.addObject(item)
    }
    
    func feedParserDidFinish(parser: MWFeedParser!) {
        tableview.reloadData()
        if blogTitle != nil {
            lblBlogTitle.text = blogTitle
            lblBlogTitle.hidden = false
        }
         addToHistory()
    }
    
    func feedParserDidStart(parser: MWFeedParser!) {
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        blogTitle = info.title
        blogDescr = info.summary
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogPosts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
            let blogPost: MWFeedItem = blogPosts[indexPath.row] as! MWFeedItem
        
        var titleText = (blogPost.title != nil) ? blogPost.title : "[No Title]";
            var author = cell.viewWithTag(1) as! UILabel
            author.text = blogPost.author
            if author.text != "" {
                author.hidden = true
            }
            var title = cell.viewWithTag(2) as! UILabel
            title.text = titleText
            var date = cell.viewWithTag(3) as! UILabel
            
            var formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            date.text = formatter.stringFromDate(blogPost.date!)
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        setBlogPost(blogPosts[indexPath.row] as! MWFeedItem)
        return indexPath
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "ShowDetails"{ return }
        let viewController:DetailViewController = segue.destinationViewController as!DetailViewController
        viewController.blogPost = post
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if !reachability.isReachable() {
            hasShownConnectionError = false
            connectionLost()
            return false
        }
        return true
    }
    
    func addToHistory() {
        if blogDescr == nil {
            blogDescr = ""
        }
        var date = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMMM yy"
        var datestr = formatter.stringFromDate(date)
        formatter.dateFormat = "HH:mm"
        var hour = formatter.stringFromDate(date)
        var blogDict = ["title": blogTitle, "description": blogDescr, "link": strUrl, "time": hour]
        var array:NSMutableArray? = historyDict.objectForKey(datestr) as? NSMutableArray
        if array == nil {
            array = NSMutableArray()
        }
        array!.addObject(blogDict)
        historyDict.setObject(array!, forKey:datestr)
        let data = NSKeyedArchiver.archivedDataWithRootObject(historyDict)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "history")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    
    // MARK: Reachability
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                println("Reachable via WiFi")
            } else {
                println("Reachable via Cellular")
            }
        } else {
            println("Not reachable")
        }
    }
    
    func connectionLost() {
        if hasShownConnectionError == false {
            hasShownConnectionError = true;
            var alert = UIAlertController(title: "No Network", message: "Please check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

