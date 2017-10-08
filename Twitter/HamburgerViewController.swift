//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Nanxi Kang on 10/7/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController, MenuDelegate {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentLeftMargin: NSLayoutConstraint!
    
    var originalLeftMargine: CGFloat!
    
    var controllers: [UIViewController] = []
    
    var menuController: MenuViewController! {
        didSet {
            view.layoutIfNeeded()
            
            menuController.willMove(toParentViewController: self)
            menuView.addSubview(menuController.view)
            menuController.didMove(toParentViewController: self)
        }
    }
    
    var contentController: UIViewController! {
        didSet(oldContentController) {
            view.layoutIfNeeded()
            
            if oldContentController != nil {
                oldContentController.willMove(toParentViewController: self)
                oldContentController.view.removeFromSuperview()
                oldContentController.didMove(toParentViewController: self)
            }
            
            contentController.willMove(toParentViewController: self)
            contentView.addSubview(contentController.view)
            contentController.didMove(toParentViewController: self)
            self.contentLeftMargin.constant = 0.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            originalLeftMargine = contentLeftMargin.constant
        } else if sender.state == .changed {
            contentLeftMargin.constant = CGFloat.maximum(originalLeftMargine + translation.x, 0.0)
            
        } else if sender.state == .ended {
            if velocity.x > 0 {
                openMenu()
            } else {
                closeMenu()
            }
        }
        view.layoutIfNeeded()
    }
    
    private func openMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentLeftMargin.constant = self.view.frame.width - 150
        })
    }
    
    private func closeMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentLeftMargin.constant = 0
        })
    }
    
    func menuSelected(index: Int, itemName: String) {
        self.contentController = self.controllers[index]
        closeMenu()
    }
    
    class func initializeHamburgerViewController() -> HamburgerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hamburgerController = storyboard.instantiateViewController(withIdentifier: "hamburgerVC") as! HamburgerViewController
        
        let menuController = storyboard.instantiateViewController(withIdentifier: "menuVC") as! MenuViewController
        menuController.menuItems = ["Home", "Profile", "Mentions"]
        menuController.delegate = hamburgerController
        hamburgerController.menuController = menuController
        
        let homeController = storyboard.instantiateViewController(withIdentifier: "tweetsNaVC") as! UINavigationController
        let profileController = storyboard.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        let mentionController = storyboard.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        profileController.onlyMentions = false
        profileController.user = User(copyFrom: User.currentUser!)
        
        mentionController.onlyMentions = true
        mentionController.user = User(copyFrom: User.currentUser!)
        
        
        hamburgerController.controllers = [homeController, profileController, mentionController]
        hamburgerController.contentController = homeController
        return hamburgerController
    }
}
