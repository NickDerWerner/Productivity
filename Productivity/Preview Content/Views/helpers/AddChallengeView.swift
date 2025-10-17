//
//  AddChallengeView.swift
//  Productivity
//
//  Created by Nick Werner on 16.10.25.
//

import SwiftUI

struct AddChallengeView: View{
    @Binding var showingAddSheed: Bool
    @ObservedObject var challengeManager: ChallengeManager
    let goal: GoalItem
    @State var title: String = ""
    @State var time: Int?
    
    
    var body: some View{
        NavigationView {
            Form {
                TextField("Enter Name", text: $title)
                TextField("Enter time in Minutes", value: $time, format: .number)
            }
            
            .navigationTitle("New Challange")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingAddSheed = false
                },
                trailing: Button("Add") {
                    if !title.isEmpty{
                        if let minutes = time, minutes > 0 {
                            //add with timer
            
                            challengeManager.addChallengeWithTimer(title, durationInMinutes: time ?? 0, associatedGoal: goal)
                        }else{
                            // add without timer
                            challengeManager.addChallenge(title, associatedGoal: goal)
                        }
                        showingAddSheed = false

                    }
                }
            )
        }
    }
}


