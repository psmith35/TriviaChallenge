//
//  TCModel.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/10/21.
//

import Foundation

class TCModel {
    
    static var triviaCategories: [TriviaCategory]?
    
    static var selectedTriviaCategories: [TriviaCategory]?
    static var triviaQuestion: TriviaQuestion?
    
    static var currentScore: Int = 0 {
        didSet {
            scoreUpdateClosure?()
        }
    }
    static var scoreUpdateClosure: (() -> Void)?
    
    static var isFinishingQuiz: Bool {
        get {
            return UserDefaults.standard.bool(forKey: DefaultsKey.isFinishingQuiz.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: DefaultsKey.isFinishingQuiz.rawValue)
        }
    }
    
    // MARK: - Score Functions
    class func loadScore() {
        currentScore = UserDefaults.standard.integer(forKey: DefaultsKey.score.rawValue)
    }
    
    class func wipeScore() {
        currentScore = 0
        UserDefaults.standard.set(currentScore, forKey: DefaultsKey.score.rawValue)
    }
    
    class func updateScore(scoreAddition: Int) {
        currentScore += scoreAddition
        UserDefaults.standard.set(currentScore, forKey: DefaultsKey.score.rawValue)
    }
    
    // MARK: - Trivia Category Functions
    class func loadRandomCategories() {
        if let triviaCategories : [TriviaCategory] = UserDefaults.standard.getDecodable(for: DefaultsKey.triviaCategories.rawValue) {
            selectedTriviaCategories = triviaCategories
        }
        else {
            setRandomCategories()
        }
    }
    
    class func wipeRandomCategories() {
        selectedTriviaCategories = nil
        UserDefaults.standard.removeObject(forKey: DefaultsKey.triviaCategories.rawValue)
    }
    
    class func setRandomCategories() {
        setRandomCategories(size: 3)
    }
    
    class func setRandomCategories(size: Int) {
        var randomCategories = [TriviaCategory]()
        var categorySize = size
        if var triviaCategoryCopies = triviaCategories, triviaCategoryCopies.count >= categorySize {
            while categorySize > 0 {
                if let index = triviaCategoryCopies.indices.randomElement() {
                    let randomElement = triviaCategoryCopies.remove(at: index)
                    randomCategories.append(randomElement)
                }
                categorySize -= 1
            }
        }
        else {
            print("Couldn't get random categories.")
        }
        selectedTriviaCategories = randomCategories
        UserDefaults.standard.setEncodable(selectedTriviaCategories, for: DefaultsKey.triviaCategories.rawValue)
    }
    
    // MARK: - Question Functions
    class func loadTriviaQuestion(completion: () -> Void) {
        if let question : TriviaQuestion = UserDefaults.standard.getDecodable(for: DefaultsKey.triviaQuestion.rawValue) {
            triviaQuestion = question
            completion()
        }
    }
    
    class func wipeTriviaQuestion() {
        triviaQuestion = nil
        UserDefaults.standard.removeObject(forKey: DefaultsKey.triviaQuestion.rawValue)
    }
    
    class func setTriviaQuestion(question: TriviaQuestion) {
        triviaQuestion = question
        updateTriviaQuestion()
    }
    
    class func updateTriviaQuestion() {
        UserDefaults.standard.setEncodable(triviaQuestion, for: DefaultsKey.triviaQuestion.rawValue)
    }

}
