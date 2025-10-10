//
//  ContentView.swift
//  Productivity
//
//  Created by Nick Werner on 10.09.25.
//

import SwiftUI
 
struct ContentView: View {
    @StateObject private var challengeManager = ChallengeManager()
    var body: some View {
        TabView {
            HomeView(challengeManager: challengeManager)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            GoalsView(challengeManager: challengeManager)
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Goals")
                }
            
            ProfileView(challengeManager: challengeManager)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .accentColor(.blue) // Changes selected tab color
    }
}




// In ContentView.swift (oder wo auch immer deine ProfileView ist)

struct ProfileView: View {
    @ObservedObject var challengeManager: ChallengeManager
    @State private var showingResetAlert = false // Zustand für den Alert

    var body: some View {
        NavigationView {
            // Ein Formular eignet sich gut für Einstellungs-Seiten
            Form {
                Section(header: Text("Gefahrenzone")) {
                    Button("Alle App-Daten zurücksetzen", role: .destructive) {
                        showingResetAlert = true // Zeige den Alert an
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Bist du sicher?", isPresented: $showingResetAlert) {
                Button("Alles löschen", role: .destructive) {
                    // Wenn der Benutzer bestätigt, rufe die Reset-Funktion auf
               challengeManager.resetAllData()
                }
                Button("Abbrechen", role: .cancel) { }
            } message: {
                Text("Diese Aktion kann nicht rückgängig gemacht werden. Alle deine Challenges und Ziele werden dauerhaft gelöscht.")
            }
        }
    }
}
#Preview {
    ContentView()
}
