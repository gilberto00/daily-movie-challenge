//
//  DateExtensions.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-20.
//

import Foundation

extension Date {
    /// Formata a data de forma relativa (ex: "há 5 minutos", "ontem", "há 2 dias")
    func relativeString() -> String {
        let now = Date()
        let calendar = Calendar.current
        
        // Se for hoje, mostrar hora
        if calendar.isDateInToday(self) {
            let minutes = Int(now.timeIntervalSince(self) / 60)
            
            if minutes < 1 {
                return "agora"
            } else if minutes < 60 {
                return "há \(minutes) minuto\(minutes > 1 ? "s" : "")"
            } else {
                let hours = minutes / 60
                return "há \(hours) hora\(hours > 1 ? "s" : "")"
            }
        }
        
        // Se for ontem
        if calendar.isDateInYesterday(self) {
            return "ontem"
        }
        
        // Se for na mesma semana
        let days = calendar.dateComponents([.day], from: self, to: now).day ?? 0
        if days < 7 {
            return "há \(days) dia\(days > 1 ? "s" : "")"
        }
        
        // Se for na mesma semana do ano anterior
        let weeks = days / 7
        if weeks < 4 {
            return "há \(weeks) semana\(weeks > 1 ? "s" : "")"
        }
        
        // Mais de um mês, mostrar data completa
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
