import Foundation
import AVFoundation

enum AudioQuality {
    case native          // Native speaker recordings
    case onlineAuthentic // Google Translate Shona TTS
    case enhanced        // Best available TTS
    case basic          // Fallback TTS
}

class AuthenticShonaAudioManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var currentQuality: AudioQuality = .basic
    
    private var audioPlayer: AVAudioPlayer?
    private var speechSynthesizer = AVSpeechSynthesizer()
    private let nativeAudio = NativeShonaAudio()
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    /// Main method to play Shona with best available pronunciation
    func speakShona(_ word: String) {
        if isPlaying {
            stopSpeaking()
            return
        }
        
        isLoading = true
        
        // Priority 1: Try native recordings (best quality)
        if hasNativeRecording(for: word) {
            playNativeRecording(for: word)
            return
        }
        
        // Use default enhanced TTS
        useEnhancedTTS(for: word)
    }
    
    private func hasNativeRecording(for word: String) -> Bool {
        let fileName = word.lowercased().replacingOccurrences(of: " ", with: "_")
        let formats = ["m4a", "mp3", "wav"]
        
        for format in formats {
            if Bundle.main.url(forResource: fileName, withExtension: format) != nil {
                return true
            }
        }
        return false
    }
    
    private func playNativeRecording(for word: String) {
        currentQuality = .native
        nativeAudio.speakShona(text: word)
        
        // Monitor native audio state
        DispatchQueue.main.async {
            self.isLoading = false
            self.isPlaying = true
        }
        
        // Check when it finishes (simplified)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.nativeAudio.isPlaying {
                self.isPlaying = false
            }
        }
    }
    
    
    private func useEnhancedTTS(for word: String) {
        currentQuality = .basic
        isLoading = false
        
        print("Using default TTS for word: \(word)")
        
        // Stop any existing speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        // Use simple default TTS
        let utterance = AVSpeechUtterance(string: word)
        utterance.rate = 0.5
        utterance.volume = 1.0
        
        print("Starting TTS playback...")
        isPlaying = true
        speechSynthesizer.speak(utterance)
    }
    
    
    func stopSpeaking() {
        isPlaying = false
        isLoading = false
        speechSynthesizer.stopSpeaking(at: .immediate)
        nativeAudio.stopSpeaking()
    }
    
    /// Returns the quality level for a specific word
    func getQualityForWord(_ word: String) -> AudioQuality {
        if hasNativeRecording(for: word) {
            return .native
        } else {
            return .basic // Will use default device TTS
        }
    }
    
    /// Returns instructions for improving pronunciation quality
    func getQualityImprovementTips() -> String {
        return """
        🎯 PRONUNCIATION QUALITY LEVELS:
        
        🟢 NATIVE: Recorded by native Shona speakers
        🔴 BASIC: Standard device TTS
        
        TO GET NATIVE QUALITY:
        1. Record native speakers saying each word
        2. Save as .m4a files named exactly like the word
        3. Add to app bundle in Xcode
        
        PRIORITY WORDS FOR RECORDING:
        • mhoro, mangwanani, masikati, manheru
        • makadii, zvakanaka, tatenda, sara
        • baba, amai, mukoma, hanzvadzi
        • sadza, mvura, nyama, doro
        """
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("TTS: Started speaking")
        DispatchQueue.main.async {
            self.isPlaying = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("TTS: Finished speaking")
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("TTS: Cancelled speaking")
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
