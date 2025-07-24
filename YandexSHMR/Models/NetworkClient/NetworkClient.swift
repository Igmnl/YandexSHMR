//
//  NetworkClient.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 18.07.2025.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

final class NetworkClient {
    static let shared = NetworkClient()
    private let baseUrl: String = "https://shmr-finance.ru/api/v1"
    private let token: String = "YOUR_TOKEN" //Bundle.main.object(forInfoDictionaryKey: "API_TOKEN") as! String
    
    func requets<T:Decodable>(method: HTTPMethod, path: String, body: Encodable? = nil) async throws ->  T {
        guard let url = URL(string: baseUrl + path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .formatted(TransactionResponse.dateFormatter)
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        
//        For debug
//        if let responseString = String(data: data, encoding: .utf8) {
//            print("Raw response: \(responseString)")
//        }
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 204:
                if T.self == DecodableStub.self {
                    return DecodableStub() as! T
                }
            case 200..<300:
                break
            case 400:
                throw NetworkError.invalidDataOrIdentifier
            case 401:
                throw NetworkError.unauthorized
            case 404:
                throw NetworkError.notFound
            case 500..<600:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NSError(domain: "", code: httpResponse.statusCode)
            }
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                if let date = TransactionResponse.dateFormatter.date(from: dateString) {
                    return date
                }
                
                // Fallback форматы при необходимости
                let formats = [
                    "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ",
                    "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                    "yyyy-MM-dd"
                ]
                
                for format in formats {
                    let formatter = DateFormatter()
                    formatter.dateFormat = format
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateString)"
                )
            }
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
