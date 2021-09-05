//
//  CategoryList.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/10/21.
//

struct CategoryList : Codable {
    
    let triviaCategories : [TriviaCategory]
    
    enum CodingKeys: String, CodingKey {
        case triviaCategories = "trivia_categories"
    }

}
