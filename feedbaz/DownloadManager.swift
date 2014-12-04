//
//  DownloadManager.swift
//  feedbaz
//
//  Created by Mockingjay on 04/12/2014.
//  Copyright (c) 2014 nicky1525. All rights reserved.
//

import UIKit

let kKEY_URL_PATH:String = "http://www.simonewebdesign.it/atom.xml"

class DownloadManager: NSObject,  NSXMLParserDelegate {
    
    var postTitle: String = String()
    var postLink: String = String()
    var eName: String = String()
    var parser: NSXMLParser = NSXMLParser()
    var blogPosts : [BlogPost] = []
    
    
    func getData () {
        let url: NSURL = NSURL(string:kKEY_URL_PATH)!
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: – NSXMLParserDelegate methods
    
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        eName = elementName
        if elementName == "entry" {
            postTitle = String()
            postLink = String()
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (!data.isEmpty) {
            if eName == "title" {
                postTitle += data
            } else if eName == "id" {
                postLink += data
            }
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        if elementName == "entry" {
            let blogPost: BlogPost = BlogPost()
            blogPost.postTitle = postTitle
            blogPost.postLink = postLink
            blogPosts.append(blogPost)
        }
    }
}

