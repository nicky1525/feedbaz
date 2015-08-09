//
//  DetailViewController.swift
//  feedbaz
//
//  Created by Nicole De La Feld on 30/03/2015.
//  Copyright (c) 2015 nicky1525. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var blogPost: RSSItem?
    var simoneBlogPost: BlogPost?
    var isSimone:Bool!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if isSimone == true {
            self.webView.loadRequest(NSURLRequest(URL: NSURL(string: simoneBlogPost!.postLink)!))
        }
        else {
            self.webView.loadRequest(NSURLRequest(URL:blogPost!.link!))
        }
    }
    
   
}
