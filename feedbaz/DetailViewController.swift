//
//  DetailViewController.swift
//  feedbaz
//
//  Created by Nicole De La Feld on 30/03/2015.
//  Copyright (c) 2015 nicky1525. All rights reserved.
//

import UIKit
import MWFeedParser

class DetailViewController: UIViewController {
    var blogPost: MWFeedItem?
    var blogTitle: NSString!
    var article:NSDictionary?
    var blogUrl:NSString!
    var historyDict: NSMutableDictionary!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = NSDateFormatter()
         formatter.dateFormat = "HH:mm"
        historyDict = NSMutableDictionary()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        historyDict = PreferenceManager.sharedInstance.getHistory()
        if (blogPost != nil) {
            self.webView.loadRequest(NSURLRequest(URL: NSURL(string:blogPost!.identifier!)!))
            addToHistory()
        }
        else {
            let url:NSURL = NSURL(string: article!.valueForKey("link") as! String)!
            self.webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    // MARK: Private Methods
    func addToHistory() {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMMM yy"
        let datestr = formatter.stringFromDate(date)
        formatter.dateFormat = "HH:mm"
        let hour = formatter.stringFromDate(date)
        //let articles = NSMutableDictionary()
        let article = ["blogTitle":blogTitle!,"blogUrl": blogUrl, "title": blogPost!.title, "link": blogPost!.identifier, "time": hour]
        var array:NSMutableArray? = historyDict.objectForKey(datestr) as? NSMutableArray
        if array == nil {
            array = NSMutableArray()
        }
        array!.insertObject(article, atIndex: 0)
        historyDict.setObject(array!, forKey:datestr)
        PreferenceManager.sharedInstance.saveHistory(historyDict)
    }
    
    
    deinit {
        webView = nil
    }
}
