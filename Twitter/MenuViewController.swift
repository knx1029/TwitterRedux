//
//  MenuViewController.swift
//  Twitter
//
//  Created by Nanxi Kang on 10/7/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /*
    let MENU_ITEM: [String] = [
        "Home",
        "Profile",
        "Mentions",
        "Trends"
    ]*/
    
    @IBOutlet weak var menuTable: UITableView!
    
    var menuItems: [String] = []
    
    weak var delegate: MenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTable.dataSource = self
        menuTable.delegate = self
        menuTable.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(menuItems.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTable.dequeueReusableCell(withIdentifier: "menuCell") as! MenuTableViewCell
        cell.menuTitleLabel.text = menuItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        print("select \(menuItems[index])")
        menuTable.deselectRow(at: indexPath, animated: false)
        self.delegate?.menuSelected(index: index, itemName: menuItems[index])
    }

}
