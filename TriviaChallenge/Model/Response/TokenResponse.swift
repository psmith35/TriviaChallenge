//
//  TokenResponse.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/8/21.
//

struct TokenResponse : Codable {
    
    let responseCode : Int
    let responseMessage : String
    let sessionToken : String
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseMessage = "response_message"
        case sessionToken = "token"
    }

}
