//
//  AddToRoutineView.swift
//  Productivity
//
//  Created by Nick Werner on 23.10.25.
//

import SwiftUI

struct AddToRoutineView: View {
    @ObservedObject var challengeManager: ChallengeManager
    @Binding var isPresented: Bool
    @Binding var challengeToAdd: ChallengeItem?
    @State private var newRoutineName: String = ""
    
    var body: some View{
        
        NavigationView {
            List {
                // 1. Section to create a new routine
                Section(header: Text("New Routine")) {
                    HStack {
                        TextField("e.g. Morning Workout", text: $newRoutineName)
                        Button("Create") {
                            // This creates the new routine AND adds the challenge to it
                            newRoutineAndAddChallenge()
                        }
                        .disabled(newRoutineName.isEmpty)
                    }
                }
                Section(header: Text("Existing Routines")){
                    ForEach(challengeManager.challengeItems.filter{ $0.isRoutine == true}){ routine in
                        Button(action: {
                            addToRoutine(aggregatorInstance: routine)
                        }) {
                            Text(routine.title)
                        }
                        
                    }
                }
                
            }
        }
        
    }
        
        func addToRoutine(aggregatorInstance: ChallengeItem){
            guard let challenge = challengeToAdd else { return }
            challengeManager.addChallengeToRoutine(challengeItem: challenge, aggregatorInstance: aggregatorInstance)
            isPresented = false
        }
        
        func newRoutineAndAddChallenge(){
            guard let challenge = challengeToAdd, !newRoutineName.isEmpty else { return }
            
            challengeManager.createNewRoutineAndMoveChallenge(challengeItem: challenge, routineName: newRoutineName)
            
            isPresented = false

        }
        
    
    
    
}

