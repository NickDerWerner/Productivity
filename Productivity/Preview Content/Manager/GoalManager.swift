//
//  GoalManager.swift
//  Productivity
//
//  Created by Nick Werner on 13.09.25.
//
import SwiftUI

class GoalManager: ObservableObject {
    
    @Published var goalItems: [GoalItem] = []
    private let userDefaults = UserDefaults.standard
    private let goalKey = "goalkey"
    
    init(){
        loadGoals()
    }
    
    func loadGoals(){
        if let data = userDefaults.data(forKey: goalKey),
           let decodedGoals = try? JSONDecoder().decode([GoalItem].self, from: data){
            goalItems = decodedGoals
        }
    }
   
    func saveGoals(){
        if let encodedData = try? JSONEncoder().encode(goalItems){
            userDefaults.set(encodedData, forKey: goalKey)
        }
    }
    func updateGoal(id: UUID, tempTitle: String, tempDescription: String? = nil){
        if let index = goalItems.firstIndex(where: {$0.id == id}){
            goalItems[index].title = tempTitle
            if let desc = tempDescription{
                goalItems[index].description = desc
            }
            saveGoals()
        }
    }
    

    func addGoal(title: String, description: String? = nil) {
        let newGoal = GoalItem(title: title, description: description ?? "", creationDate: Date())
        goalItems.append(newGoal)
        saveGoals()
        
    }
    
    func deleteGoal(_ goalToDelete: GoalItem) {
            goalItems.removeAll { $0.id == goalToDelete.id }
             saveGoals() 
        }
}

