//
//  ChallengeManager.swift
//  Productivity
//
//  Created by Nick Werner on 13.09.25.
//

import SwiftUI


// STEP 2: Create the Todo Manager
// This handles all the data operations (save, load, add, delete)
class ChallengeManager: ObservableObject {
    // @Published means SwiftUI will update the view when this changes
    @Published var challengeItems: [ChallengeItem] = []
    
    // UserDefaults is like a simple database on the device
    private let userDefaults = UserDefaults.standard
    private let challengeKey = "SavedChallenge"  // Key name for storing todos
    
    // This runs when TodoManager is created
    init() {
        loadChallenge()  // Load existing todos when app starts
        checkForDailyReset()
        
        //check for dayChange
        NotificationCenter.default.addObserver(self, selector: #selector(dayDidChange), name: .NSCalendarDayChanged, object: nil)
    }
    
    deinit {
        // Stop listening to notifications to prevent memory issues
        NotificationCenter.default.removeObserver(self)
    }

    @objc func dayDidChange(){
        DispatchQueue.main.async {
                print("Midnight trigger: Day has changed! (on main thread)")
                
                // You need to add "self." because this is inside a closure
                self.checkForDailyReset()
            }
    }
    
    // STEP 3: Load todos from storage
    func loadChallenge() {
        // Try to get saved data from UserDefaults
        if let data = userDefaults.data(forKey: challengeKey),
           let decodedchallenge = try? JSONDecoder().decode([ChallengeItem].self, from: data) {
            challengeItems = decodedchallenge  // Use saved todos
        }
        // If no saved todos exist, todoItems stays empty (which is fine)
    }
    
    // STEP 4: Save todos to storage
    func saveChallenge() {
        // Convert todos to JSON data and save
        if let encodedData = try? JSONEncoder().encode(challengeItems) {
            userDefaults.set(encodedData, forKey: challengeKey)
        }
    }
    
    // STEP 5: Add a new todo
    func addChallenge(_ title: String) {
        let newChallenge = ChallengeItem(title: title)
        challengeItems.append(newChallenge)  // Add to list
        saveChallenge()  // Save immediately
    }
    
    // STEP 6: Toggle todo completion
    func toggleChallenge(_ challenge: ChallengeItem) {
        // Find the todo in the list and flip its completed status
        if let index = challengeItems.firstIndex(where: { $0.id == challenge.id }) {
            let wascompleted = challengeItems[index].isCompleted
            
            challengeItems[index].isCompleted.toggle()
            
            if challengeItems[index].isCompleted && !wascompleted {
                challengeItems[index].streak += 1
            } else if (challengeItems[index].isCompleted == false && wascompleted){
                challengeItems[index].streak -= 1
            }
            saveChallenge()  // Save immediately
        }
    }
    
    func resetDailyChallenge(){
        print("running daily reset")
        var hasChanges = false
        for index in challengeItems.indices{
            if challengeItems[index].isDailyChallenge, challengeItems[index].isCompleted{
                challengeItems[index].isCompleted = false
                hasChanges = true
            }
            
        }
        if hasChanges{
            saveChallenge()
        }
    }
    
    func checkForDailyReset(){
        let lastResetKey = "lastResetKey"
        let lastResetDate = userDefaults.object(forKey: lastResetKey) as? Date
        if lastResetDate == nil || !Calendar.current.isDateInToday(lastResetDate!){
            resetDailyChallenge()
            userDefaults.set(Date(), forKey: lastResetKey)
            print("Daily reset complete. New reset date saved")
        }else{
            print("No reset of daily challenges done")
        }
    
    }
    
    
    // STEP 7: Delete todos
    func deleteChallenge(at offsets: IndexSet) {
        challengeItems.remove(atOffsets: offsets)
        saveChallenge()  // Save immediately
    }
    
    
    //Timer relatet functions
    
    // In the ChallengeManager class

    func startTimer(for challenge: ChallengeItem) {
        if let index = challengeItems.firstIndex(where: { $0.id == challenge.id }) {
            // Only start if it's not already running
            guard !challengeItems[index].isTimerRunning else { return }
            
            challengeItems[index].isTimerRunning = true
            // Calculate the exact date it should end
            challengeItems[index].timerEndDate = Date().addingTimeInterval(TimeInterval(challengeItems[index].timeRemaining))
            saveChallenge()
        }
    }

    func pauseTimer(for challenge: ChallengeItem) {
        if let index = challengeItems.firstIndex(where: { $0.id == challenge.id }) {
            // Only pause if it's currently running
            guard challengeItems[index].isTimerRunning else { return }
            
            // Before pausing, update timeRemaining to the latest value
            if let endDate = challengeItems[index].timerEndDate {
                let remaining = Int(endDate.timeIntervalSince(Date()))
                challengeItems[index].timeRemaining = max(0, remaining)
            }
            
            challengeItems[index].isTimerRunning = false
            challengeItems[index].timerEndDate = nil // Clear the end date
            saveChallenge()
        }
    }

    // This function now syncs the state from the end date
    func updateAndCheckTimers() {
        var needsSave = false
        for index in challengeItems.indices {
            // Check only running timers that have a valid end date
            if challengeItems[index].isTimerRunning, let endDate = challengeItems[index].timerEndDate {
                
                // Calculate remaining time based on the fixed end date
                let remaining = Int(endDate.timeIntervalSince(Date()))
                challengeItems[index].timeRemaining = max(0, remaining)

                // If the end date has passed, complete the challenge
                if remaining <= 0 {
                    challengeItems[index].isTimerRunning = false
                    challengeItems[index].timerEndDate = nil
                    if !challengeItems[index].isCompleted {
                        challengeItems[index].isCompleted = true
                        challengeItems[index].streak += 1
                    }
                }
                needsSave = true
            }
        }
        
        if needsSave {
            saveChallenge()
        }
    }
    
    func addChallengeWithTimer(_ title: String, durationInMinutes: Int) {
        // Erstelle ein neues ChallengeItem
        let newChallenge = ChallengeItem(
            title: title,
            hasTimer: true,
            timerDuration: durationInMinutes * 60, // Dauer in Sekunden umrechnen
            timeRemaining: durationInMinutes * 60 // Verbleibende Zeit auf die Gesamtdauer setzen
        )
        
        // Füge die Challenge zur Liste hinzu
        challengeItems.append(newChallenge)
        
        // Speichere die Änderungen sofort
        saveChallenge()
    }

    
    
}
