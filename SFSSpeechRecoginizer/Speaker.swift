//
//  Speaker.swift
//  SFSSpeechRecoginizer
//
//  Created by Edison on 2019/8/19.
//  Copyright © 2019 pcloudy. All rights reserved.
//

import Foundation
import AVFoundation

class Speak {
    
    let voices = AVSpeechSynthesisVoice.speechVoices()
    let voiceSynth = AVSpeechSynthesizer()
    var voiceToUse: AVSpeechSynthesisVoice?
    
    init() {
        for voice in voices {
            if voice.name == "Samantha (Enhanced)"  && voice.quality == .enhanced {
                voiceToUse = voice
            }
        }
    }
    
    
    public func sayThis(_ phrase: String){
        let utterance = AVSpeechUtterance(string: phrase)
        

        
        
        voiceSynth.speak(utterance)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
        
        do {
            disableAVSession()
        }
    }
    
    private func disableAVSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't disable.")
        }
    }
}
