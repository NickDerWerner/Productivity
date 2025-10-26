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
    func addChallenge(_ title: String, associatedGoal: GoalItem?, isAggregator: Bool, associatedAggregatorID: UUID? = nil, isRoutine: Bool? = nil,  activeDays: Set<DayOfWeek> = []) -> ChallengeItem {
        
        let isSubChallenge: Bool = associatedAggregatorID != nil
        let newChallenge =
        ChallengeItem(
            title: title,
                      associatedGoal: associatedGoal,
                      isAggregator: isAggregator,
                      isSubChallange: isSubChallenge,
                      associatedAggregatorID: associatedAggregatorID,
                      isRoutine: isRoutine ?? false,
                      activeDays: activeDays,
                     // hasTimer: false
        )
        challengeItems.append(newChallenge)  // Add to list
        saveChallenge()  // Save immediately
        return newChallenge
    }
    
    func addChallengeWithTimer(_ title: String, associatedGoal: GoalItem?, isAggregator: Bool, associatedAggregatorID: UUID? = nil, durationInMinutes: Int, activeDays: Set<DayOfWeek> = []) {
   
        let isSubChallenge: Bool = associatedAggregatorID != nil
        let newChallenge = ChallengeItem(
            title: title,
            associatedGoal: associatedGoal,
            isAggregator: isAggregator,
            isSubChallange: isSubChallenge,
            associatedAggregatorID: associatedAggregatorID,
            hasTimer: true,
            timerDuration: durationInMinutes * 60, // Dauer in Sekunden umrechnen
            timeRemaining: durationInMinutes * 60, // Verbleibende Zeit auf die Gesamtdauer setzen
            activeDays: activeDays
        )
        
        // Füge die Challenge zur Liste hinzu
        challengeItems.append(newChallenge)
        
        // Speichere die Änderungen sofort
        saveChallenge()
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
            
            if challengeItems[index].isSubChallange{
                if let parentID = challengeItems[index].associatedAggregatorID{
                    
                    let allSubChallenges = challengeItems.filter{$0.associatedAggregatorID == parentID}
                    
                    if allSubChallenges.allSatisfy(\.isCompleted){
                        if let parentIndex = challengeItems.firstIndex(where: {$0.id == parentID}) {
                        if challengeItems[parentIndex].isCompleted == false{
                            challengeItems[parentIndex].isCompleted = true
                            challengeItems[parentIndex].streak += 1
                            }
                           
                        }
                    }
            }}
            saveChallenge()  // Save immediately
        }
    }
    func createNewRoutineAndMoveChallenge(challengeItem: ChallengeItem, routineName: String){
        let aggregatorInstance = addChallenge(routineName,associatedGoal: nil, isAggregator: true, isRoutine: true)
        addChallengeToRoutine(challengeItem: challengeItem, aggregatorInstance:  aggregatorInstance)
        //   saveChallenge() already safes it in addChallengeToRoutine
    }
    
    func addChallengeToRoutine(challengeItem: ChallengeItem, aggregatorInstance: ChallengeItem){
        if let challengeIndex = challengeItems.firstIndex(where: {challengeItem.id == $0.id}){
            challengeItems[challengeIndex].associatedAggregatorID = aggregatorInstance.id
            challengeItems[challengeIndex].isSubChallange = true
            saveChallenge()
           
        }
    }
    func removeChallengeFromAggregator(challengeItem: ChallengeItem){
        if let challengeIndex = challengeItems.firstIndex(where: {challengeItem.id == $0.id}){
            challengeItems[challengeIndex].associatedAggregatorID = nil
            challengeItems[challengeIndex].isSubChallange = false
            saveChallenge()
        }
    }
    
    
    func resetDailyChallenge(){
        print("running daily reset")
        var hasChanges = false
        
        
        for index in challengeItems.indices{
            if challengeItems[index].isDailyChallenge{
                if challengeItems[index].isCompleted{
                    challengeItems[index].isCompleted = false
                    if challengeItems[index].hasTimer{
                        challengeItems[index].timeRemaining = challengeItems[index].timerDuration
                        challengeItems[index].timerEndDate = nil
                        challengeItems[index].isTimerRunning = false
                    }
                }else{
                    
                    let wasActiveYesterday: Bool = {
                        // If the activeDays set is empty, it's active every day (including yesterday).
                        if challengeItems[index].activeDays.isEmpty {
                            return true
                        }
                        
                        // 1. Get yesterday's date
                        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
                            return false }
                        // 2. Get the weekday Int for *yesterday* (Sunday=1, Monday=2...)
                        let yesterdayWeekdayInt = Calendar.current.component(.weekday, from: yesterday)
                        // 3. Try to convert that Int into our DayOfWeek enum
                        guard let yesterdayDay = DayOfWeek(rawValue: yesterdayWeekdayInt) else {
                            return false // Should never happen if your enum is 1-7
                        }
                        // 4. Check if the challenge's set contains yesterday's day
                        return challengeItems[index].activeDays.contains(yesterdayDay)
                    }() // The () at the end immediately runs this closure
                    
                    if wasActiveYesterday{
                        challengeItems[index].streak = 0
                    }
                    
                }
                hasChanges = true
            }
            
        }
        if hasChanges{
            saveChallenge()
        }
    }
    
    func moveChallenge(from source: IndexSet, to destination: Int) {
        
        // 1. Get the list of root items that the ForEach is *actually* displaying
        let rootItems = challengeItems.filter { $0.isSubChallange == false }
        
        // 2. Create a mutable copy of just those root items
        var reorderedRootItems = rootItems
        
        // 3. Perform the move on this temporary, root-only array
        reorderedRootItems.move(fromOffsets: source, toOffset: destination)
        
        // 4. Get all the sub-challenges, grouped by their parent's ID
        let subChallengeGroups = Dictionary(
            grouping: challengeItems.filter { $0.isSubChallange == true },
            by: { $0.associatedAggregatorID! }
        )
        
        // 5. Create a new, empty array to build our new list
        var newChallengeItems: [ChallengeItem] = []
        
        // 6. Walk through the newly ordered root items
        for rootItem in reorderedRootItems {
            // Add the root item itself
            newChallengeItems.append(rootItem)
            
            // If this root item is an aggregator, find and add its children
            if rootItem.isAggregator, let subChallenges = subChallengeGroups[rootItem.id] {
                newChallengeItems.append(contentsOf: subChallenges)
            }
        }
        
        // 7. Replace the old, full array with our new, correctly-ordered array
        challengeItems = newChallengeItems
        
        // 8. Save the new order
        saveChallenge()
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
    
    func editChallenge(UUID: UUID, newTitle: String) {
        if let index = challengeItems.firstIndex(where: {$0.id == UUID}){
            challengeItems[index].title = newTitle
            saveChallenge()
        }
    }
    
    
    func deleteChallenge(_ challengeToDelete: ChallengeItem) {
        if challengeToDelete.isAggregator{
            for index in challengeItems.indices{
                if challengeItems[index].associatedAggregatorID == challengeToDelete.id{
                    
                        challengeItems[index].associatedAggregatorID = nil
                    challengeItems[index].isSubChallange = false
                    }
                }
            }
            challengeItems.removeAll { $0.id == challengeToDelete.id }
            saveChallenge() // Speichere die Änderung
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
                       toggleChallenge(challengeItems[index])
                    }
                }
                needsSave = true
            }
        }
        
        if needsSave {
            saveChallenge()
        }
    }
    
    

    func resetAllData() {
            // 1. Lösche alle Challenges aus dem Speicher der App
            challengeItems.removeAll()
            
            // 2. Lösche die gespeicherten Daten aus UserDefaults
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
            }
            
            print("Alle App-Daten wurden zurückgesetzt.")
        }

    
}
