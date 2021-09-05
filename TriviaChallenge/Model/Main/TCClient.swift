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
        static let urlBase = "https://opentdb.com/"
        static let base = urlBase + "api.php?"
        static let sessionTokenPart = "&token=\(sessionToken)"
        
        case getToken
        case resetToken
        case getCategories
        
        var stringValue: String {
            switch self {
            case .getToken :
                return Endpoints.base + "command=request"
            case .resetToken :
                return Endpoints.base + "command=reset" + Endpoints.sessionTokenPart
            case .getCategories :
                return Endpoints.urlBase + "api_category.php"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getSessionToken(success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        _ = taskForGETRequest(url: Endpoints.getToken.url, responseType: TokenResponse.self, completion: {
            (response, error) in
            if let response = response, response.responseCode == 0 {
                TCClient.sessionToken = response.sessionToken
                success()
            }
            else {
                failure(error)
            }
        })
    }
    
    class func resetSessionToken(success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        _ = taskForGETRequest(url: Endpoints.resetToken.url, responseType: ResetResponse.self, completion: {
            (response, error) in
            if let response = response {
                if response.responseCode == 0 {
                    TCClient.sessionToken = response.sessionToken
                    success()
                }
                else if response.responseCode == 3 {
                    TCClient.getSessionToken(success: success, failure: failure)
                }
            }
            else {
                failure(error)
            }
        })
    }
    
    class func getTriviaCategories(success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        _ = taskForGETRequest(url: Endpoints.getCategories.url, responseType: CategoryList.self, completion: {
            (response, error) in
            if let response = response {
                TCMModel.triviaCategories = response.triviaCategories
                success()
            }
            else {
                failure(error)
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
