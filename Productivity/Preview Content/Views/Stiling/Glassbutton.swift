//
//  Glassbutton.swift
//  Productivity
//
//  Created by Nick Werner on 18.10.25.
//

import SwiftUI

/// A reusable Liquid-Glass button for iOS 26+ with a graceful fallback.
struct GlassButton: View {
    var title: String
    var systemImage: String? = nil
    var prominent: Bool = true        // primary vs subtle
    var tint: Color = .blue
    var action: () -> Void

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        Button(action: action) {
            if let systemImage {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .labelStyle(.titleAndIcon)
            } else {
                Text(title).font(.headline)
            }
        }
        .padding(.horizontal) // spacing inside the label
        .tint(tint)

        // iOS 26 Liquid Glass styles + graceful fallback
        #if compiler(>=6.0)
        .modifier(GlassStyle(prominent: prominent, reduceTransparency: reduceTransparency))
        #else
        // very old toolchains: safe, readable fallback
        .buttonStyle(.borderedProminent)
        #endif
        .accessibilityLabel(Text(title))
    }
}

private struct GlassStyle: ViewModifier {
    let prominent: Bool
    let reduceTransparency: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            if prominent{
                content
                  
                    .buttonStyle( .glassProminent )  // Liquid Glass
                // Respect users who reduce transparency: swap to an opaque style.
                    .opacity(reduceTransparency ? 1 : 1)
                    .background(reduceTransparency ? Color(.systemBackground) : nil)
                    .clipShape(Capsule())
            } else {
                content
                
                    .buttonStyle(.glass)  // Liquid Glass
                // Respect users who reduce transparency: swap to an opaque style.
                    .opacity(reduceTransparency ? 1 : 1)
                    .background(reduceTransparency ? Color(.systemBackground) : nil)
                    .clipShape(Capsule())
            }
            
        } else {
            // Fallback for iOS < 26: bordered + a hint of material
            content
                .buttonStyle(.borderedProminent)
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}


struct PlusButton: View {
    var prominent: Bool = true
    var action: () -> Void

    // If you didn’t put reduceTransparency inside the modifier:
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "plus")
                .font(.title2)                // icon size
                                  // hit target
                .contentShape(Circle())
                .accessibilityLabel("Add")
        }
        .modifier(GlassStyle(
            prominent: prominent,
            reduceTransparency: reduceTransparency
        ))
        .controlSize(.mini)
    }
}
