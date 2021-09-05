//
//  UserDefaults+Codable.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/22/21.
//

import Foundation

//Ref - https://stackoverflow.com/questions/41355427/attempt-to-insert-non-property-list-object-when-trying-to-save-a-custom-object-i
extension UserDefaults {
    func setEncodable<T: Encodable>(_ encodable: T, for key: String) {
        guard let data = try? PropertyListEncoder().encode(encodable) else {
            return
        }
        self.set(data, forKey: key)
    }

    func getDecodable<T: Decodable>(for key: String) -> T? {
        guard
            self.object(forKey: key) != nil,
            let data = self.value(forKey: key) as? Data
        else {
            return nil
        }

        let obj = try? PropertyListDecoder().decode(T.self, from: data)
        return obj
    }
}
