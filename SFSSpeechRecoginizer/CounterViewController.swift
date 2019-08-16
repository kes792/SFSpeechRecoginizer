//
//  CounterViewController.swift
//  Counter
//
//  Created by Suyeol Jeon on 02/05/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

// Conform to the protocol `View` then the property `self.reactor` will be available.
final class CounterViewController: UIViewController, StoryboardView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var microphoneButton: UIButton!
    @IBOutlet var textLabel: UILabel!
    
    @IBOutlet var decreaseButton: UIButton!
    @IBOutlet var increaseButton: UIButton!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    var disposeBag = DisposeBag()
    
    
    // Called when the new value is assigned to `self.reactor`
    func bind(reactor: CounterViewReactor) {
        // Action
        increaseButton.rx.tap               // Tap event
            .map { Reactor.Action.increase }  // Convert to Action.increase
            .bind(to: reactor.action)         // Bind to reactor.action
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .map { Reactor.Action.decrease }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        microphoneButton.rx.controlEvent([.touchDown])
            .map { Reactor.Action.startRecording }  // Convert to Action.increase
            .bind(to: reactor.action)         // Bind to reactor.action
            .disposed(by: disposeBag)
        
        microphoneButton.rx.controlEvent([.touchUpInside])
            .map { Reactor.Action.stopRecording }  // Convert to Action.increase
            .bind(to: reactor.action)         // Bind to reactor.action
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.value }   // 10
            .distinctUntilChanged()
            .map { "\($0)" }               // "10"
            .bind(to: valueLabel.rx.text)  // Bind to valueLabel
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.recognizeString }
            .distinctUntilChanged()
            .map { "\($0)" }
            .bind(to: textLabel.rx.text)  
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: activityIndicatorView.rx.isAnimating)
            
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.recognizeString }   // 10
            .distinctUntilChanged()
            .map { "\($0)" }               // "10"
            .bind(to: textLabel.rx.text)  // Bind to valueLabel
            .disposed(by: disposeBag)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad...")
        
        
    }
    
    
    
}
