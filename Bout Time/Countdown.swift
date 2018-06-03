//
//  Timer.swift
//  Bout Time
//
//  Created by Brandon Mahoney on 5/30/18.
//  Copyright © 2018 Brandon Mahoney. All rights reserved.
//

import Foundation


extension GameVC {
    
    //Countdown Timer
    func startCountdown() {
        countdown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameVC.runCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func runCountdown() {
        if (count > 0){
            count -= 1
            countdownLabel.text = String(count)
        }else{
            //            countdown.invalidate()
            checkAnswer()
        }
    }
    
    func resetCount() {
        countdownLabel.text = "60"
        count = 60
    }
    
}
