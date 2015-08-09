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

    func setBlogPost(post:MWFeedItem) {
        self.post = post
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blogPosts = NSMutableArray()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
            var feedParser = MWFeedParser(feedURL: NSURL(string: strUrl))
            feedParser.delegate = self
            feedParser.feedParseType = ParseTypeFull
            feedParser.connectionType = ConnectionTypeSynchronously
            feedParser.parse();
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
    }
    
    func feedParserDidStart(parser: MWFeedParser!) {
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        blogTitle = info.title
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

