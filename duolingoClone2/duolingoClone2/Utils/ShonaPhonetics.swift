import Foundation

struct ShonaPhonetics {
    
    /// Applies minimal, natural adjustments to Shona text for better TTS pronunciation
    static func toPhonetic(_ shonaText: String) -> String {
        var phoneticText = shonaText.lowercased()
        
        // Very minimal adjustments - only the most problematic sounds
        let phoneticMappings: [(String, String)] = [
            // Just handle the most obvious mispronunciations
            ("mhoro", "m-horo"),        // Hello - slight pause before h
            ("zh", "z"),               // Just use z sound instead of zh
            ("sv", "s-v"),             // Slight separation
            ("zv", "z-v")              // Slight separation
        ]
        
        // Apply minimal adjustments
        for (shona, phonetic) in phoneticMappings {
            phoneticText = phoneticText.replacingOccurrences(of: shona, with: phonetic)
        }
        
        return phoneticText
    }
    
    /// Gets phonetic pronunciation with proper syllable breaks
    static func getPhoneticPronunciation(for word: String) -> String {
        let phonetic = toPhonetic(word)
        
        // Add slight pauses between syllables for clarity
        return phonetic.replacingOccurrences(of: "-", with: " ")
    }
}