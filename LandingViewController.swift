//
//  LandingViewController.swift
//  feedbaz
//
//  Created by Mockingjay on 22/03/2015.
//  Copyright (c) 2015 nicky1525. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, NSURLConnectionDelegate {
    @IBOutlet weak var scrollview: UIScrollView!
    var urlArray:Array<String>!
    var homeController: HomeController!
    var selectedUrl:String!
    var isValid: Bool!
    var reachability:Reachability!
    var hasShownConnectionError:Bool!
    var historyBlogs:Array<NSDictionary>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        isValid = false
        hasShownConnectionError = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try reachability = Reachability.reachabilityForInternetConnection()
            urlArray = ["http://www.simonewebdesign.it/atom.xml","http://www.aladyinlondon.com/feed","http://nshipster.com/feed.xml","http://www.sweetandgeek.it/feed/"]
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
             try reachability.startNotifier()
        } catch {
            print(error)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        reachability.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func btnItemPressed(sender: AnyObject) {
        let button = sender as! UIButton
        selectedUrl = urlArray[button.tag - 1]
        if reachability.isReachable() {
            performSegueWithIdentifier("ShowArticles", sender: self)
        }
        else {
            hasShownConnectionError = false
            connectionLost()
        }
    }
    
    func findRSSWithString(url:String) {
        if reachability.isReachable() {
            if let blogsUrl = NSURL(string:  "http://\(url)") {
                if var blogHtmlData: NSData = NSData(contentsOfURL: blogsUrl) { // may return nil, too
                    blogHtmlData = NSData(contentsOfURL: blogsUrl)!
                    let blogParser: TFHpple = TFHpple(HTMLData: blogHtmlData)
                    
                    //looking for this node to find rss feed link: <link rel="alternate" type="application/rss+xml" href="http://example.com/feed" />
                    var blogXpathQueryString: String = "//link[@rel='alternate'][@type='application/rss+xml']"
                    var blogNodes: [AnyObject] = blogParser.searchWithXPathQuery(blogXpathQueryString)
                    if blogNodes.count == 0 {
                        blogXpathQueryString = "//link[@rel='alternate'][@type='application/atom+xml']"
                        blogNodes = blogParser.searchWithXPathQuery(blogXpathQueryString)
                    }
                    if blogNodes.count > 0 {
                        var match: String = String()
                        match = blogNodes[0].objectForKey("href")
                        if match != "" {
                            selectedUrl = match
                            performSegueWithIdentifier("ShowArticles", sender: self)
                        }
                        else {
                            let alert = UIAlertController(title: "Error", message: "No feed RSS found for the specified URL", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                    }
                }
                    
                else {
                    let alert = UIAlertController(title: "Error", message: "Please meake sure you entered a valid URL", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else {
                
                let alert = UIAlertController(title: "Error", message: "Please meake sure you entered a valid URL", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                hasShownConnectionError = false
                connectionLost()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        homeController = segue.destinationViewController as! HomeController
        homeController.strUrl = selectedUrl
    }
    
    // MARK: Reachability
    
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        let httpResponse =  response as! NSHTTPURLResponse
        if(httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            isValid = false
        }
        else {
            isValid = true
            
        }
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Not reachable")
        }
    }
    
    func connectionLost() {
        if hasShownConnectionError == false {
            hasShownConnectionError = true;
            let alert = UIAlertController(title: "No Network", message: "Please check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: KeyboardNotifications
    func registerForKeyboardNotifications() {
        // Notify when keyboard shows or hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
        //Dismiss the keyboard touching outside the textfield
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        scrollview.addGestureRecognizer(tap)
    }
    
    func keyboardWillShow(aNotification:NSNotification) {
        //let info = NSDictionary(dictionary: aNotification.userInfo!)
        //var kbSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.size
        let frame = view.frame
        let scrollPoint = CGPoint(x: 0.0, y: frame.size.height/3);
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.scrollview.setContentOffset(scrollPoint, animated: true)
            }, completion: nil)
    }
    
    func keyboardWillBeHidden(aNotification:NSNotification) {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.scrollview.setContentOffset(CGPointZero, animated: true)
            }, completion: nil)
    }
    
    func dismissKeyboard() {
        scrollview.endEditing(true)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollview.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        scrollview.endEditing(true)
        findRSSWithString(textField.text!)
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}