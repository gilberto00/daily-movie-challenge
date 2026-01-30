//
//  ChallengeService.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import Foundation

class ChallengeService {
    static let shared = ChallengeService()
    
    private let baseURL = "https://us-central1-movie-daily-dev.cloudfunctions.net"
    
    private init() {}
    
    /// Data de hoje no fuso do usuário, formato YYYY-MM-DD (mesmo que o servidor use para o desafio do dia)
    static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
    
    /// Idioma do sistema para o backend (ex.: pt-BR, fr-CA, en)
    static func systemLanguageCode() -> String {
        let id = Locale.current.identifier
        return id.replacingOccurrences(of: "_", with: "-")
    }
    
    func fetchDailyChallenge() async throws -> DailyChallenge {
        let today = Self.todayDateString()
        let lang = Self.systemLanguageCode()
        let urlString = "\(baseURL)/getDailyChallenge?date=\(today)&lang=\(lang)"
        print("🔍 [ChallengeService] Fetching challenge from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ [ChallengeService] Invalid URL: \(urlString)")
            throw ChallengeError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        
        print("📡 [ChallengeService] Starting network request...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [ChallengeService] Invalid response type")
                throw ChallengeError.networkError
            }
            
            print("📊 [ChallengeService] HTTP Status: \(httpResponse.statusCode)")
            print("📊 [ChallengeService] Response Headers: \(httpResponse.allHeaderFields)")
            
            if httpResponse.statusCode != 200 {
                let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                print("❌ [ChallengeService] HTTP Error \(httpResponse.statusCode): \(responseString)")
                
                if httpResponse.statusCode == 404 {
                    throw ChallengeError.cloudFunctionNotFound
                } else if httpResponse.statusCode >= 500 {
                    throw ChallengeError.serverError
                } else {
                    throw ChallengeError.networkError
                }
            }
            
            print("✅ [ChallengeService] Response received, data size: \(data.count) bytes")
            
            do {
                let decoder = JSONDecoder()
                let challenge = try decoder.decode(DailyChallenge.self, from: data)
                print("✅ [ChallengeService] Challenge decoded successfully: \(challenge.title)")
                return challenge
            } catch let decodingError {
                let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                print("❌ [ChallengeService] Decoding error: \(decodingError)")
                print("❌ [ChallengeService] Response body: \(responseString)")
                throw ChallengeError.invalidChallenge
            }
            
        } catch let error as ChallengeError {
            print("❌ [ChallengeService] ChallengeError: \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ [ChallengeService] Unexpected error: \(error.localizedDescription)")
            print("❌ [ChallengeService] Error type: \(type(of: error))")
            throw ChallengeError.networkError
        }
    }
    
    func fetchExtraQuestion(movieId: Int, excludeTypes: [String] = []) async throws -> DailyChallenge {
        let excludeTypesString = excludeTypes.joined(separator: ",")
        let lang = Self.systemLanguageCode()
        let urlString = "\(baseURL)/getExtraQuestion?movieId=\(movieId)&excludeTypes=\(excludeTypesString)&lang=\(lang)"
        
        guard let url = URL(string: urlString) else {
            throw ChallengeError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ChallengeError.networkError
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(DailyChallenge.self, from: data)
    }
    
    func fetchNewMovieChallenge() async throws -> DailyChallenge {
        let lang = Self.systemLanguageCode()
        let urlString = "\(baseURL)/getNewMovieChallenge?lang=\(lang)"
        
        guard let url = URL(string: urlString) else {
            throw ChallengeError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ChallengeError.networkError
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(DailyChallenge.self, from: data)
    }
}

enum ChallengeError: LocalizedError {
    case networkError
    case authenticationError
    case invalidChallenge
    case cloudFunctionNotFound
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error. Please check your connection."
        case .authenticationError:
            return "Authentication failed."
        case .invalidChallenge:
            return "Invalid challenge response from server."
        case .cloudFunctionNotFound:
            return "Cloud Function not found. Please deploy the function first."
        case .serverError:
            return "Server error. Please try again later."
        }
    }
}
