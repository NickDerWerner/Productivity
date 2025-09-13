//
//  ContentView.swift
//  Productivity
//
//  Created by Nick Werner on 10.09.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            GoalsView()
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Goals")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .accentColor(.blue) // Changes selected tab color
    }
}




struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("Profile Content")
                .navigationTitle("Profile")
        }
    }
}

#Preview {
    ContentView()
}
