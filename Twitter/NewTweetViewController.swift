//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by Nanxi Kang on 10/1/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import AFNetworking
import UIKit

class NewTweetViewController: UIViewController {

    @IBOutlet weak var tweetsText: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var tweetId: String?
    
    weak var delegate: AddTweetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSave))

        if let user = User.currentUser {
            nameLabel.text = "@\(user.screenName!)"
            fullnameLabel.text = user.name
            if let url = user.profileBiggerUrl {
                profileImage.setImageWith(url)
            }
        }
        tweetsText.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onSave(_ sender: Any?) {
        print(tweetsText.text)
        TwitterClient.postTweet(content: tweetsText.text, replyId: tweetId, onSuccess: {
            (tweet: Tweet) -> Void in
            if (self.delegate != nil) {
                self.delegate!.addTweet(tweet: tweet)
            }
        }, onFailure: {
            (errorMsg: String) -> Void in
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let button = sender as! UIBarButtonItem
        let controller = segue.destination as! UINavigationController
        let vc = controller.topViewController as! TweetsViewController
        
        if (button == navigationItem.leftBarButtonItem) {
            // is cancel
            print("CANCEL")
        } else {
            // is search
            print("TWEET")
            print(tweetsText.text)
            TwitterClient.postTweet(content: tweetsText.text, replyId: tweetId, onSuccess: {
                (tweet: Tweet) -> Void in
                vc.addTweet(tweet: tweet)
            }, onFailure: {
                (errorMsg: String) -> Void in
            })
        }
    }
}
