//
//  MenuDelegate.swift
//  Twitter
//
//  Created by Nanxi Kang on 10/8/17.
//  Copyright © 2017 Nanxi Kang. All rights reserved.
//

import Foundation

protocol MenuDelegate: class {
    
    func menuSelected(index: Int, itemName: String)
}
