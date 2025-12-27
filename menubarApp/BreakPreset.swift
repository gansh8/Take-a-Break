//
//  BreakPreset.swift
//  menubarApp
//
//  Created by Claude on 27/12/25.
//

import SwiftUI

struct BreakPreset: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let backgroundColor: Color
    let instructions: [String]

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, iconName, instructions
        case backgroundColorHex
    }

    init(id: String, title: String, subtitle: String, iconName: String, backgroundColor: Color, instructions: [String]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.backgroundColor = backgroundColor
        self.instructions = instructions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        iconName = try container.decode(String.self, forKey: .iconName)
        instructions = try container.decode([String].self, forKey: .instructions)

        let hexString = try container.decode(String.self, forKey: .backgroundColorHex)
        backgroundColor = Color(hex: hexString) ?? .blue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(backgroundColor.toHex(), forKey: .backgroundColorHex)
    }
}

extension BreakPreset {
    static let drinkWater = BreakPreset(
        id: "drink_water",
        title: "Hydrate",
        subtitle: "Time to drink some water",
        iconName: "drop.fill",
        backgroundColor: Color(red: 0.2, green: 0.6, blue: 0.86),
        instructions: [
            "Stand up and grab your water bottle",
            "Drink at least 8 ounces of water",
            "Stay hydrated for better focus"
        ]
    )

    static let stretch = BreakPreset(
        id: "stretch",
        title: "Stretch",
        subtitle: "Release tension from your body",
        iconName: "figure.flexibility",
        backgroundColor: Color(red: 0.4, green: 0.7, blue: 0.4),
        instructions: [
            "Stand up and reach for the ceiling",
            "Gently twist your torso left and right",
            "Touch your toes to stretch your back",
            "Roll your shoulders backward 5 times"
        ]
    )

    static let neckExercise = BreakPreset(
        id: "neck_exercise",
        title: "Neck Care",
        subtitle: "Relieve neck tension",
        iconName: "figure.mind.and.body",
        backgroundColor: Color(red: 0.7, green: 0.5, blue: 0.8),
        instructions: [
            "Slowly tilt your head to the right",
            "Hold for 5 seconds, then tilt left",
            "Gently roll your head in a circle",
            "Look up at the ceiling, then down",
            "Repeat 3 times"
        ]
    )

    static let handStretch = BreakPreset(
        id: "hand_stretch",
        title: "Hand & Wrist",
        subtitle: "Prevent repetitive strain",
        iconName: "hand.raised.fill",
        backgroundColor: Color(red: 0.95, green: 0.6, blue: 0.4),
        instructions: [
            "Extend your arm with palm facing up",
            "Gently pull fingers back with other hand",
            "Hold for 10 seconds, switch hands",
            "Make a fist, then spread fingers wide",
            "Rotate wrists clockwise, then counter-clockwise"
        ]
    )

    static let walk = BreakPreset(
        id: "walk",
        title: "Take a Walk",
        subtitle: "Get your body moving",
        iconName: "figure.walk",
        backgroundColor: Color(red: 0.3, green: 0.7, blue: 0.6),
        instructions: [
            "Step away from your desk",
            "Walk around your space for 30 seconds",
            "Swing your arms naturally",
            "Take deep breaths as you walk",
            "Return feeling refreshed"
        ]
    )

    static let eyeRest = BreakPreset(
        id: "eye_rest",
        title: "Eye Rest",
        subtitle: "Reduce eye strain",
        iconName: "eye.fill",
        backgroundColor: Color(red: 0.5, green: 0.5, blue: 0.7),
        instructions: [
            "Look away from your screen",
            "Focus on something 20 feet away",
            "Blink 10 times slowly",
            "Close your eyes for 10 seconds",
            "Gently massage your temples"
        ]
    )

    static let breathe = BreakPreset(
        id: "breathe",
        title: "Deep Breathing",
        subtitle: "Calm your mind",
        iconName: "lungs.fill",
        backgroundColor: Color(red: 0.6, green: 0.7, blue: 0.9),
        instructions: [
            "Sit comfortably or stand up",
            "Breathe in slowly through your nose (4 counts)",
            "Hold your breath (4 counts)",
            "Exhale slowly through your mouth (6 counts)",
            "Repeat 5 times"
        ]
    )

    static let custom = BreakPreset(
        id: "custom",
        title: "Custom",
        subtitle: "Your personalized break message",
        iconName: "pencil.circle.fill",
        backgroundColor: .black,
        instructions: []
    )

    static let allPresets: [BreakPreset] = [
        .drinkWater,
        .stretch,
        .neckExercise,
        .handStretch,
        .walk,
        .eyeRest,
        .breathe,
        .custom
    ]

    static func preset(withId id: String) -> BreakPreset? {
        return allPresets.first { $0.id == id }
    }
}

// Color extension for hex conversion
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
            return "#000000"
        }

        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
