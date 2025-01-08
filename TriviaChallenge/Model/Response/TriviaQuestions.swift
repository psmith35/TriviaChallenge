//
//  TriviaQuestions.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/10/21.
//

struct TriviaQuestions : Codable {
    
    let responseCode : Int
    let triviaQuestions : [TriviaQuestion]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case triviaQuestions = "results"
    }

}
