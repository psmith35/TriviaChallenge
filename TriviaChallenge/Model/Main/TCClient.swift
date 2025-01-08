//
//  TCClient.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/8/21.
//

import Foundation
import UIKit

class TCClient {
    
    static var sessionToken = ""
        
    enum MethodTypes : String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum Endpoints {
        static let url = "https://opentdb.com/"
        static let base = "\(url)api.php?"
        static let categoryBase = "\(url)api_category.php"
        static let tokenBase = "\(url)api_token.php?"
        
        case getToken
        case resetToken
        case getCategories
        case getQuestions(Int, TriviaCategory, Difficulty)
        
        var stringValue: String {
            switch self {
            case .getToken:
                return Endpoints.tokenBase + "command=request"
            case .resetToken:
                return Endpoints.tokenBase + "command=reset" + sessionTokenPart
            case .getCategories:
                return Endpoints.categoryBase
            case .getQuestions(let amount, let category, let difficulty):
                return Endpoints.base + "amount=\(amount)" + sessionTokenPart + "&category=\(category.id)&difficulty=\(difficulty.rawValue)&encode=base64"
            }
        }
        
        var sessionTokenPart: String {
            return "&token=\(sessionToken)"
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: - Helper Functions
    class func loadGameData(success: @escaping () -> Void, failure: @escaping (String, String) -> Void) {
        let successClosure = {loadSessionToken(success: success, failure: failure)}
        getTriviaCategories(success: successClosure, failure: failure)
    }
    
    class func loadSessionToken(success: @escaping () -> Void, failure: @escaping (String, String) -> Void) {
        guard let sessionToken = UserDefaults.standard.string(forKey: DefaultsKey.sessionToken.rawValue) else {
            getSessionToken(success: success, failure: failure)
            return
        }
        TCClient.sessionToken = sessionToken
        success()
    }
    
    class func setSessionToken(sessionToken: String) {
        TCClient.sessionToken = sessionToken
        UserDefaults.standard.setValue(sessionToken, forKey: DefaultsKey.sessionToken.rawValue)
    }
    
    // MARK: - API Functions
    class func getSessionToken(success: @escaping () -> Void, failure: @escaping (String, String) -> Void) {
        let getTokenErrorTitle = "Couldn't Start Session"
        _ = taskForGETRequest(url: Endpoints.getToken.url, responseType: TokenResponse.self, completion: {
            (response, error) in
            if let response = response {
                if response.responseCode == 0 {
                    setSessionToken(sessionToken: response.sessionToken)
                    success()
                }
                else {
                    failure(getTokenErrorTitle, response.responseMessage)
                }
            }
            else {
                failure(getTokenErrorTitle, error?.localizedDescription ?? "")
            }
        })
    }
    
    class func resetSessionToken(success: @escaping () -> Void, failure: @escaping (String, String) -> Void) {
        let resetTokenErrorTitle = "Couldn't Restart Session"
        _ = taskForGETRequest(url: Endpoints.resetToken.url, responseType: ResetResponse.self, completion: {
            (response, error) in
            if let response = response {
                if response.responseCode == 0 {
                    setSessionToken(sessionToken: response.sessionToken)
                    success()
                }
                else if response.responseCode == 3 {
                    getSessionToken(success: success, failure: failure)
                }
                else {
                    failure(resetTokenErrorTitle, "There was a problem resetting the session.")
                }
            }
            else {
                failure(resetTokenErrorTitle, error?.localizedDescription ?? "")
            }
        })
    }
    
    class func getTriviaCategories(success: @escaping () -> Void, failure: @escaping (String, String) -> Void) {
        _ = taskForGETRequest(url: Endpoints.getCategories.url, responseType: CategoryList.self, completion: {
            (response, error) in
            if let response = response {
                TCModel.triviaCategories = response.triviaCategories
                success()
            }
            else {
                failure("Couldn't Get Trivia Categories", error?.localizedDescription ?? "")
            }
        })
    }
    
    class func getTriviaQuestions(amount: Int, triviaCategory: TriviaCategory, difficulty: Difficulty, shouldTryAgain: Bool, success: @escaping ([TriviaQuestion]) -> Void, failure: @escaping (String, String) -> Void) {
        _ = taskForGETRequest(url: Endpoints.getQuestions(amount, triviaCategory, difficulty).url, responseType: TriviaQuestions.self, completion: {
            (response, error) in
            if let response = response {
                
                let failureClosure = {failure("Couldn't Get Trivia", "Try Again Later")}
                let tryAgainClosure = {
                    getTriviaQuestions(amount: amount, triviaCategory: triviaCategory, difficulty: difficulty, shouldTryAgain: false, success: success, failure: failure)
                }
                
                switch response.responseCode {
                    case 0:
                        success(response.triviaQuestions)
                    case 1, 2:
                        failureClosure()
                    case 3:
                        if shouldTryAgain {
                            getSessionToken(success: tryAgainClosure, failure: failure)
                        }
                        else {
                            failureClosure()
                        }
                    case 4:
                        if shouldTryAgain {
                            resetSessionToken(success: tryAgainClosure, failure: failure)
                        }
                        else {
                            failureClosure()
                        }
                    default:
                        print("Error found.")
                }
            }
            else {
                failure("Couldn't Get Trivia", error?.localizedDescription ?? "")
            }
        })
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, removeSecurity: Bool = false , responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let request = URLRequest(url: url)
        let task = taskForData(urlRequest: request, removeSecurity: removeSecurity, responseType: responseType, completion: completion)
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, removeSecurity: Bool = false, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        
        request.httpMethod = MethodTypes.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try! encoder.encode(body)
        
        let task = taskForData(urlRequest: request, removeSecurity: removeSecurity, responseType: responseType, completion: completion)
        return task
    }
    
    class func taskForPUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, removeSecurity: Bool = false, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        
        request.httpMethod = MethodTypes.put.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try! encoder.encode(body)
        
        let task = taskForData(urlRequest: request, removeSecurity: removeSecurity, responseType: responseType, completion: completion)
        return task
    }
        
    class func taskForDELETERequest<ResponseType: Decodable>(url: URL, removeSecurity: Bool = false, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        
        request.httpMethod = MethodTypes.delete.rawValue
        var xsrfCookie: HTTPCookie? = nil
        for cookie in HTTPCookieStorage.shared.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = taskForData(urlRequest: request, removeSecurity: removeSecurity, responseType: responseType, completion: completion)
        return task
    }
    
    @discardableResult class func taskForData<ResponseType: Decodable>(urlRequest: URLRequest, removeSecurity: Bool, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            if(removeSecurity) {
                let range : Range = 5..<data.count
                data = data.subdata(in: range)
            }
            do {
                //print(String(data: data, encoding: .utf8)!)
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, error)
                }
            }
            catch {
                do {
                    let errorObject = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorObject)
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
}
