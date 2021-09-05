//
//  KeyedDecodingContainer+Base64Encoding.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/23/21.
//

import Foundation

//Ref - https://stackoverflow.com/questions/31859185/how-to-convert-a-base64string-to-string-in-swift

extension String {
    //: ### Base64 encoding a string
        func base64Encoded() -> String {
            if let data = self.data(using: .utf8) {
                return data.base64EncodedString()
            }
            return self
        }

    //: ### Base64 decoding a string
        func base64Decoded() -> String {
            var st = self;
            if (self.count % 4 <= 2){
                st += String(repeating: "=", count: (self.count % 4))
            }
            if let data = Data(base64Encoded: st, options: .ignoreUnknownCharacters) {
                return String(data: data, encoding: .utf8) ?? self
            }
            return self
        }
}
