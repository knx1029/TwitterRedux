//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Nanxi Kang on 10/7/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import AFNetworking
import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var numFollowerLabel: UILabel!
    @IBOutlet weak var numTweetsLabel: UILabel!
    @IBOutlet weak var numFollowingLabel: UILabel!
    @IBOutlet weak var tweetsTable: UITableView!
    
    var user: User?
    var tweets: [Tweet] = []
    
    var onlyMentions: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("user? \(user)")
        if let user = self.user {
            if let username = user.name {
                fullnameLabel.text = username
            }
            if let screenName = user.screenName {
                nameLabel.text = "@\(screenName)"
            }
            if let url = user.profileBiggerUrl {
                profileImage.setImageWith(url)
            }
            if let numTweets = user.numTweets {
                self.numTweetsLabel.text = "\(numTweets)"
            }
            if let numFollowing = user.numFollowing {
                self.numFollowingLabel.text = "\(numFollowing)"
            }
            if let numFollowers = user.numFollowers {
                self.numFollowerLabel.text = "\(numFollowers)"
            }
        }

        tweetsTable.delegate = self
        tweetsTable.dataSource = self
        self.fetchTweets(doSomething: {() -> Void in })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Implementing UITableViewDataSource, UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    // Create a cell to display
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell") as! TwitterTableViewCell
        let tweet = self.tweets[indexPath.row]
        cell.set(tweet)
        view.layoutIfNeeded()
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is LoginViewController) {
            print("logout Tapped")
            User.currentUser = nil
        }  else if (segue.destination is TweetDetailsViewController) {
            let vc = segue.destination as! TweetDetailsViewController
            let indexPath = tweetsTable.indexPath(for: sender as! TwitterTableViewCell)!
            tweetsTable.deselectRow(at: indexPath, animated: true)
            let tweet = self.tweets[indexPath.row]
            vc.tweet = Tweet(copyFrom: tweet)
        } else {
            let controller = segue.destination as! UINavigationController
            let vc = controller.topViewController!
            if (vc is NewTweetViewController) {
                print("new tweet")
                let newTweetVc = vc as! NewTweetViewController
                newTweetVc.tweetId = nil
            } else {
                print("transit to \(type(of: vc))")
            }
        }
    }
    
    private func fetchTweets(doSomething: @escaping () -> Void) {
        if let user = self.user {
            
            if (onlyMentions) {
                TwitterClient.fetchMentionTweets(count: 20, processTweets: {(tweets: [Tweet]) -> Void in
                    self.tweets = tweets
                    self.tweetsTable.reloadData()
                    doSomething()
                })
            } else {
                TwitterClient.fetchUserTweets(count: 20, user: user, processTweets: {(tweets: [Tweet]) -> Void in
                    /*for tweet in tweets {
                     print("tweet: \(tweet.toString())")
                     }*/
                    self.tweets = tweets
                    self.tweetsTable.reloadData()
                    doSomething()
                })
            }
        }
    }

}
