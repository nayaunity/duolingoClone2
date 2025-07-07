import Foundation
import AVFoundation

class SpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {
        // Request audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func speak(text: String, language: String = "en-US") {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.4 // Slower rate for learning
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    func speakShona(text: String) {
        // Use original Shona text with optimized speech settings
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.35 // Slightly slower for clarity
        utterance.volume = 1.0
        utterance.pitchMultiplier = 0.95 // Slightly lower pitch for African feel
        
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // Debug function to test phonetic conversion
    func getPhoneticPreview(for shonaText: String) -> String {
        return ShonaPhonetics.getPhoneticPronunciation(for: shonaText)
    }
}