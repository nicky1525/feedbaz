//
//  PreferenceManager.swift
//  feedbaz
//
//  Created by Nicole De La Feld on 02/09/2015.
//  Copyright (c) 2015 nicky1525. All rights reserved.
//

import UIKit

class PreferenceManager: NSObject {
    let kKEY_HISTORY = "history"
    let kKEY_FAVOURITES = "favourites"
    static let sharedInstance = PreferenceManager()
    var userDefaults: NSUserDefaults!
    
    override init() {
        userDefaults = NSUserDefaults.standardUserDefaults()
    }
    
    func saveHistory(dict: NSMutableDictionary) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(dict)
        userDefaults.setObject(data, forKey: kKEY_HISTORY)
        userDefaults.synchronize()
    }
    
    func getHistory() -> NSMutableDictionary {
        var historyDict = NSMutableDictionary()
        if let data = userDefaults.objectForKey(kKEY_HISTORY) as? NSData {
            historyDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableDictionary
        }
        return historyDict
    }
    
    func clearHistory() {
        userDefaults.removeObjectForKey(kKEY_HISTORY)
        userDefaults.synchronize()
    }
    
    func saveFavourites(array: NSMutableArray) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(array)
        userDefaults.setObject(data, forKey: kKEY_FAVOURITES)
        userDefaults.synchronize()
    }
    
    func getFavourites() -> NSMutableArray {
        var favouritesArray = NSMutableArray()
        if let data = userDefaults.objectForKey(kKEY_FAVOURITES) as? NSData {
            favouritesArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableArray
        }
        return favouritesArray
    }
    
    func clearFavourites() {
        userDefaults.removeObjectForKey(kKEY_FAVOURITES)
        userDefaults.synchronize()
    }
}
