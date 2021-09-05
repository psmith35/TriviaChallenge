//
//  Difficulty.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/10/21.
//

enum Difficulty: String, Codable {
    
    case easy, medium, hard
    
    var pointsValue: Int {
        switch self {
            case .easy:
                return 200
            case .medium:
                return 400
            case .hard:
                return 800
        }
    }
    
    var pointsString : String {
        return "\(pointsValue) Points"
    }
        
}
