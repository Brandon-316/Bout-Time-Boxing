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


//Extensions
extension Array {
    var shuffle:[Element] {
        var elements = self
        for index in 0..<elements.count {
            let anotherIndex = Int(arc4random_uniform(UInt32(elements.count-index)))+index
            if anotherIndex != index {
                swap(&elements[index], &elements[anotherIndex])
            }
        }
        return elements
    }
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension UIButton{
    func roundedButton(){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [.topLeft , .bottomLeft],
                                     cornerRadii:CGSize(5.0, 5.0))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
}

class ViewController: UIViewController {
    
    var events = [EventDetail]()
    
    let questionsPerRound = 6
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedEvent: Int = 0
    
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 1
    var startSound: SystemSoundID = 2
    var endSound: SystemSoundID = 3
    
    var countdown = Timer()
    var count = 60
    
    var eventBtn1URL = ""
    var eventBtn2URL = ""
    var eventBtn3URL = ""
    var eventBtn4URL = ""
    
    var location1Btn: UIButton!
    var location2Btn: UIButton!
    var location3Btn: UIButton!
    var location4Btn: UIButton!

    
//Event Buttons
    @IBOutlet weak var event1Button: UIButton!
    @IBAction func event1Seque(_ sender: Any) {
            self.performSegue(withIdentifier: "EventDetailSeque", sender: eventBtn1URL)
    }
    @IBOutlet weak var event2Button: UIButton!
    @IBAction func event2Seque(_ sender: Any) {
        self.performSegue(withIdentifier: "EventDetailSeque", sender: eventBtn2URL)
    }
    @IBOutlet weak var event3Button: UIButton!
    @IBAction func event3Seque(_ sender: Any) {
        self.performSegue(withIdentifier: "EventDetailSeque", sender: eventBtn3URL)
    }
    @IBOutlet weak var event4Button: UIButton!
    @IBAction func event4Seque(_ sender: Any) {
        self.performSegue(withIdentifier: "EventDetailSeque", sender: eventBtn4URL)
    }
    
//Round Results, label and Timer
    @IBOutlet weak var resultsField: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    

    @IBOutlet weak var playAgainButton: UIButton!
    @IBAction func playAgainButton(_ sender: Any) {
        loadGameStartSound()
        playGameStartSound()
        questionsAsked = 0
        correctQuestions = 0
        resetCount()
        displayEvent()
    }
    @IBOutlet weak var nextRoundButton: UIButton!
    @IBAction func nextRoundButton(_ sender: Any) {
        resetCount()
        nextRound()
    }

    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var yourScoreLabel: UILabel!

//Arrow Buttons
    @IBOutlet weak var label1Button: UIButton!
    @IBAction func label1Button(_ sender: AnyObject) {
        SetLocations()
        let location1 = label1Button.frame.origin.y
        let location2 = label2UpButton.frame.origin.y
        
        UIButton.animate(withDuration: 1.0, animations: {
            self.location1Btn.frame.origin.y = location2
            self.location2Btn.frame.origin.y = location1
        })
    }
    
    @IBOutlet weak var label2UpButton: UIButton!
    @IBAction func label2UpButton(_ sender: AnyObject) {
        SetLocations()
        let location1 = label2UpButton.frame.origin.y
        let location2 = label1Button.frame.origin.y
    
            UIButton.animate(withDuration: 1.0, animations:{
                self.location2Btn.frame.origin.y = location2
                self.location1Btn.frame.origin.y = location1
            })
        }
    
    @IBOutlet weak var label2DownButton: UIButton!
    @IBAction func label2DownButton(_ sender: AnyObject) {
        SetLocations()
        let location1 = label2UpButton.frame.origin.y
        let location2 = label3UpButton.frame.origin.y
        
        UIButton.animate(withDuration: 1.0, animations:{
            self.location2Btn.frame.origin.y = location2
            self.location3Btn.frame.origin.y = location1
        })
    }
    
    @IBOutlet weak var label3UpButton: UIButton!
    @IBAction func label3UpButton(_ sender: AnyObject) {
        SetLocations()
        let location1 = label3UpButton.frame.origin.y
        let location2 = label2UpButton.frame.origin.y
        
        UIButton.animate(withDuration: 1.0, animations:{
            self.location3Btn.frame.origin.y = location2
            self.location2Btn.frame.origin.y = location1
        })
    }
    
    @IBOutlet weak var label3DownButton: UIButton!
    @IBAction func label3DownButton(_ sender: AnyObject) {
        SetLocations()
        let location1 = label3UpButton.frame.origin.y
        let location2 = label4Button.frame.origin.y
        
        UIButton.animate(withDuration: 1.0, animations:{
            self.location3Btn.frame.origin.y = location2
            self.location4Btn.frame.origin.y = location1
        })
    }
    
    @IBOutlet weak var label4Button: UIButton!
    @IBAction func label4Button(_ sender: AnyObject) {
        SetLocations()
        let location1 = label4Button.frame.origin.y
        let location2 = label3UpButton.frame.origin.y
        
        UIButton.animate(withDuration: 1.0, animations:{
            self.location4Btn.frame.origin.y = location2
            self.location3Btn.frame.origin.y = location1
        })
    }


//viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        label1Button.setImage(#imageLiteral(resourceName: "down_full_selected.png"), for: .highlighted)
        label2UpButton.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: .highlighted)
        label2DownButton.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: .highlighted)
        label3UpButton.setImage(#imageLiteral(resourceName: "up_half_selected.png"), for: .highlighted)
        label3DownButton.setImage(#imageLiteral(resourceName: "down_half_selected.png"), for: .highlighted)
        label4Button.setImage(#imageLiteral(resourceName: "up_full_selected.png"), for: .highlighted)
        
        event1Button.roundedButton()
        event2Button.roundedButton()
        event3Button.roundedButton()
        event4Button.roundedButton()

        assignEvents()
        displayEvent()
        loadGameStartSound()
        playGameStartSound()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
//Assign Events
    func assignEvents() {
        for eventData in Events().library {
            let event = EventDetail(dictionary: eventData)
            events.append(event)
        }
    }
    
//Set Array of Random Numbers
    func uniqueRandoms(numberOfRandoms: Int, minNum: Int, maxNum: UInt32) -> [Int] {
        var uniqueNumbers = Set<Int>()
        while uniqueNumbers.count < numberOfRandoms {
            uniqueNumbers.insert(Int(arc4random_uniform(maxNum + 1)) + minNum)
        }
        return Array(uniqueNumbers).shuffle
    }

////Display Events
    func displayEvent() {
        let eventsCount = Int(events.count) - 1
        var eventArray = uniqueRandoms(numberOfRandoms: 4, minNum: 0, maxNum: UInt32(eventsCount))
        
        let eventsDictionary1 = events[Int(eventArray[0])]
        let eventsDictionary2 = events[Int(eventArray[1])]
        let eventsDictionary3 = events[Int(eventArray[2])]
        let eventsDictionary4 = events[Int(eventArray[3])]
        
        event1Button.setTitle(eventsDictionary1.event, for: .normal)
        event1Button.tag = Int(eventsDictionary1.date!)!
        event1Button.isUserInteractionEnabled = false
        event2Button.setTitle(eventsDictionary2.event, for: .normal)
        event2Button.tag = Int(eventsDictionary2.date!)!
        event2Button.isUserInteractionEnabled = false
        event3Button.setTitle(eventsDictionary3.event, for: .normal)
        event3Button.tag = Int(eventsDictionary3.date!)!
        event3Button.isUserInteractionEnabled = false
        event4Button.setTitle(eventsDictionary4.event, for: .normal)
        event4Button.tag = Int(eventsDictionary4.date!)!
        event4Button.isUserInteractionEnabled = false
        

        
        eventBtn1URL = eventsDictionary1.url!
        eventBtn2URL = eventsDictionary2.url!
        eventBtn3URL = eventsDictionary3.url!
        eventBtn4URL = eventsDictionary4.url!
    
        label1Button.isHidden = false
        label2UpButton.isHidden = false
        label2DownButton.isHidden = false
        label3UpButton.isHidden = false
        label3DownButton.isHidden = false
        label4Button.isHidden = false
        event1Button.isHidden = false
        event2Button.isHidden = false
        event3Button.isHidden = false
        event4Button.isHidden = false
        playAgainButton.isHidden = true
        nextRoundButton.isHidden = true
        yourScoreLabel.isHidden = true
        resultsField.isHidden = true
        countdownLabel.isHidden = false
        instructionLabel.isHidden = false
        instructionLabel.text = "Shake to complete"
        startCountdown()
    }
    
    
//Display Score
    func displayScore() {
        // Hide the answer buttons
        label1Button.isHidden = true
        label2UpButton.isHidden = true
        label2DownButton.isHidden = true
        label3UpButton.isHidden = true
        label3DownButton.isHidden = true
        label4Button.isHidden = true
        event1Button.isHidden = true
        event2Button.isHidden = true
        event3Button.isHidden = true
        event4Button.isHidden = true
        countdownLabel.isHidden = true
        instructionLabel.isHidden = true
        nextRoundButton.isHidden = true
        // Display play again button
        playAgainButton.isHidden = false
        yourScoreLabel.isHidden = false
        resultsField.text = "\(correctQuestions)/\(questionsPerRound)"
        resultsField.isHidden = false
    }
    
//Check Answer
    func checkAnswer() {
        questionsAsked += 1
        SetLocations()
        nextRoundButton.isHidden = false
        instructionLabel.text = "Tap events to learn more"
        if location1Btn.tag < location2Btn.tag && location2Btn.tag < location3Btn.tag && location3Btn.tag < location4Btn.tag{
            correctQuestions += 1
            
            event1Button.isUserInteractionEnabled = true
            event2Button.isUserInteractionEnabled = true
            event3Button.isUserInteractionEnabled = true
            event4Button.isUserInteractionEnabled = true

            countdown.invalidate()
            loadCorrectSound()
            playCorrectSound()
            nextRoundButton.setImage(#imageLiteral(resourceName: "next_round_success.png"), for: .normal)
        }else{
            //Show red button
            event1Button.isUserInteractionEnabled = true
            event2Button.isUserInteractionEnabled = true
            event3Button.isUserInteractionEnabled = true
            event4Button.isUserInteractionEnabled = true
            countdown.invalidate()
            loadIncorrectSound()
            playIncorrectSound()
            nextRoundButton.setImage(#imageLiteral(resourceName: "next_round_fail.png"), for: .normal)
        }
    }
    
    
//Play Again

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
            loadGameEndSound()
            playGameEndSound()
            assignEvents()
        } else {
            // Continue game
            displayEvent()
        }
    }
    
//Countdown Timer
    func startCountdown() {
        countdown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.runCountdown), userInfo: nil, repeats: true)
    }
    
    func runCountdown() {
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
    

//Set Locations
    //Set Location 1
    func SetLocations(){
        if event1Button.frame.origin.y == label1Button.frame.origin.y {
            location1Btn = event1Button
        }else if event2Button.frame.origin.y == label1Button.frame.origin.y {
            location1Btn = event2Button
        }else if event3Button.frame.origin.y == label1Button.frame.origin.y {
            location1Btn = event3Button
        }else{
            location1Btn = event4Button
        }
        //Set Location 2
        if event1Button.frame.origin.y == label2UpButton.frame.origin.y {
            location2Btn = event1Button
        }else if event2Button.frame.origin.y == label2UpButton.frame.origin.y {
            location2Btn = event2Button
        }else if event3Button.frame.origin.y == label2UpButton.frame.origin.y {
            location2Btn = event3Button
        }else{
            location2Btn = event4Button
        }
        //Set Location 3
        if event1Button.frame.origin.y == label3UpButton.frame.origin.y {
            location3Btn = event1Button
        }else if event2Button.frame.origin.y == label3UpButton.frame.origin.y {
            location3Btn = event2Button
        }else if event3Button.frame.origin.y == label3UpButton.frame.origin.y {
            location3Btn = event3Button
        }else{
            location3Btn = event4Button
        }
        //Set Location 4
        if event1Button.frame.origin.y == label4Button.frame.origin.y {
            location4Btn = event1Button
        }else if event2Button.frame.origin.y == label4Button.frame.origin.y {
            location4Btn = event2Button
        }else if event3Button.frame.origin.y == label4Button.frame.origin.y {
            location4Btn = event3Button
        }else{
            location4Btn = event4Button
        }
    }
    
    
    
//Game Sounds
    func loadGameStartSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "Boxing Bell Start Round", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &startSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(startSound)
    }
    
    
    func loadGameEndSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "Boxing Bell End Round", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &endSound)
    }
    
    func playGameEndSound() {
        AudioServicesPlaySystemSound(endSound)
    }
    func loadCorrectSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "CorrectDing", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &correctSound)
    }
    
    func playCorrectSound() {
        AudioServicesPlaySystemSound(correctSound)
    }
    
    func loadIncorrectSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "IncorrectBuzz", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &incorrectSound)
    }
    
    func playIncorrectSound() {
        AudioServicesPlaySystemSound(incorrectSound)
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
        checkAnswer()
    }
    
    
    
    
    
    

}

