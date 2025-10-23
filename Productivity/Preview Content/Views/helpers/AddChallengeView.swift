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
    @State var isAggregator: Bool = false
    @Binding var parentIDForAdding: UUID?
    
    var body: some View{
        NavigationView {
            Form {
                TextField("Enter Name", text: $title)
                
                if isAggregator == false {
                    TextField("Enter time in Minutes", value: $time, format: .number)
                }
                
                if parentIDForAdding == nil && time == nil{
                    Toggle("Is Aggregation Challenge", isOn: $isAggregator)
                }
                
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
            
                            challengeManager.addChallengeWithTimer(title, associatedGoal: goal, isAggregator: isAggregator, associatedAggregatorID: parentIDForAdding, durationInMinutes: time ?? 0)
                        }else{
                            // add without timer
                            challengeManager.addChallenge(title, associatedGoal: goal, isAggregator: isAggregator, associatedAggregatorID: parentIDForAdding)
                        }
                        showingAddSheed = false
                        parentIDForAdding = nil
                    }
                }
            )
        }
    }
}


