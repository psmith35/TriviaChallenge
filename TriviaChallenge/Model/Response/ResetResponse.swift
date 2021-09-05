//
//  ResetResponse.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/8/21.
//

struct ResetResponse : Codable {
    
    let responseCode : Int
    let sessionToken : String
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case sessionToken = "token"
    }

}
