//
//  SoundLogic.swift
//  Bout Time
//
//  Created by Brandon Mahoney on 5/30/18.
//  Copyright © 2018 Brandon Mahoney. All rights reserved.
//

import Foundation
import UIKit
import GameKit
import AudioToolbox

class SoundLogic {
    
    //Sound Clip File Variables//
    let soundType = "wav"
    let startSoundFile = "Boxing Bell Start Round"
    let endSoundFile = "Boxing Bell End Round"
    let correctSoundFile = "CorrectDing"
    let incorrectSoundFile = "IncorrectBuzz"
    
    //System Sound ID's//
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 1
    var startSound: SystemSoundID = 2
    var endSound: SystemSoundID = 3
    
    
    
    func playSound(sound: inout SystemSoundID, soundType: Sound) {
        let pathToSoundFile = Bundle.main.path(forResource: soundType.fileName, ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
        AudioServicesPlaySystemSound(sound)
    }
    
}


enum Sound {
    case start
    case end
    case correct
    case incorrect
    
    var soundID: SystemSoundID {
        switch self {
            case .correct: return 0
            case .incorrect: return 1
            case .start: return 2
            case .end: return 3
        }
    }
    
    var fileName: String {
        switch self {
        case .correct: return "CorrectDing"
        case .incorrect: return "IncorrectBuzz"
        case .start: return "Boxing Bell Start Round"
        case .end: return "Boxing Bell End Round"
        }
    }
}
