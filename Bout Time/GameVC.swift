//
//  ViewController.swift
//  Bout Time
//
//  Created by Brandon Mahoney on 11/2/16.
//  Copyright © 2016 Brandon Mahoney. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox


class GameVC: UIViewController {
    
// MARK: Variables
    var events = [EventDetail]()
    let questionsPerRound = 6
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedEvent: Int = 0
    //System Sound ID's//
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 1
    var startSound: SystemSoundID = 2
    var endSound: SystemSoundID = 3
    let sound = SoundLogic()
    
    var countdown = Timer()
    var count = 60
    
    var eventBtn1URL = ""
    var eventBtn2URL = ""
    var eventBtn3URL = ""
    var eventBtn4URL = ""

    
// MARK: Outlets
    @IBOutlet weak var event1Button: UIButton!
    @IBOutlet weak var event2Button: UIButton!
    @IBOutlet weak var event3Button: UIButton!
    @IBOutlet weak var event4Button: UIButton!
    @IBOutlet weak var eventsStack: UIStackView!
    @IBOutlet weak var arrowStack: UIStackView!
    //Round Results, label and Timer
    @IBOutlet weak var resultsField: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var nextRoundButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var yourScoreLabel: UILabel!
    //Arrow Buttons
    @IBOutlet weak var label1Button: UIButton!
    @IBOutlet weak var label2UpButton: UIButton!
    @IBOutlet weak var label2DownButton: UIButton!
    @IBOutlet weak var label3UpButton: UIButton!
    @IBOutlet weak var label3DownButton: UIButton!
    @IBOutlet weak var label4Button: UIButton!


// MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        label1Button.setImage(#imageLiteral(resourceName: "down_full_selected.png"), for: .highlighted)
        label2UpButton.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: .highlighted)
        label2DownButton.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: .highlighted)
        label3UpButton.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: .highlighted)
        label3DownButton.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: .highlighted)
        label4Button.setImage(#imageLiteral(resourceName: "up_full_selected.png"), for: .highlighted)

        assignEvents()
        displayEvent()
        sound.playSound(sound: &startSound, soundType: .start)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        roundButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: Methods
    //Assign Events
    func assignEvents() {
        for eventData in Events().library {
            let event = EventDetail(dictionary: eventData)
            events.append(event)
        }
    }
    
    //Set Array of Random Numbers - Not in use
    func uniqueRandoms(numberOfRandoms: Int, minNum: Int, maxNum: UInt32) -> [Int] {
        var uniqueNumbers = Set<Int>()
        while uniqueNumbers.count < numberOfRandoms {
            uniqueNumbers.insert(Int(arc4random_uniform(maxNum + 1)) + minNum)
        }
        return Array(uniqueNumbers).shuffle
    }

    //Display Events
    func displayEvent() {
//        let eventsCount = Int(events.count) - 1
//        var eventArray = uniqueRandoms(numberOfRandoms: 4, minNum: 0, maxNum: UInt32(eventsCount))
        
        events = events.shuffle
        
//        let eventsDictionary1 = events[Int(eventArray[0])]
        let eventsDictionary1 = events[0]
        let eventsDictionary2 = events[1]
        let eventsDictionary3 = events[2]
        let eventsDictionary4 = events[3]

        event1Button.setTitle(eventsDictionary1.event, for: .normal)
        event1Button.tag = Int(eventsDictionary1.date!)!
        event2Button.setTitle(eventsDictionary2.event, for: .normal)
        event2Button.tag = Int(eventsDictionary2.date!)!
        event3Button.setTitle(eventsDictionary3.event, for: .normal)
        event3Button.tag = Int(eventsDictionary3.date!)!
        event4Button.setTitle(eventsDictionary4.event, for: .normal)
        event4Button.tag = Int(eventsDictionary4.date!)!
        
        handleInteractionEnabled()
        
        eventBtn1URL = eventsDictionary1.url!
        eventBtn2URL = eventsDictionary2.url!
        eventBtn3URL = eventsDictionary3.url!
        eventBtn4URL = eventsDictionary4.url!
        
        handleIsHidden(displayScore: false)
        instructionLabel.text = "Shake to complete"
        startCountdown()
    }
    
    //Display Score
    func displayScore() {
        resultsField.text = "\(correctQuestions)/\(questionsPerRound)"
        handleIsHidden(displayScore: true)
    }
    
    //Check Answer
    func checkAnswer() {
        let event1 = eventsStack.arrangedSubviews[0] as! UIButton
        let event2 = eventsStack.arrangedSubviews[1] as! UIButton
        let event3 = eventsStack.arrangedSubviews[2] as! UIButton
        let event4 = eventsStack.arrangedSubviews[3] as! UIButton
        
        questionsAsked += 1
//        nextRoundButton.isHidden = false
        nextRoundButton.alpha = 1
        countdownLabel.alpha = 0
        instructionLabel.text = "Tap events to learn more"
        if event1.tag < event2.tag && event2.tag < event3.tag && event3.tag < event4.tag {
            correctQuestions += 1
            
            handleInteractionEnabled()

            countdown.invalidate()
            sound.playSound(sound: &correctSound, soundType: .correct)
            nextRoundButton.setImage(#imageLiteral(resourceName: "next_round_success.png"), for: .normal)
        }else{
            //Show red button
            handleInteractionEnabled()
            
            countdown.invalidate()
            sound.playSound(sound: &incorrectSound, soundType: .incorrect)
            nextRoundButton.setImage(#imageLiteral(resourceName: "next_round_fail.png"), for: .normal)
        }
    }

    //Load Next Round
    func loadNextRoundWithDelay(seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.resetCount()
            self.nextRound()
        }
    }
    
    //Next Round
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore()
            sound.playSound(sound: &endSound, soundType: .end)
//            assignEvents()
        } else {
            // Continue game
            displayEvent()
        }
    }
    
    //Button methods
    func handleInteractionEnabled() {
        let buttons = [event1Button, event2Button, event3Button, event4Button]
        for button in buttons {
            button?.isUserInteractionEnabled = !(button?.isUserInteractionEnabled)!
        }
    }
    
    func roundButtons() {
        let buttons = [event1Button, event2Button, event3Button, event4Button]
        for button in buttons {
            button?.roundedButton()
        }
    }
    
    func handleIsHidden(displayScore: Bool) {
        let gamePlayBtns = [label1Button, label2UpButton, label2DownButton, label3UpButton, label3DownButton, label4Button, event1Button, event2Button, event3Button, event4Button]
        let gamePlayLabels = [countdownLabel, instructionLabel]
        let showScoreLabels = [yourScoreLabel, resultsField]
        
        for btn in gamePlayBtns {
            btn?.isHidden = displayScore
        }
        for label in gamePlayLabels {
            label?.isHidden = displayScore
        }
        for label in showScoreLabels {
            label?.isHidden = !displayScore
        }
        
//        nextRoundButton.isHidden = true
        nextRoundButton.alpha = 0
        countdownLabel.alpha = 1
        
        playAgainButton.isHidden = !displayScore
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "EventDetailSeque" {
            let websiteController = segue.destination as! EventDetailViewController
            websiteController.urlWebsite = sender as? String
        }
        
    }

    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if countdown.isValid {
            checkAnswer()
        }
    }
    
// MARK: Actions
    @IBAction func nextRoundButton(_ sender: Any) {
        resetCount()
        nextRound()
    }
    
    @IBAction func playAgainButton(_ sender: Any) {
        sound.playSound(sound: &startSound, soundType: .start)
        questionsAsked = 0
        correctQuestions = 0
        resetCount()
        displayEvent()
    }
    
    @IBAction func arrowPressed(_ sender: UIButton) {
        var event: UIButton?
        var index: Int?
        
        switch sender.tag {
            case 1: event = eventsStack.arrangedSubviews[0] as? UIButton
                            index = 1
            case 2: event = eventsStack.arrangedSubviews[1] as? UIButton
                            index = 0
            case 3: event = eventsStack.arrangedSubviews[1] as? UIButton
                            index = 2
            case 4: event = eventsStack.arrangedSubviews[2] as? UIButton
                            index = 1
            case 5: event = eventsStack.arrangedSubviews[2] as? UIButton
                            index = 3
            case 6: event = eventsStack.arrangedSubviews[3] as? UIButton
                            index = 2
            default: return
        }
        
        UIView.animate(withDuration: 0.3, animations:{
            self.eventsStack.removeArrangedSubview(event!)
            self.eventsStack.insertArrangedSubview(event!, at: index!)
            self.eventsStack.layoutIfNeeded()
        })
    }
    
    @IBAction func eventSeque(_ sender: UIButton) {
        var url = ""
        guard let id = sender.restorationIdentifier else { return }
        
        switch id {
            case "1": url = eventBtn1URL
            case "2": url = eventBtn2URL
            case "3": url = eventBtn3URL
            case "4": url = eventBtn4URL
            default: return
        }
        self.performSegue(withIdentifier: "EventDetailSeque", sender: url)
    }
}
