import Foundation
import AVFoundation

class NativeShonaAudio: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    
    override init() {
        super.init()
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
    
    /// Plays native Shona pronunciation - uses pre-recorded files when available
    func speakShona(text: String) {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // First try to play pre-recorded native audio
        if playNativeRecording(for: cleanText) {
            return
        }
        
        // If no recording available, try online pronunciation API
        tryOnlinePronunciation(for: cleanText)
    }
    
    private func playNativeRecording(for word: String) -> Bool {
        // Look for pre-recorded audio file
        guard let audioPath = getNativeAudioPath(for: word),
              let audioData = try? Data(contentsOf: audioPath) else {
            return false
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
            
            isPlaying = true
            audioPlayer?.play()
            return true
        } catch {
            print("Failed to play native audio: \(error)")
            return false
        }
    }
    
    private func getNativeAudioPath(for word: String) -> URL? {
        // Check bundle for pre-recorded audio files
        // Audio files should be named like: "mhoro.m4a", "mangwanani.m4a", etc.
        let fileName = word.replacingOccurrences(of: " ", with: "_")
        
        // Try different audio formats
        let formats = ["m4a", "mp3", "wav"]
        
        for format in formats {
            if let path = Bundle.main.url(forResource: fileName, withExtension: format) {
                return path
            }
        }
        
        return nil
    }
    
    private func tryOnlinePronunciation(for word: String) {
        // Try to get pronunciation from online sources
        // This is a placeholder for future implementation
        
        // Option 1: Try Forvo API (pronunciation dictionary)
        tryForvoAPI(for: word)
        
        // Option 2: Try Google Translate TTS with Shona language code
        // Note: This requires API setup but would be much better than English TTS
        // tryGoogleTranslateTTS(for: word)
        
        // Fallback: Use the best available TTS
        fallbackTTS(for: word)
    }
    
    private func tryForvoAPI(for word: String) {
        // Forvo is the largest pronunciation dictionary
        // API: https://api.forvo.com/v1/word/pronunciations/\(word)/sn/
        // This would require API key and network request
        
        guard let url = URL(string: "https://apifree.forvo.com/key/YOUR_API_KEY/format/json/action/word-pronunciations/word/\(word)/language/sn") else {
            fallbackTTS(for: word)
            return
        }
        
        // For now, skip to fallback since we don't have API key
        // In production, you would:
        // 1. Make network request to Forvo
        // 2. Parse JSON response
        // 3. Download and play the audio URL from native speakers
        
        fallbackTTS(for: word)
    }
    
    private func fallbackTTS(for word: String) {
        // Last resort: Use best available TTS
        let synthesizer = AVSpeechSynthesizer()
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: word)
        
        // Try to find the best voice for African languages
        let preferredVoices = [
            "en-ZA",  // South African English
            "sw",     // Swahili (closest Bantu language)
            "en-NG",  // Nigerian English
            "en-KE",  // Kenyan English
            "fr-SN",  // Senegalese French (has similar sounds)
            "en-US"   // Final fallback
        ]
        
        for voiceCode in preferredVoices {
            if let voice = AVSpeechSynthesisVoice(language: voiceCode) {
                utterance.voice = voice
                break
            }
        }
        
        utterance.rate = 0.4
        utterance.volume = 1.0
        utterance.pitchMultiplier = 0.9
        
        isPlaying = true
        synthesizer.speak(utterance)
        
        // Since we can't easily detect when TTS finishes, set a timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isPlaying = false
        }
    }
    
    func stopSpeaking() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        if let error = error {
            print("Audio decode error: \(error)")
        }
    }
}

// MARK: - Extensions for easy recording management

extension NativeShonaAudio {
    
    /// Returns list of words that have native recordings available
    func getAvailableRecordings() -> [String] {
        let commonWords = [
            "mhoro", "mangwanani", "masikati", "manheru", "makadii",
            "ndiri", "zvakanaka", "tatenda", "sara", "baba", "amai",
            "mukoma", "hanzvadzi", "mwana", "sadza", "mvura", "nyama"
        ]
        
        return commonWords.filter { word in
            getNativeAudioPath(for: word) != nil
        }
    }
    
    /// Instructions for adding native recordings
    static func getRecordingInstructions() -> String {
        return """
        TO ADD NATIVE SHONA RECORDINGS:
        
        1. Record a native Shona speaker saying each word clearly
        2. Save as .m4a, .mp3, or .wav files
        3. Name files exactly as the Shona word (e.g., "mhoro.m4a")
        4. Add files to the app bundle in Xcode
        
        Priority words to record:
        • mhoro (hello)
        • mangwanani (good morning)
        • masikati (good afternoon)
        • manheru (good evening)
        • makadii (how are you?)
        • zvakanaka (fine/good)
        • tatenda (thank you)
        • baba (father)
        • amai (mother)
        • sadza (staple food)
        
        For best results:
        - Use native speakers from Zimbabwe
        - Record in quiet environment
        - Speak at moderate pace
        - High quality audio (44.1kHz, 16-bit minimum)
        """
    }
}