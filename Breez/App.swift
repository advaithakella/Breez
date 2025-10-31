//
//  App.swift
//  Breez
//
//  Created by Advaith Akella on 9/19/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct BreezApp: App {
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Google Sign-In
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            fatalError("GoogleService-Info.plist not found or CLIENT_ID missing")
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)

        // Register custom fonts at launch so SwiftUI and UIKit can resolve them
        FontRegistrar.registerAllCustomFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            AppContainerView()
        }
    }
}
