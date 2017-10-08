//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Nanxi Kang on 9/30/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ButtonTappedDelegate, AddTweetDelegate {

    @IBOutlet weak var tweetsTable: UITableView!
    
    var tweets: [Tweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add top refresher
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tweetsTable.insertSubview(refreshControl, at: 0)
        
        // Do any additional setup after loading the view.
        navigationItem.title = "Home"
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
        cell.setDelegate(self)
        view.layoutIfNeeded()
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newTweetVc = segue.destination as! NewTweetViewController
        newTweetVc.tweetId = nil
        newTweetVc.delegate = self
    }
    
    private func fetchTweets(doSomething: @escaping () -> Void) {
        TwitterClient.fetchHomeTweets(count: 20, processTweets: {(tweets: [Tweet]) -> Void in
            self.tweets = tweets
            self.tweetsTable.reloadData()
            doSomething()
        })
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        print("refresh!")
        fetchTweets(doSomething: refreshControl.endRefreshing)
    }
    
    func addTweet(tweet: Tweet) {
        self.tweets = [tweet] + self.tweets
        self.tweetsTable.reloadData()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        User.currentUser = nil
        NotificationCenter.default.post(name: TwitterClient.USER_DID_LOGOUT, object: nil)
    }
    
    func onFav(tweet: Tweet, favButton: UIButton) {
        if (tweet.favorited == false) {
            TwitterClient.favorite(id: tweet.id!, onSuccess: { () -> Void in
                tweet.favorited = true
                favButton.setImage(UIImage(named: "fav"), for: .normal)
            }, onFailure: { (error: String) -> Void in })
        } else {
            TwitterClient.unfavorite(id: tweet.id!, onSuccess: { () -> Void in
                tweet.favorited = false
                favButton.setImage(UIImage(named: "heart"), for: .normal)
            }, onFailure: { (error: String) -> Void in })
        }
    }
    
    func onRetweet(tweet: Tweet, retweetButton: UIButton) {
        TwitterClient.retweet(id: tweet.id!, onSuccess: { (tweet: Tweet) -> Void in
            self.addTweet(tweet: tweet)
            self.tweetsTable.reloadData()
        }, onFailure: { (error: String) -> Void in
        })
    }
    
    func onReply(tweet: Tweet, replyButton: UIButton) {
        let newTweetVc = storyboard?.instantiateViewController(withIdentifier: "newTweetVC") as! NewTweetViewController
        newTweetVc.tweetId = tweet.id!
        newTweetVc.delegate = self
        dismiss(animated: true, completion: { })
        show(newTweetVc, sender: self)
        //present(controller, animated: true)
    }
    
    func onProfile(tweet: Tweet) {
        let profileVc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        profileVc.user = User(copyFrom: tweet.author!)
        show(profileVc, sender: self)
    }
}
