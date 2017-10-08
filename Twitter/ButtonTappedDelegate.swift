//
//  ButtonTappedDelegate.swift
//  Twitter
//
//  Created by Nanxi Kang on 10/8/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import Foundation
import UIKit

protocol ButtonTappedDelegate: class {
    func onFav(tweet: Tweet, favButton: UIButton)
    
    func onRetweet(tweet: Tweet, retweetButton: UIButton)
    
    func onReply(tweet: Tweet, replyButton: UIButton)
    
    func onProfile(tweet: Tweet)
}
