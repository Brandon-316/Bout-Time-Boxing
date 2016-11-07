//
//  EventDetailViewController.swift
//  Bout Time
//
//  Created by Brandon Mahoney on 11/2/16.
//  Copyright © 2016 Brandon Mahoney. All rights reserved.
//

import Foundation
import UIKit

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var EventWebView: UIWebView!
    @IBAction func DismissButton(_ sender: AnyObject) {
                self.dismiss(animated: true, completion: nil)
//                _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    var urlWebsite: String?

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let myURLString = urlWebsite
        let myURL = URL(string: myURLString!)
        let myURLRequest = URLRequest(url: myURL!)
        EventWebView.loadRequest(myURLRequest)
        self.EventWebView.scalesPageToFit = true
        

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
