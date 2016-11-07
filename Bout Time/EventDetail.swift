//
//  EventDetail.swift
//  Bout Time
//
//  Created by Brandon Mahoney on 11/3/16.
//  Copyright © 2016 Brandon Mahoney. All rights reserved.
//

import Foundation
import UIKit

struct EventDetail {
    
    var event: String?
    var date: String?
    var url: String?
    
    init(dictionary: [String: String]) {
        
        event = dictionary["Event"]
        date = dictionary["Date"]
        url = dictionary["URL"]
    }
}
