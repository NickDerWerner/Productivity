//
//  SettingsView.swift
//  Productivity
//
//  Created by Nick Werner on 18.10.25.
//
import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("useHaptics") private var useHaptics = true
    @AppStorage("appearance") private var appearance: Appearance = .system

    var body: some View {
        VStack {
            Section("Appearance") {
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag(Appearance.system)
                    Text("Light").tag(Appearance.light)
                    Text("Dark").tag(Appearance.dark)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)   // extra space inside the row
            }
            .padding(.vertical, 8)   // extra space inside the row
            Section("General") {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                Toggle("Haptics", isOn: $useHaptics)
            }
        }
        .navigationTitle("Settings")
        .padding(.vertical, 8)   // extra space inside the row

    }
}


enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    // nil = follow system
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
