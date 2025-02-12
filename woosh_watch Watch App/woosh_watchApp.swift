//
//  woosh_watchApp.swift
//  woosh_watch Watch App
//
//  Created by Abdelmonem Shaker on 11/02/2025.
//

import SwiftUI

@main
struct woosh_watch_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor private var delegate: ExtensionDelegate
        @StateObject private var movementService = MovementService()
        
        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(movementService)
            }
        }
}
