//
//  TriviaQuestion.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/10/21.
//

enum QuestionType: String, Codable {
    case multiple, boolean
}

struct TriviaQuestion : Codable {
    
    let category: String
    let type: QuestionType
    let difficulty: Difficulty
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let answers: [String]
    var submittedAnswer: String?
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
        case answers,submittedAnswer
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        category = try values.decode(String.self, forKey: .category).base64Decoded()
        type = try QuestionType(rawValue: values.decode(String.self, forKey: .type).base64Decoded())!
        difficulty = try Difficulty(rawValue: values.decode(String.self, forKey: .difficulty).base64Decoded())!
        question = try values.decode(String.self, forKey: .question).base64Decoded()
        correctAnswer = try values.decode(String.self, forKey: .correctAnswer).base64Decoded()
        
        var incorrectAnswerList = try values.decode([String].self, forKey: .incorrectAnswers)
        for i in 0..<incorrectAnswerList.count {
            incorrectAnswerList[i] = incorrectAnswerList[i].base64Decoded()
        }
        incorrectAnswers = incorrectAnswerList
        
        if let answers = try values.decodeIfPresent([String].self, forKey: .answers) {
            self.answers = answers
        }
        else {
            var answerList: [String] = []
            switch type {
                case .boolean:
                    let answer = correctAnswer
                    answerList = answer == "True" || answer == "False" ? ["True", "False"] : []
                case .multiple:
                    answerList = incorrectAnswers
                    answerList.append(correctAnswer)
                    answerList.shuffle()
            }
            answers = answerList
        }
        
        submittedAnswer = try values.decodeIfPresent(String.self, forKey: .submittedAnswer)?.base64Decoded()
    }
    
}
