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
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color(NSColor(cgColor: AppPreferences.shared.breakViewBackgroundColor) ?? NSColor.black)
                .ignoresSafeArea()
                .opacity(opacity)
            
            if showContent {
                VStack(spacing: 50) {
                    if AppPreferences.shared.enableStandupBreak {
                        VStack(spacing: 20) {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            Text("Time to Stand Up!")
                                .font(.system(size: 80, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Take a moment to stretch and move around")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        Text(AppPreferences.shared.breakMessage)
                            .font(.system(size: 100, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("Skip") {
                        timer?.invalidate()
                        timer = nil
                        onClose()
                    }
                    .font(.system(size: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
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
		Task.detached {[weak self] in
			guard self?.window != nil else { return }
			await self?.window?.close()
			self?.window = nil
		}
    }
}
