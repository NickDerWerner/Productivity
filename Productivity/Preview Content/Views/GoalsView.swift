//
//  GoalsView.swift
//  Productivity
//
//  Created by Nick Werner on 13.09.25.
//
import SwiftUI




struct GoalsView: View {
    @StateObject private var goalManager = GoalManager()
    @ObservedObject var challengeManager: ChallengeManager
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
           
            List {
                ForEach(goalManager.goalItems){ goal in
                    NavigationLink(destination: GoalDetailView(goalManager: goalManager, challengeManager: challengeManager, goal: goal)) {
                                          Text(goal.title)
                                      }
                    
                }
            
                }
            .navigationTitle("My Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.glassProminent)
                }
            }

                        .sheet(isPresented: $showingAddSheet) {
                            AddGoalView(goalManager: goalManager)
                        }
                        
        }
    }
}


