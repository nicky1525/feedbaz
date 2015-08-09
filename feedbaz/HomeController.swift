//
//  HomeController.swift
//  feedbaz
//
//  Created by Mockingjay on 04/12/2014.
//  Copyright (c) 2014 nicky1525. All rights reserved.
//

import UIKit

class HomeController: UIViewController, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblBlogTitle: UILabel!
    var strUrl: String!
    var post: RSSItem?
    var SimonePost: BlogPost?
    var blogPosts : [RSSItem] = []
    var blogTitle: String!
    var isSimone:Bool!
    var manager = DownloadManager()
    func getManager() -> DownloadManager {
        return self.manager
    }
    func setBlogPost(post:RSSItem) {
        self.post = post
    }
    
    func SimonePost(post:BlogPost) {
        self.SimonePost = post
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if strUrl.rangeOfString("simonewebdesign") != nil{
            manager.getData()
            isSimone = true
            self.tableview.reloadData()
            self.lblBlogTitle.hidden = false;
        }
        else {
            isSimone = false
            let url: NSURL = NSURL(string:strUrl)!
            let request: NSURLRequest = NSURLRequest(URL:url)
            
            RSSParser.parseFeedForRequest(request, callback: { (feed, error) -> Void in
                self.blogPosts = feed!.items!
                self.blogTitle = feed!.title!
                self.tableview.reloadData()
                self.lblBlogTitle.text = self.blogTitle
                self.lblBlogTitle.hidden = false
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSimone == true {
            return manager.blogPosts.count
        }
        return blogPosts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        if(isSimone == true) {
            let blogPost: BlogPost = manager.blogPosts[indexPath.row]
            var author = cell.viewWithTag(1) as! UILabel
            author.text = blogPost.postAuthor
            if author.text != "" {
                author.hidden = true
            }
            var title = cell.viewWithTag(2) as! UILabel
            title.text = blogPost.postTitle
            var date = cell.viewWithTag(3) as! UILabel
            
            var formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            date.text = formatter.stringFromDate(blogPost.postDate!)
            
        }
        else {
            let blogPost: RSSItem = blogPosts[indexPath.row]
            var author = cell.viewWithTag(1) as! UILabel
            author.text = blogPost.author
            if author.text != "" {
                author.hidden = true
            }
            var title = cell.viewWithTag(2) as! UILabel
            title.text = blogPost.title
            var date = cell.viewWithTag(3) as! UILabel
            
            var formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            date.text = formatter.stringFromDate(blogPost.pubDate!)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (isSimone == true) {
            SimonePost(manager.blogPosts[indexPath.row])
        } else {
            setBlogPost(blogPosts[indexPath.row])
        }
        
        return indexPath
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "ShowDetails"{ return }
        let viewController:DetailViewController = segue.destinationViewController as!DetailViewController
        viewController.isSimone = isSimone
        if isSimone == true {
            viewController.simoneBlogPost = SimonePost
        }
        else {
            viewController.blogPost = post
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

