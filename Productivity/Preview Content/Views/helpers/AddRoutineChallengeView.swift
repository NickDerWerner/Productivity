//
//  AddRoutineChallengeView.swift
//  Productivity
//
//  Created by Nick Werner on 25.10.25.
//

//
//  AddChallengeView.swift
//  Productivity
//
//  Created by Nick Werner on 16.10.25.
//

import SwiftUI

struct AddRoutineChallengeView: View{
    @Binding var showingAddChallengeView: Bool
    @ObservedObject var challengeManager: ChallengeManager
    @State var title: String = ""
    @State var time: Int?
    @State var isAggregator: Bool = false //legacy
    @Binding var parentIDForAdding: UUID?
    @State private var activeDays: Set<DayOfWeek> = Set(DayOfWeek.allCases)
    
    var body: some View{
        NavigationView {
            Form {
                TextField("Enter Name", text: $title)
                
                TextField("Enter time in Minutes", value: $time, format: .number)
                
                Section(header: Text("Active Days")) {
                                    DaySelectorView(activeDays: $activeDays)
                                }

                
            }
            
            .navigationTitle("New Challange")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingAddChallengeView = false
                },
                trailing: Button("Add") {
                    if !title.isEmpty && !activeDays.isEmpty{
                        if let minutes = time, minutes > 0 {
                            //add with timer
            
                            challengeManager.addChallengeWithTimer(title, associatedGoal: nil , isAggregator: isAggregator, associatedAggregatorID: parentIDForAdding, durationInMinutes: time ?? 0, activeDays: activeDays)
                        }else{
                            // add without timer
                            challengeManager.addChallenge(title, associatedGoal: nil, isAggregator: isAggregator, associatedAggregatorID: parentIDForAdding, activeDays: activeDays)
                        }
                        showingAddChallengeView = false
                        parentIDForAdding = nil
                    }
                }
            )
        }
    }
}


