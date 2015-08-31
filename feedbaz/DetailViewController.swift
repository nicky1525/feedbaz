//
//  DetailViewController.swift
//  feedbaz
//
//  Created by Nicole De La Feld on 30/03/2015.
//  Copyright (c) 2015 nicky1525. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var blogPost: MWFeedItem?
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string:blogPost!.identifier!)!))
    }
}
