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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        urlArray = ["http://www.simonewebdesign.it/atom.xml","http://blog.cliomakeup.com/feed/","http://nshipster.com/feed.xml","http://www.sweetandgeek.it/feed/"]
        isValid = false
    }
    
    @IBAction func btnItemPressed(sender: AnyObject) {
        var button = sender as! UIButton
        selectedUrl = urlArray[button.tag - 1]
        performSegueWithIdentifier("ShowArticles", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        homeController = segue.destinationViewController as! HomeController
        homeController.strUrl = selectedUrl
    }
    
    func registerForKeyboardNotifications() {
        // Notify when keyboard shows or hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
        //Dismiss the keyboard touching outside the textfield
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        scrollview.addGestureRecognizer(tap)
    }
    
    func findBlogWithString(url:String) {
        var standards = ["/?feed=rss", "/?feed=rss2", "/?feed=rdf", "/?feed=atom", "/feed/", "/rss/", "/feed/rss/", "/feed/rss2/", "/feed/rdf/", "/feed/atom/", "/atom.xml"]
        
        var request: NSURLRequest
        var response: NSURLResponse
        var error: NSError
        for standard in standards {
            if isValid == true {
                selectedUrl = url + String(standard)
                performSegueWithIdentifier("ShowArticles", sender: self)
                break
            }
            request = NSURLRequest(URL: NSURL(string: url + String(standard))!)
            var connection =  NSURLConnection(request: request, delegate: self)
            //connection?.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            //connection!.start()
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        connection.cancel()
    }
        
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        var httpResponse =  response as! NSHTTPURLResponse
        if(httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            isValid = false
        }
        else {
            isValid = true
        }
    }
    
    
    func keyboardWillShow(aNotification:NSNotification) {
        var info = NSDictionary(dictionary: aNotification.userInfo!)
        var kbSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.size
        var frame = view.frame
        var scrollPoint = CGPoint(x: 0.0, y: frame.size.height/3);
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
        findBlogWithString(textField.text)
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}

