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
    var transcriptionString: String? = nil
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
        case getRecognizeString

    }
    
    // State is a current view state
    struct State {
        var value: Int
        var isLoading: Bool
        var recognizeString: String
    }
    
    let initialState: State
    
    init() {
        self.initialState = State(
            value: 0, // start from 0
            isLoading: false,
            recognizeString: ""
        )
        
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
                Observable.just(Mutation.startRecognization),
                Observable.just(Mutation.setLoading(true)),
                ])
            
        case .stopRecording:
            return Observable.concat([
                Observable.just(Mutation.setLoading(false)).delay(.milliseconds(1000), scheduler: MainScheduler.instance),
                Observable.just(Mutation.stopRecognization),
                
                ])
            
        case .changeRecognizeString:
            return Observable.concat([
                Observable.just(Mutation.getRecognizeString),
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
            do {
                try speechRecognizer.startRecording()
            }
            catch {
                print(error)
            }
            
        case .stopRecognization:
            speechRecognizer.stopRecording()
            state.recognizeString = transcriptionString != nil ? transcriptionString! : "."
        
        case .getRecognizeString:
            state.recognizeString = transcriptionString != nil ? transcriptionString! : "."
    }
        
        return state
    }
    
    
    // MARK: SBSpeechRecognitionDelegate
    func speechRecognitionFinished(transcription:String) {
        print("[speechRecognitionFinished] transcription = \(transcription)")
        transcriptionString = transcription
        mutate(action: .changeRecognizeString)
    }
    
    func speechRecognitionPartialResult(transcription:String) {
        print("[speechRecognitionPartialResult] transcription = \(transcription)")
        transcriptionString = transcription
        mutate(action: .changeRecognizeString)
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
