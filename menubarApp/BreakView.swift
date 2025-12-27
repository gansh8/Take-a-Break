//
//  BreakView.swift
//  menubarApp
//
//  Created by Claude on 27/06/25.
//

import SwiftUI

struct BreakView: View {
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var opacity: Double = 0.0
    @State private var showContent = false
    @State private var currentInstructionIndex = 0
    @State private var selectedPreset: BreakPreset
    let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        _selectedPreset = State(initialValue: AppPreferences.shared.selectedBreakPreset)
    }

    var body: some View {
        ZStack {
            Color(NSColor(cgColor: AppPreferences.shared.breakViewBackgroundColor) ?? NSColor.black)
                .ignoresSafeArea()
                .opacity(opacity)

            if showContent {
                VStack(spacing: 50) {
                    if selectedPreset.id == "custom" {
                        // Custom message view
                        VStack(spacing: 20) {
                            Text(AppPreferences.shared.breakMessage)
                                .font(.system(size: 100, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        // Preset activity view
                        VStack(spacing: 30) {
                            // Icon with subtle pulsing animation
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.15))
                                    .frame(width: 140, height: 140)

                                Image(systemName: selectedPreset.iconName)
                                    .font(.system(size: 70))
                                    .foregroundColor(.white)
                            }

                            VStack(spacing: 12) {
                                Text(selectedPreset.title)
                                    .font(.system(size: 60, weight: .semibold))
                                    .foregroundColor(.white)

                                Text(selectedPreset.subtitle)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            // Instructions list
                            if !selectedPreset.instructions.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(Array(selectedPreset.instructions.enumerated()), id: \.offset) { index, instruction in
                                        HStack(alignment: .top, spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(.white.opacity(0.2))
                                                    .frame(width: 32, height: 32)

                                                Text("\(index + 1)")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.white)
                                            }

                                            Text(instruction)
                                                .font(.system(size: 20))
                                                .foregroundColor(.white.opacity(0.95))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .opacity(currentInstructionIndex >= index ? 1.0 : 0.5)
                                    }
                                }
                                .frame(maxWidth: 600)
                                .padding(.horizontal, 40)
                            }
                        }
                    }

                    Button("Skip") {
                        timer?.invalidate()
                        timer = nil
                        onClose()
                    }
                    .font(.system(size: 16))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .buttonStyle(PlainButtonStyle())
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5), value: showContent)
            }
        }
        .onAppear {
            setupFadeInAndAutoClose()
            startInstructionAnimation()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func setupFadeInAndAutoClose() {
        remainingTime = TimeInterval(AppPreferences.shared.breakTimeSeconds)

        if AppPreferences.shared.fadeInBreak {
            // Fade in animation
            withAnimation(.easeInOut(duration: 1.0)) {
                opacity = 1.0
            }

            // Show content after fade in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showContent = true
                }
            }
        } else {
            // Show immediately without animation
            opacity = 1.0
            showContent = true
        }

        // Setup auto-close timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            remainingTime -= 1
            if remainingTime <= 0 {
                timer?.invalidate()
                timer = nil
                onClose()
            }
        }
    }

    private func startInstructionAnimation() {
        let instructions = selectedPreset.instructions
        guard !instructions.isEmpty else { return }

        // Calculate time per instruction
        let totalTime = TimeInterval(AppPreferences.shared.breakTimeSeconds)
        guard totalTime > 0 && instructions.count > 0 else { return }

        let timePerInstruction = totalTime / Double(instructions.count)

        // Highlight each instruction progressively
        for index in 0..<instructions.count {
            let delay = timePerInstruction * Double(index) + 0.5 // Add small delay after content shows
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentInstructionIndex = index
                }
            }
        }
    }
}

// Window controller for fullscreen break window
class BreakWindowController: NSObject, ObservableObject {
    static let shared = BreakWindowController()
    private var window: NSWindow?
    
    func showBreakWindow() {
        closeBreakWindow()
        
        let breakView = BreakView {
            self.closeBreakWindow()
        }
        
        let hostingController = NSHostingController(rootView: breakView)
        
        window = NSWindow(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window?.contentViewController = hostingController
        window?.level = .screenSaver
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window?.isOpaque = false
        window?.backgroundColor = NSColor.clear
        window?.ignoresMouseEvents = false
        window?.makeKeyAndOrderFront(nil)
        
        // Enter fullscreen
        if let screen = NSScreen.main {
            window?.setFrame(screen.frame, display: true)
        }
    }
    
    func closeBreakWindow() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.window?.close()
            self.window = nil
        }
    }
}
