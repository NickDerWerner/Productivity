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
    @State private var isEditing = false
    @State private var tempTitle = ""
    @State private var tempDescription = ""
    let goal: GoalItem
    @Environment(\.dismiss) var dismiss
    @State private var showingAddSheet = false
    
    // 1. Die neue State-Variable
    @State private var showingDeleteAlert = false
    @State private var parentIDForAdding: UUID? = nil
    
    private var liveGoal: GoalItem {
           // Find the most up-to-date version of the goal from the manager
           // and fall back to the initial goal if it's not found (e.g., if it was deleted)
           goalManager.goalItems.first { $0.id == goal.id } ?? goal
       }
    
    var body: some View {
        
            VStack(spacing: 20) {
                if isEditing{
                    VStack(alignment: .leading) {
                        Text("Title").font(.caption).foregroundColor(.secondary)
                        TextEditor(text: $tempTitle)
                            .frame(height: 30)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        Text("DESCRIPTION").font(.caption).foregroundColor(.secondary)
                        TextEditor(text: $tempDescription)
                            .frame(height: 100)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                    }
                }else{
                    Text(liveGoal.description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ChallengesInGoalsView(challengeManager: challengeManager, goal: goal, isEditing: $isEditing, showingAddSheet: $showingAddSheet, parentIDForAdding: $parentIDForAdding)//missing variable
                Spacer()
                if isEditing{
                    // 2. Der angepasste Button
                    Button("Delete Goal", role: .destructive) {
                        showingDeleteAlert = true
                    }
                    .padding()
                }
            }
            
            .padding()
            
            .navigationTitle(isEditing ? "editing" : liveGoal.title)
            .navigationBarTitleDisplayMode(.inline)
            
            // 3. Die neue Alert-Logik
            .toolbar{
                Button(isEditing ? "Done" : "Edit"){
                    if isEditing {
                        goalManager.updateGoal(id: goal.id, tempTitle: tempTitle, tempDescription: tempDescription)
                    }else{
                        tempTitle = liveGoal.title
                        tempDescription = liveGoal.description
                        //goal aktualisieren
                        
                    }
                    withAnimation {
                        isEditing.toggle()
                    }
                }
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                }
            }
            .alert("Are you sure?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    goalManager.deleteGoal(goal)
                    dismiss() // Diese Funktion schließt die aktuelle Ansicht
                }
            } message: {
                Text("Once deleted, your Goal is gone, bruh")
            }
            
            .sheet(isPresented: $showingAddSheet){
                AddChallengeView(showingAddSheed: $showingAddSheet, challengeManager: challengeManager, goal: goal, parentIDForAdding: $parentIDForAdding)
            }
        
    }
}
