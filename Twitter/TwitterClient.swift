//
//  TwitterClient.swift
//  Twitter
//
//  Created by Nanxi Kang on 9/29/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import AFNetworking
import BDBOAuth1Manager
import Foundation

class TwitterClient {
    
    static let USER_DID_LOGOUT: NSNotification.Name = NSNotification.Name("UserDidLogout")
    
    private static var client: BDBOAuth1SessionManager! = getTwitterClient()
    
    class func deauthorize() {
        TwitterClient.client.deauthorize()
    }
    
    private static var loginSuccess: (() -> Void)?
    
    class func attemptLogin(loginSuccess: @escaping () -> Void) {
        TwitterClient.loginSuccess = loginSuccess
        fetchRequestToken()
    }
    
    class func finishLogin(url: URL) {
        TwitterClient.authorize(url: url, doSomething: { () -> Void in
            TwitterClient.getUser(processUser: { (user: User) -> Void in
                User.currentUser = user
                print("user is \(user.name)")
                if let loginSuccess = TwitterClient.loginSuccess {
                    loginSuccess()
                }
            })
        })
    }
    
    class func fetchRequestToken() {
        client.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitternkang://oauth"), scope: nil, success: TwitterClient.succeedOnRequestToken, failure: TwitterClient.failedOnRequestToken)
    }
    
    class func authorize(url: URL, doSomething: @escaping () -> Void) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        client.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: {(credsOpt: BDBOAuth1Credential?) -> Void in doSomething() }, failure: self.failedOnAccessToken)
    }
    
    class func fetchHomeTweets(count: Int, processTweets: @escaping ([Tweet]) -> Void) {
        client.get("1.1/statuses/home_timeline.json?count=\(count)", parameters: nil, progress: nil, success: { (dataTask: URLSessionDataTask, response: Any) -> Void in
            if let tweetDicts = response as? [NSDictionary] {
                let tweets = Tweet.tweets(fromArray: tweetDicts)
                processTweets(tweets)
            }
        }, failure: { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            print("Error in fetching home tweets: \(error.localizedDescription)")
        })
    }
    
    class func fetchMentionTweets(count: Int, processTweets: @escaping ([Tweet]) -> Void) {
        client.get("1.1/statuses/mentions_timeline.json?count=\(count)", parameters: nil, progress: nil, success: { (dataTask: URLSessionDataTask, response: Any) -> Void in
            if let tweetDicts = response as? [NSDictionary] {
                let tweets = Tweet.tweets(fromArray: tweetDicts)
                processTweets(tweets)
            }
        }, failure: { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            print("Error in fetching mentions tweets: \(error.localizedDescription)")
        })
    }
    
    class func fetchUserTweets(count: Int, user: User, processTweets: @escaping ([Tweet]) -> Void) {
        client.get("1.1/statuses/user_timeline.json?count=\(count)&screen_name=\(user.screenName!)", parameters: nil, progress: nil, success: { (dataTask: URLSessionDataTask, response: Any) -> Void in
            if let tweetDicts = response as? [NSDictionary] {
                let tweets = Tweet.tweets(fromArray: tweetDicts)
                processTweets(tweets)
            }
        }, failure: { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            print("Error in fetching user tweets: \(error.localizedDescription)")
        })
    }
    
    class func getUser(processUser: @escaping (User) -> Void) {
        client.get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (dataTask: URLSessionDataTask, response: Any) -> Void in
            if let userDict = response as? NSDictionary {
                let user = User(dict: userDict)
                processUser(user)
            }
        }, failure: { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            print("Error in getting User: \(error.localizedDescription)")
        })
    }
    
    class func postTweet(content: String, replyId: String?, onSuccess: @escaping (Tweet) -> Void, onFailure: @escaping (String) -> Void) {
        let parameters = NSMutableDictionary()
        parameters.setValue(content, forKey: "status")
        //let encodedContent = content.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        //parameters.setValue(encodedContent, forKey: "status")
        if let replyId = replyId {
            parameters.setValue(replyId, forKey: "in_reply_to_status_id")
        }
        client.post("1.1/statuses/update.json", parameters: parameters, progress: nil, success: { (dataTask: URLSessionDataTask, response: Any) -> Void in
            if let tweetDict = response as? NSDictionary {
                let tweet = Tweet(dict: tweetDict)
                onSuccess(tweet)
            }
        }, failure: { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            print("Error in post Tweet: \(error.localizedDescription)")
            onFailure(error.localizedDescription)
        })
    }
    
    class func retweet(id: String, onSuccess: @escaping (Tweet) -> Void, onFailure: @escaping (String) -> Void) {
        let url = "1.1/statuses/retweet/\(id).json"
        client.post(url, parameters: nil, progress: nil, success: { (dataTask: URLSessionDataTask, response: Any) -> Void in
            if let tweetDict = response as? NSDictionary {
                let tweet = Tweet(dict: tweetDict)
                onSuccess(tweet)
            }
        }, failure: { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            print("Error in reweet: \(error.localizedDescription)")
            onFailure(error.localizedDescription)
        })
    }
    
    class func favorite(id: String, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void) {
        let url = "1.1/favorites/create.json?id=\(id)"
        client.post(url, parameters: nil, progress: nil, success: { (dataTask: URLSessionDataTask, response: Any) -> Void in
            onSuccess()
        }, failure: { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            print("Error in favorite: \(error.localizedDescription)")
            onFailure(error.localizedDescription)
        })
    }
    
    class func unfavorite(id: String, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void) {
        let url = "1.1/favorites/destroy.json?id=\(id)"
        client.post(url, parameters: nil, progress: nil, success: { (dataTask: URLSessionDataTask, response: Any) -> Void in
            onSuccess()
        }, failure: { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            print("Error in unfavorite: \(error.localizedDescription)")
            onFailure(error.localizedDescription)
        })
    }

    
    private class func failedOnAccessToken(error: Error?) {
        print("Error in fetching AccessToken: \(error?.localizedDescription)")
    }
    
    private class func succeedOnRequestToken(credsOpt: BDBOAuth1Credential?) {
        if let creds = credsOpt {
            let urlString = "https://api.twitter.com/oauth/authorize?oauth_token=\(creds.token!)"
            let url = URL(string: urlString)!
            UIApplication.shared.open(url)
        }
    }
    
    private class func failedOnRequestToken(error: Error?) {
        print("Error in fetching RequestToken \(error?.localizedDescription)")
    }
    
    private class func getTwitterClient() -> BDBOAuth1SessionManager {
        let BASE_URL = URL(string: "https://api.twitter.com")
        let CONSUMER_KEY = "zLmIgfBezuLfmAjw25OzF2xtg"
        let CONSUMER_SECRET = "eMKLe0vcdabPdUPwO5k1OXzrLntJSRgW9bREsorSVCRcBcwEUC"
        
        let client = BDBOAuth1SessionManager(baseURL: BASE_URL, consumerKey: CONSUMER_KEY, consumerSecret: CONSUMER_SECRET)!
        return client
    }
}
