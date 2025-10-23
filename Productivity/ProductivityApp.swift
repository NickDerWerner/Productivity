//
//  ProductivityApp.swift
//  Productivity
//
//  Created by Nick Werner on 10.09.25.
//

import SwiftUI

@main
struct ProductivityApp: App {
    @AppStorage("appearance") private var appearance: Appearance = .system
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(appearance.colorScheme) 
        }
    }
}
