//
//  HomeController.swift
//  feedbaz
//
//  Created by Mockingjay on 04/12/2014.
//  Copyright (c) 2014 nicky1525. All rights reserved.
//

import UIKit

class HomeController: UIViewController, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var manager = DownloadManager()
    var post: BlogPost?
    @IBOutlet weak var lblBlogTitle: UILabel!
    func getManager() -> DownloadManager {
        return self.manager
    }
    
    func setBlogPost(post:BlogPost) {
        self.post = post
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager.getData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.blogPosts.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
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

        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
         setBlogPost(getManager().blogPosts[indexPath.row])
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

