//
//  GoalDetailView.swift
//  Productivity
//
//  Created by Nick Werner on 13.09.25.
//
import SwiftUI

struct GoalDetailView: View {
    @ObservedObject var goalManager: GoalManager
    @ObservedObject var challengeManager: ChallengeManager
    let goal: GoalItem
    @Environment(\.dismiss) var dismiss
    
    // 1. Die neue State-Variable
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text(goal.description)
            
            ChallengesInGoalsView(challengeManager: challengeManager, goal: goal)
            Spacer()
            
            // 2. Der angepasste Button
            Button("Delete Goal", role: .destructive) {
                showingDeleteAlert = true
            }
            .padding()
        }
        .padding()
        .navigationTitle(goal.title)
        // 3. Die neue Alert-Logik
        .alert("Are you sure?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                goalManager.deleteGoal(goal)
                dismiss() // Diese Funktion schließt die aktuelle Ansicht
            }
        } message: {
            Text("Once deleted, your Challenge is gone, bruh")
        }
    }
}
