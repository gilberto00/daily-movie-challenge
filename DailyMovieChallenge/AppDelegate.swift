//
//  AppDelegate.swift
//  DailyMovieChallenge
//
//  Necessário para passar o token APNs ao Firebase Messaging (push notifications).
//  Em apps SwiftUI sem AppDelegate, o sistema chama este método e precisamos repassar ao FCM.
//

import UIKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    /// O sistema chama este método quando recebe o token APNs. Sem repassar ao Firebase, o FCM token não é gerado.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("✅ [AppDelegate] APNs device token received: \(tokenString.prefix(20))...")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ [AppDelegate] Failed to register for remote notifications: \(error)")
    }
}
