//
//  HomeController.swift
//  feedbaz
//
//  Created by Mockingjay on 04/12/2014.
//  Copyright (c) 2014 nicky1525. All rights reserved.
//

import UIKit
import MWFeedParser
import SVProgressHUD

class HomeController: UIViewController, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource, MWFeedParserDelegate {
    @IBOutlet weak var tableview: UITableView!
    //@IBOutlet weak var lblBlogTitle: UILabel!
    var strUrl: String!
    var post: MWFeedItem?
    var blogPosts : NSMutableArray!
    var blogTitle: String!
    var blogDescr: String!
   // var reachability:Reachability!
    var hasShownConnectionError:Bool!

    var favouriteArray: [NSDictionary] = []
    var favouriteArticles: [NSDictionary] = []

    func setBlogPost(post:MWFeedItem) {
        self.post = post
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blogPosts = NSMutableArray()
        hasShownConnectionError = false
        favouriteArray = [NSDictionary] ()
        favouriteArticles = [NSDictionary] ()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         SVProgressHUD.showWithStatus(NSLocalizedString("Loading...", comment:""), maskType: .Clear)
            let feedParser = MWFeedParser(feedURL: NSURL(string: strUrl))
            feedParser.delegate = self
            feedParser.feedParseType = ParseTypeFull
            feedParser.connectionType = ConnectionTypeAsynchronously
            feedParser.parse();
        do {
//            try reachability = Reachability.reachabilityForInternetConnection()
//            try reachability = Reachability.reachabilityForInternetConnection()
//            
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
//            try reachability.startNotifier()

        } catch {
            print(error)
        }
        favouriteArray = PreferenceManager.sharedInstance.getFavourites()
        favouriteArticles = PreferenceManager.sharedInstance.getArticles()
    }
    
    // MARK: MWFeedParserDelegate
    func feedParser(parser: MWFeedParser!, didFailWithError error: NSError!) {
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        blogPosts.addObject(item)
    }
    
    func feedParserDidFinish(parser: MWFeedParser!) {
        tableview.reloadData()
        SVProgressHUD.dismiss()
        if blogTitle != nil {
            self.title = blogTitle
        }
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
            let blogPost: MWFeedItem = blogPosts[indexPath.row] as! MWFeedItem
        
        let titleText = (blogPost.title != nil) ? blogPost.title : "[No Title]";
            let author = cell.viewWithTag(1) as! UILabel
            author.text = blogPost.author
            if author.text != "" {
                author.hidden = true
            }
            let title = cell.viewWithTag(2) as! UILabel
            title.text = titleText
            let date = cell.viewWithTag(3) as! UILabel
        
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            date.text = formatter.stringFromDate(blogPost.date!)
        
            let btnFavourite = cell.viewWithTag(4) as! UIButton
            btnFavourite.addTarget(self, action: Selector("addArticleToFavourites:"), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        setBlogPost(blogPosts[indexPath.row] as! MWFeedItem)
        return indexPath
    }
    
    // MARK: IBActions
    
    func addArticleToFavourites(sender:AnyObject) {
        let button = sender as! UIButton
        let cell = button.superview!.superview as! UITableViewCell
        let index = tableview.indexPathForCell(cell)
        let article = blogPosts.objectAtIndex(index!.row) as! MWFeedItem
        let blogPostDict = ["title": article.title, "author": blogTitle, "link": article.identifier, "update": article.date]
        if favouriteArticles.count > 0 {
            for i in 0 ... favouriteArticles.count - 1 {
                favouriteArticles.append(blogPostDict)
            }
        }
        else {
            favouriteArticles.append(blogPostDict)
        }
        SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Article added to your favourites!", comment:""), maskType:.Clear)

        PreferenceManager.sharedInstance.saveArticles(uniq(favouriteArticles))
    }
    
    @IBAction func btnAddToFavouritesPressed(sender: AnyObject) {
        if blogDescr == nil {
            blogDescr = ""
        }
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMMM yy"
        //let datestr = formatter.stringFromDate(date)
        formatter.dateFormat = "HH:mm"
        let hour = formatter.stringFromDate(date)
        let blogDict = ["title": blogTitle, "description": blogDescr, "link": strUrl, "time": hour]
        if favouriteArray.count > 0 {
            for i in 0 ... favouriteArray.count - 1  {
                    favouriteArray.append(blogDict)
            }
        }
        else {
            favouriteArray.append(blogDict)
        }
        SVProgressHUD.showSuccessWithStatus(NSLocalizedString("This blog has been saved to your favourites!", comment:""), maskType:.Clear)
        PreferenceManager.sharedInstance.saveFavourites(uniq(favouriteArray))
    }
    
    func uniq<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }

//    // MARK: Reachability
//    func reachabilityChanged(note: NSNotification) {
//        
//        let reachability = note.object as! Reachability
//        
//        if reachability.isReachable() {
//            if reachability.isReachableViaWiFi() {
//                print("Reachable via WiFi")
//            } else {
//                print("Reachable via Cellular")
//            }
//        } else {
//            print("Not reachable")
//        }
//    }
//    
//    func connectionLost() {
//        if hasShownConnectionError == false {
//            hasShownConnectionError = true;
//            let alert = UIAlertController(title: "No Network", message: "Please check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
//    }
//
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "ShowDetails"{ return }
        let viewController:DetailViewController = segue.destinationViewController as!DetailViewController
        viewController.blogPost = post
        viewController.blogTitle = blogTitle
        viewController.blogUrl = strUrl
    }

//    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
//        if !reachability.isReachable() {
//            hasShownConnectionError = false
//            connectionLost()
//            return false
//        }
//        return true
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}