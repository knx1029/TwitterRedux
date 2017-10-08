//
//  User.swift
//  Twitter
//
//  Created by Nanxi Kang on 9/29/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import Foundation

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileUrl: URL?
    var profileBiggerUrl: URL?
    var tagline: String?
    var numFollowers: Int?
    var numTweets: Int?
    var numFollowing: Int?
    
    var dict: NSDictionary?
    
    init(dict: NSDictionary) {
        name = dict["name"] as? String
        screenName = dict["screen_name"] as? String
        tagline = dict["description"] as? String
        numFollowers = dict["followers_count"] as? Int
        numFollowing = dict["friends_count"] as? Int
        numTweets = dict["statuses_count"] as? Int
        let profileUrlString = dict["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            let profileString = profileUrlString.replacingOccurrences(of: "_normal.", with: "_400x400.")
            profileUrl = URL(string: profileString)
            profileBiggerUrl = URL(string: profileString)
        }
        self.dict = dict
    }
    
    init(copyFrom: User) {
        self.name = copyFrom.name
        self.screenName = copyFrom.screenName
        self.numFollowers = copyFrom.numFollowers
        self.numFollowing = copyFrom.numFollowing
        self.numTweets = copyFrom.numTweets
        self.profileUrl = copyFrom.profileUrl
        self.profileBiggerUrl = copyFrom.profileBiggerUrl
        self.tagline = copyFrom.tagline
        self.dict = copyFrom.dict
    }
    
    func toString() -> String {
        return "name: \(self.name), screenName: \(self.screenName), tagline: \(self.tagline), profileUrl: \(self.profileUrl?.absoluteString), profileBiggerUrl: \(self.profileBiggerUrl?.absoluteString)"
    }
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if (_currentUser != nil) {
                return _currentUser
            }
            
            let defaults = UserDefaults.standard
            if let data = defaults.object(forKey: "currentUser") as? Data {
                let dict = try? JSONSerialization.jsonObject(with: data, options: [])
                if let dict = dict as? NSDictionary {
                    _currentUser = User(dict: dict)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dict!, options: [])
                defaults.set(data, forKey: "currentUser")
            } else {
                defaults.set(nil, forKey: "currentUser")
            }
            
            defaults.synchronize()
        }
    }
}
