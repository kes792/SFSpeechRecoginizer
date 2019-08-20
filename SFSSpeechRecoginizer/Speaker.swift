//
//  Speaker.swift
//  SFSSpeechRecoginizer
//
//  Created by Edison on 2019/8/19.
//  Copyright © 2019 pcloudy. All rights reserved.
//

import Foundation
import AVFoundation

class Speaker : NSObject {
    let voices = AVSpeechSynthesisVoice.speechVoices()
    let voiceSynth = AVSpeechSynthesizer()
    var voiceToUse: AVSpeechSynthesisVoice?
    
    override init() {
        super.init()
        /*
        for voice in voices {
            if voice.name == "Mei-Jia"{//Sin-Ji"{//"Li-mu"{//"Ting-Ting"  {
                voiceToUse = voice
            }
        }
         */
        voiceToUse = AVSpeechSynthesisVoice(language: "zh-CN")
        voiceSynth.delegate = self
    }
    
    public func sayThis(_ phrase: String){
        
        var utterance = AVSpeechUtterance(string: phrase)
        if(phrase.count == 0){
            utterance = AVSpeechUtterance(string: "小樂精靈")
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        utterance.voice = voiceToUse
        utterance.rate = 0.5
        
        voiceSynth.speak(utterance)
        
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

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("All done")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Start")
    }
}


