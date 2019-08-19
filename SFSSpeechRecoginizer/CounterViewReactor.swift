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
    
    
    var speaker = Speak()
    
    var speechRecognizer: Recognizer!
    //let speaker =
    var transcriptionString: String? = ""
    // Action is an user interaction
    enum Action {
        case increase
        case decrease
        
        case startRecording
        case stopRecording
        case cancelRecording
        case sayString
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case increaseValue
        case decreaseValue
        case setLoading(Bool)
        
        case startRecognization
        case setRecognizeString(String)
        case resetRecognizeString(String)
        case sayString

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
                Observable.just(Mutation.setLoading(false)).delay(.milliseconds(1000), scheduler: MainScheduler.instance),
                speechRecognizer.stopRecording().map(Mutation.setRecognizeString),
                ])
        case .cancelRecording:
            return Observable.concat([
                Observable.just(Mutation.setLoading(false)),
                speechRecognizer.stopRecording().map(Mutation.resetRecognizeString)
                ])
        case .sayString:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.sayString).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false)),
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
            
        case let .setRecognizeString(recognizeString) :
            print("[reduce] .setRecognizeString(recognizeString) = \(recognizeString)")
            state.recognizeString = recognizeString //!= nil ? transcriptionString! : "."
            
        case let .resetRecognizeString(recognizeString):
            print("[reduce] .resetRecognizeString(recognizeString) = \(recognizeString)")
            state.recognizeString = ""
            
        case .sayString:
            speaker.sayThis(state.recognizeString)
        }
        
        return state
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
