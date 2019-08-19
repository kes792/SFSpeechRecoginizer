//
//  Recognizer.swift
//  Counter
//
//  Created by Edison on 2019/8/15.
//  Copyright © 2019 Suyeol Jeon. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

import Speech

public protocol RecognizerDelegate: class {
    func speechRecognitionFinished(transcription:String)
    func speechRecognitionPartialResult(transcription:String)
    func speechRecognitionRecordingAuthorized(authrize: Bool)
    func speechRecognitionTimedOut()
}

class Recognizer :NSObject, SFSpeechRecognizerDelegate{
    
    public weak var delegate: RecognizerDelegate?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    var transcriptionString = ""

    
    public override init() {
        super.init()
        
        setupSpeechRecognition()
    }
    
    private func setupSpeechRecognition() {
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization{(authStatus) in
            
            self.delegate?.speechRecognitionRecordingAuthorized(
                authrize: authStatus == SFSpeechRecognizerAuthorizationStatus.authorized)
        }
    }
    
    private var speechRecognitionTimeout: Timer?
    
    public var speechTimeoutInterval: TimeInterval = 2 {
        didSet {
            restartSpeechTimeout()
        }
    }
    
    private func restartSpeechTimeout() {
        speechRecognitionTimeout?.invalidate()
        
        speechRecognitionTimeout = Timer.scheduledTimer(timeInterval:speechTimeoutInterval, target: self, selector: #selector(timedOut), userInfo: nil, repeats: false)
    }
    
    public func startRecording()  {
     
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.recognitionTask = nil
            self.recognitionRequest = nil
        }
       
        // Setup input source
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
    
        }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
           
            if let result = result {
                isFinal = result.isFinal
                //self.delegate?.speechRecognitionPartialResult(transcription: result.bestTranscription.formattedString)
                print("[recognitionTask] speechRecognitionPartialResult = \(self.transcriptionString)")

                self.transcriptionString = result.bestTranscription.formattedString

            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
            
            if isFinal {
                //self.delegate?.speechRecognitionFinished(transcription: result!.bestTranscription.formattedString)
                print("[recognitionTask] speechRecognitionFinished = \(self.transcriptionString)")

                self.transcriptionString = result!.bestTranscription.formattedString
                
                //self.stopRecording().map(CounterViewReactor.Mutation.getRecognizeString)
           
            }
            else {
                if error == nil {
                    self.restartSpeechTimeout()
                }
                else {
                    // cancel voice recognition

                }
                //self.transcriptionString = result!.bestTranscription.formattedString
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do{
            try audioEngine.start()
        }catch {
            print("audioEngine start failed")
        }
        
    }
    
    @objc private func timedOut() {
        //stopRecording()
        
        self.delegate?.speechRecognitionTimedOut()
    }
    
    public func stopRecording() -> Observable<String> {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0) // Remove tap on bus when stopping recording.
        
        recognitionRequest?.endAudio()
        
        speechRecognitionTimeout?.invalidate()
        speechRecognitionTimeout = nil
        
        print("[stopRecording] self.transcriptionString = \(self.transcriptionString)")

        
        return Observable<String>.create{observer in
            //对订阅者发出了.next事件，且携带了一个数据"hangge.com"
            observer.onNext(self.transcriptionString)
            //对订阅者发出了.completed事件
            observer.onCompleted()
            //因为一个订阅行为会有一个Disposable类型的返回值，所以在结尾一定要returen一个Disposable
            return Disposables.create()
        }
    }
}
