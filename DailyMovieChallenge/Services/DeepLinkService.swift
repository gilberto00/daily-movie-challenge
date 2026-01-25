//
//  DeepLinkService.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-24.
//

import Foundation
import SwiftUI
import Combine

/// Enum para representar diferentes tipos de deep links
enum DeepLinkDestination: Hashable {
    case home
    case trivia
    case result
    case leaderboard
    case settings
    case challenge(movieId: Int?)
    
    /// Cria um DeepLinkDestination a partir de uma URL
    static func from(url: URL) -> DeepLinkDestination? {
        guard url.scheme == "dailymoviechallenge" || url.scheme == "https" else {
            return nil
        }
        
        // Suporta tanto URL schemes customizados quanto Universal Links
        let path = url.pathComponents
        
        // URL scheme: dailymoviechallenge://home
        // Universal Link: https://dailymoviechallenge.app/home
        if path.isEmpty || path.count == 1 {
            // Apenas o host/scheme, assume home
            if url.host == "home" || url.lastPathComponent == "home" || path.isEmpty {
                return .home
            }
        }
        
        // Verifica o primeiro componente do path
        if let firstComponent = path.first, firstComponent != "/" {
            switch firstComponent.lowercased() {
            case "home":
                return .home
            case "trivia", "challenge":
                // Extrai movieId se disponível: dailymoviechallenge://trivia?movieId=123
                if let movieIdString = url.queryParameters?["movieId"],
                   let movieId = Int(movieIdString) {
                    return .challenge(movieId: movieId)
                }
                return .trivia
            case "result":
                return .result
            case "leaderboard", "ranking":
                return .leaderboard
            case "settings", "notifications":
                return .settings
            default:
                break
            }
        }
        
        // Fallback: verifica query parameters
        if let destination = url.queryParameters?["destination"] {
            switch destination.lowercased() {
            case "home":
                return .home
            case "trivia", "challenge":
                if let movieIdString = url.queryParameters?["movieId"],
                   let movieId = Int(movieIdString) {
                    return .challenge(movieId: movieId)
                }
                return .trivia
            case "result":
                return .result
            case "leaderboard":
                return .leaderboard
            case "settings":
                return .settings
            default:
                break
            }
        }
        
        return .home // Default
    }
}

/// Serviço para gerenciar deep linking no app
class DeepLinkService: ObservableObject {
    static let shared = DeepLinkService()
    
    @Published var pendingDestination: DeepLinkDestination?
    
    private init() {}
    
    /// Processa uma URL e retorna o destino correspondente
    func handleURL(_ url: URL) -> DeepLinkDestination? {
        guard let destination = DeepLinkDestination.from(url: url) else {
            print("⚠️ [DeepLinkService] Could not parse URL: \(url)")
            return nil
        }
        
        print("✅ [DeepLinkService] Parsed deep link: \(destination)")
        return destination
    }
    
    /// Processa uma notificação push e extrai o destino do payload
    func handleNotification(userInfo: [AnyHashable: Any]) -> DeepLinkDestination? {
        // Extrai dados do payload da notificação
        guard let aps = userInfo["aps"] as? [String: Any],
              let _ = aps["alert"] as? [String: Any] else {
            // Tenta extrair diretamente do userInfo
            if let destinationString = userInfo["destination"] as? String {
                switch destinationString.lowercased() {
                case "home":
                    return .home
                case "trivia", "challenge":
                    if let movieId = userInfo["movieId"] as? Int {
                        return .challenge(movieId: movieId)
                    }
                    return .trivia
                case "leaderboard":
                    return .leaderboard
                case "settings":
                    return .settings
                default:
                    break
                }
            }
            return .home // Default para notificações
        }
        
        // Se não houver destino específico, retorna home
        if let destinationString = userInfo["destination"] as? String {
            switch destinationString.lowercased() {
            case "home":
                return .home
            case "trivia", "challenge":
                if let movieId = userInfo["movieId"] as? Int {
                    return .challenge(movieId: movieId)
                }
                return .trivia
            case "leaderboard":
                return .leaderboard
            case "settings":
                return .settings
            default:
                break
            }
        }
        
        return .home
    }
}

// MARK: - URL Extension para query parameters
extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var params: [String: String] = [:]
        for item in queryItems {
            if let value = item.value {
                params[item.name] = value
            }
        }
        return params.isEmpty ? nil : params
    }
}
