//
//  CounterViewReactor.swift
//  Counter
//
//  Created by Suyeol Jeon on 07/09/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import ReactorKit
import RxSwift

final class CounterViewReactor: Reactor, RecognizerDelegate {
    
    
    
    var speechRecognizer: Recognizer!
    var transcriptionString: String? = ""
    // Action is an user interaction
    enum Action {
        case increase
        case decrease
        
        case startRecording
        case stopRecording
        case changeRecognizeString

    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case increaseValue
        case decreaseValue
        case setLoading(Bool)
        
        case startRecognization
        case stopRecognization
        
        case getRecognizeString(String)
        case changeRecognizeString
    }
    
    // State is a current view state
    struct State {
        var value: Int = 0
        var isLoading: Bool = false
        var recognizeString: String = ""
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        
        speechRecognizer = Recognizer()
        speechRecognizer.delegate = self
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        //如果当前正在加载中则不继续
        
        
        switch action {
        case .increase:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.increaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false)),
                ])
            
        case .decrease:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.decreaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false)),
                ])
            
        case .startRecording:
            
            return Observable.concat([
                .just(Mutation.startRecognization),
                .just(Mutation.setLoading(true)),
                ])
            
        case .stopRecording:
            return Observable.concat([
                speechRecognizer.stopRecording().map(Mutation.getRecognizeString),
                Observable.just(Mutation.setLoading(false)),
                //Observable.just(Mutation.stopRecognization),
                
                ])
        
        case .changeRecognizeString:
            return Observable.concat([
                Observable.just(Mutation.changeRecognizeString),
                ])
 
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {
        case .increaseValue:
            state.value += 1
            
        case .decreaseValue:
            state.value -= 1
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            
        case .startRecognization:
            speechRecognizer.startRecording()
            state.recognizeString = ""
            
        case .stopRecognization:
            state.recognizeString = ""
        
        case let .getRecognizeString(recognizeString) :
            print("[reduce] .getRecognizeString(recognizeString) = \(recognizeString)")
            state.recognizeString = recognizeString //!= nil ? transcriptionString! : "."
            
        case .changeRecognizeString :
            print("[reduce] .changeRecognizeString = \(String(describing: self.transcriptionString))")
            state.recognizeString = self.transcriptionString ?? "" //!= nil ? transcriptionString! : "."
        
        }
        
        return state
    }
    
    
    // MARK: SBSpeechRecognitionDelegate
    func speechRecognitionFinished(transcription:String) {
        print("[speechRecognitionFinished] transcription = \(transcription)")
        self.transcriptionString = transcription
       
    }
    
    func speechRecognitionPartialResult(transcription:String) {
        print("[speechRecognitionPartialResult] transcription = \(transcription)")
        self.transcriptionString = transcription
    }
    
    func speechRecognitionTimedOut() {
        //toggleSpeechRecognition()
    }
    func speechRecognitionRecordingAuthorized(authrize: Bool) {
        OperationQueue.main.addOperation {
            //self.microphoneButton.isEnabled = isButtonEnabled
        }
    
    }
    
}
