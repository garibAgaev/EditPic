

import Foundation

class MYMailgunAPI {
    
    static let shared = MYMailgunAPI()
    
    private let apiKey = ""
    private let domain = ""
    private let senderEmail = ""
        
    func sendEmail(to recipientEmail: String, subject: String, body: String) async throws -> String {
        let url = URL(string: "https://api.mailgun.net/v3/\(domain)/messages")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let params = [
            "from": senderEmail,
            "to": recipientEmail,
            "subject": subject,
            "text": body
        ]
        
        request.httpBody = params
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        request = try addAuthorizationHeader(to: request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MYMailgunAPIError.serverError
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            return responseString
        } else {
            throw MYMailgunAPIError.responseParseError
        }
    }
    
    func addAuthorizationHeader(to request: URLRequest) throws -> URLRequest {
        if let authData = "api:\(apiKey)".data(using: .utf8) {
            var request = request
            request.setValue("Basic \(authData.base64EncodedString())", forHTTPHeaderField: "Authorization")
            return request
        } else {
            throw MYMailgunAPIError.authorizationFailed
        }
    }
    
    func checkEmailExists(email: String) async throws -> Bool? {
        let url = URL(string: "https://api.mailgun.net/v4/address/validate?address=\(email)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request = try addAuthorizationHeader(to: request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MYMailgunAPIError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw MYMailgunAPIError.jsonParsingError
        }
        
        if let result = json["is_valid"] as? Bool {
            return result
        } else {
            throw MYMailgunAPIError.responseParseError
        }
    }
}
