import Foundation
import AVFoundation

enum AudioQuality {
    case native          // Native speaker recordings
    case huggingFace     // Hugging Face Shona TTS (authentic AI model)
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
    private let huggingFaceService = HuggingFaceShonaService()
    private let onlineService = OnlinePronunciationService()
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
        
        // Priority 2: Try Hugging Face Shona TTS (authentic AI model)
        tryHuggingFaceTTS(for: word)
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
    
    private func tryHuggingFaceTTS(for word: String) {
        huggingFaceService.speakShona(word) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.currentQuality = .huggingFace
                    self?.isLoading = false
                    self?.isPlaying = true
                    
                    // Monitor Hugging Face service state
                    self?.observeHuggingFaceService()
                } else {
                    // Fallback to Google Translate
                    self?.tryOnlineAuthentic(for: word)
                }
            }
        }
    }
    
    private func observeHuggingFaceService() {
        // Simple observer for Hugging Face service
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.huggingFaceService.isPlaying && !self.huggingFaceService.isLoading {
                self.isPlaying = false
            } else if self.huggingFaceService.isPlaying {
                self.observeHuggingFaceService()
            }
        }
    }
    
    private func tryOnlineAuthentic(for word: String) {
        onlineService.getAuthenticPronunciation(for: word) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.currentQuality = .onlineAuthentic
                    self?.isLoading = false
                    self?.isPlaying = true
                    
                    // Monitor online service state
                    self?.observeOnlineService()
                } else {
                    // Fallback to enhanced TTS
                    self?.useEnhancedTTS(for: word)
                }
            }
        }
    }
    
    private func observeOnlineService() {
        // Simple observer for online service
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.onlineService.isPlaying && !self.onlineService.isLoading {
                self.isPlaying = false
            } else if self.onlineService.isPlaying {
                self.observeOnlineService()
            }
        }
    }
    
    private func useEnhancedTTS(for word: String) {
        currentQuality = .enhanced
        isLoading = false
        
        print("Using Enhanced TTS for word: \(word)")
        
        // Stop any existing speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        // Use the best available African-influenced voice
        let selectedVoice = getBestAfricanVoice()
        
        // Apply Shona-specific phonetic improvements based on voice type
        let improvedText = applyShonaPhoneticHints(to: word, voice: selectedVoice)
        let utterance = AVSpeechUtterance(string: improvedText)
        
        // Check if current voice is African for parameter optimization
        let voiceName = selectedVoice?.name.lowercased() ?? ""
        let isCurrentVoiceAfrican = selectedVoice?.language.contains("sw") == true ||
                                   selectedVoice?.language.contains("NG") == true ||
                                   selectedVoice?.language.contains("KE") == true ||
                                   selectedVoice?.language.contains("ZA") == true ||
                                   voiceName.contains("trinoids") ||
                                   voiceName.contains("nigerian")
        
        if let voice = selectedVoice {
            utterance.voice = voice
            print("Using voice: \(voice.name) (\(voice.language))")
            print("Original text: '\(word)' -> Phonetic: '\(improvedText)'")
        } else {
            print("No suitable voice found, using default")
        }
        
        // More natural settings for African voices
        if isCurrentVoiceAfrican {
            utterance.rate = 0.45         // Slightly faster, more natural
            utterance.volume = 1.0
            utterance.pitchMultiplier = 0.9   // Less pitch modification
            utterance.preUtteranceDelay = 0.05
        } else {
            utterance.rate = 0.3          // Slower for non-African voices
            utterance.volume = 1.0
            utterance.pitchMultiplier = 0.85
            utterance.preUtteranceDelay = 0.1
        }
        
        print("Starting TTS playback...")
        isPlaying = true
        speechSynthesizer.speak(utterance)
    }
    
    private func getBestAfricanVoice() -> AVSpeechSynthesisVoice? {
        // Debug: List all available voices
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        print("Available voices: \(allVoices.count)")
        for voice in allVoices.prefix(5) {
            print("  \(voice.name) (\(voice.language))")
        }
        
        let voicePriorities = [
            "sw-KE",  // Swahili (BEST - similar Bantu phonetics to Shona!)
            "sw-TZ",  // Swahili Tanzania  
            "en-NG",  // Nigerian English (excellent for African sounds)
            "en-KE",  // Kenyan English (familiar with Bantu languages)
            "yo-NG",  // Yoruba (Nigerian, good phonetics)
            "ig-NG",  // Igbo (Nigerian, good phonetics)
            "ha-NG",  // Hausa (Nigerian)
            "en-ZA",  // South African English
            "af-ZA",  // Afrikaans (familiar with African sounds)
            "zu-ZA",  // Zulu (Bantu language like Shona!)
            "xh-ZA",  // Xhosa (Bantu language)
            "st-ZA",  // Sotho (Bantu language)
            "tn-ZA",  // Tswana (Bantu language)
            "fr-SN",  // Senegalese French (has click sounds)
            "en-AU",  // Australian English (different vowel system)
            "en-US"   // Final fallback
        ]
        
        for voiceCode in voicePriorities {
            if let voice = AVSpeechSynthesisVoice(language: voiceCode) {
                print("Found voice for \(voiceCode): \(voice.name) (actual language: \(voice.language))")
                return voice
            } else {
                print("No voice found for \(voiceCode)")
            }
        }
        
        print("Using default voice")
        return AVSpeechSynthesisVoice(language: "en-US")
    }
    
    /// Applies phonetic hints based on the voice type
    private func applyShonaPhoneticHints(to word: String, voice: AVSpeechSynthesisVoice?) -> String {
        var improved = word.lowercased()
        
        // Shona phonetic substitutions optimized for African language voices
        let phoneticMappings: [String: String] = [
            // Common Shona words - simplified for African voices (less English-centric)
            "mhoro": "mhoro",             // Keep original - African voices handle this better
            "mangwanani": "mangwanani",   // African voices know these patterns
            "masikati": "masikati",       // Keep original
            "manheru": "manheru",         // Keep original  
            "makadii": "makadii",         // Keep original
            "zvakanaka": "zvakanaka",     // Keep original
            "tatenda": "tatenda",         // Keep original
            "sara": "sara",               // Keep original
            "kwazvo": "kwazvo",           // Keep original
            
            // Only adjust problematic combinations for non-African fallback voices
            "english_mhoro": "m-HO-ro",           // For English voices only
            "english_mangwanani": "mahn-gwa-NAH-nee",
            "english_masikati": "mah-see-KAH-tee",
            "english_manheru": "mahn-HEH-roo",
            "english_makadii": "mah-kah-DEE",
            "english_zvakanaka": "zvah-kah-NAH-kah",
            "english_tatenda": "tah-TEN-dah",
            "english_sara": "SAH-rah",
            "english_kwazvo": "kwah-ZVO",
            
            // Common letter combinations
            "mh": "m-h",    // Aspirated m - add slight separation
            "vh": "v-h",    // Aspirated v
            "bh": "b-h",    // Aspirated b
            "dh": "d-h",    // Aspirated d
            "zh": "zh",     // Keep zh sound
            "sv": "sv",     // sv combination
            "zv": "zv",     // zv combination
        ]
        
        // Check if we're using an African language voice
        // Note: Nigerian voices may report as en-US but have Nigerian characteristics
        let voiceName = voice?.name.lowercased() ?? ""
        let isAfricanVoice = voice?.language.contains("sw") == true ||  // Swahili
                            voice?.language.contains("NG") == true ||   // Nigerian
                            voice?.language.contains("KE") == true ||   // Kenyan  
                            voice?.language.contains("ZA") == true ||   // South African languages
                            voiceName.contains("trinoids") ||          // Nigerian voice on iOS
                            voiceName.contains("nigerian")
        
        if isAfricanVoice {
            // African voices can handle Shona phonetics better - use original word
            print("Using African voice - keeping original pronunciation")
            return improved
        } else {
            // Non-African voice - apply English phonetic mappings
            print("Using non-African voice - applying phonetic hints")
            if let phoneticVersion = phoneticMappings["english_\(improved)"] {
                return phoneticVersion
            }
            
            // Apply pattern-based improvements for English voices
            for (pattern, replacement) in phoneticMappings {
                if pattern.count <= 2 { // Letter combinations
                    improved = improved.replacingOccurrences(of: pattern, with: replacement)
                }
            }
        }
        
        return improved
    }
    
    func stopSpeaking() {
        isPlaying = false
        isLoading = false
        speechSynthesizer.stopSpeaking(at: .immediate)
        nativeAudio.stopSpeaking()
        huggingFaceService.stopPlaying()
        onlineService.stopPlaying()
    }
    
    /// Returns the quality level for a specific word
    func getQualityForWord(_ word: String) -> AudioQuality {
        if hasNativeRecording(for: word) {
            return .native
        } else if huggingFaceService.apiKey != nil {
            return .huggingFace // Hugging Face available with API key
        } else {
            return .enhanced // Will fall back to enhanced TTS
        }
    }
    
    /// Returns instructions for improving pronunciation quality
    func getQualityImprovementTips() -> String {
        return """
        🎯 PRONUNCIATION QUALITY LEVELS:
        
        🟢 NATIVE: Recorded by native Shona speakers
        🔵 AUTHENTIC: Google Translate Shona TTS
        🟡 ENHANCED: Optimized African-influenced TTS
        🔴 BASIC: Standard English TTS
        
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