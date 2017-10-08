//
//  LoginViewController.swift
//  Twitter
//
//  Created by Nanxi Kang on 9/28/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import BDBOAuth1Manager
import UIKit

class LoginViewController: UIViewController {

    var hamburgerController: HamburgerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onLogin(_ sender: Any) {
        TwitterClient.deauthorize()
        TwitterClient.attemptLogin { 
            self.presentTweets()
        }
    }
    
    func presentTweets() {
        let hamburgerController = HamburgerViewController.initializeHamburgerViewController()
        dismiss(animated: true, completion: nil)
        present(hamburgerController, animated: true)
    }
}
