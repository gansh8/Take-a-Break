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
        // Get preset based on user preference (auto-rotate or fixed)
        _selectedPreset = State(initialValue: AppPreferences.shared.selectedBreakPreset)
    }
    
    var body: some View {
        ZStack {
            // Use preset background color, or preferences color for custom
            (selectedPreset.id == "custom"
                ? Color(NSColor(cgColor: AppPreferences.shared.breakViewBackgroundColor) ?? NSColor.black)
                : selectedPreset.backgroundColor)
                .ignoresSafeArea()
                .opacity(opacity)

            if showContent {
                VStack(spacing: 50) {
                    if selectedPreset.id == "custom" {
                        // Custom message view
                        Text(AppPreferences.shared.breakMessage)
                            .font(.system(size: 100, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    } else {
                        // Preset activity view - simplified
                        presetActivityContent
                    }

                    Button(action: {
                        timer?.invalidate()
                        timer = nil
                        onClose()
                    }) {
                        HStack(spacing: 8) {
                            Text("Skip")
                            Text("(ESC)")
                                .font(.system(size: 12))
                                .opacity(0.7)
                        }
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

    private var presetActivityContent: some View {
        VStack(spacing: 30) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 140, height: 140)

                Image(systemName: selectedPreset.iconName)
                    .font(.system(size: 70))
                    .foregroundColor(.white)
            }

            // Title
            Text(selectedPreset.title)
                .font(.system(size: 60, weight: .semibold))
                .foregroundColor(.white)

            // Subtitle
            Text(selectedPreset.subtitle)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.9))

            // Instructions list
            if !selectedPreset.instructions.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(0..<selectedPreset.instructions.count, id: \.self) { index in
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 32, height: 32)

                                Text("\(index + 1)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text(selectedPreset.instructions[index])
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.95))
                        }
                        .opacity(currentInstructionIndex >= index ? 1.0 : 0.5)
                    }
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 40)
            }
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
            let delay = timePerInstruction * Double(index) + 1.0 // Add delay after content shows
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
        // Close existing window synchronously
        window?.close()
        window = nil

        let breakView = BreakView {
            self.closeBreakWindow()
        }

        let hostingController = NSHostingController(rootView: breakView)

        let breakWindow = BreakWindow(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        breakWindow.onEscape = {
            self.closeBreakWindow()
        }

        breakWindow.contentViewController = hostingController
        breakWindow.level = .screenSaver
        breakWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        breakWindow.isOpaque = false
        breakWindow.backgroundColor = NSColor.clear
        breakWindow.ignoresMouseEvents = false
        breakWindow.isReleasedWhenClosed = false

        // Enter fullscreen
        if let screen = NSScreen.main {
            breakWindow.setFrame(screen.frame, display: true)
        }

        window = breakWindow

        // Activate and make key window
        NSApp.activate(ignoringOtherApps: true)
        breakWindow.makeKeyAndOrderFront(nil)
        breakWindow.orderFrontRegardless()
    }

    func closeBreakWindow() {
        DispatchQueue.main.async { [weak self] in
            self?.window?.close()
            self?.window = nil
        }
    }
}

// Custom window subclass to handle ESC key
class BreakWindow: NSWindow {
    var onEscape: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC key
            onEscape?()
        } else {
            super.keyDown(with: event)
        }
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}
