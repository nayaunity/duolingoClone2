import Foundation
import AVFoundation

class AuthenticShonaAudio: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {
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
    
    /// Speaks Shona using International Phonetic Alphabet (IPA) mappings
    func speakShona(text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Convert to IPA-based pronunciation
        let ipaText = convertToIPA(text)
        
        let utterance = AVSpeechUtterance(string: ipaText)
        
        // Try to find the best available voice for African languages
        utterance.voice = getBestVoiceForShona()
        utterance.rate = 0.35
        utterance.volume = 1.0
        utterance.pitchMultiplier = 0.9 // Slightly lower for African feel
        
        synthesizer.speak(utterance)
    }
    
    private func getBestVoiceForShona() -> AVSpeechSynthesisVoice? {
        // Priority order for voices that might handle Shona better
        let preferredLanguages = [
            "en-ZA",  // South African English - closest to Shona phonetics
            "sw",     // Swahili - similar phonetic system
            "zu",     // Zulu - Bantu language like Shona
            "xh",     // Xhosa - Bantu language like Shona
            "af-ZA",  // Afrikaans (South Africa) - familiar with African sounds
            "en-KE",  // Kenyan English
            "en-NG",  // Nigerian English
            "en-US"   // Fallback
        ]
        
        for language in preferredLanguages {
            if let voice = AVSpeechSynthesisVoice(language: language) {
                return voice
            }
        }
        
        return AVSpeechSynthesisVoice(language: "en-US")
    }
    
    private func convertToIPA(_ shonaText: String) -> String {
        let text = shonaText.lowercased()
        
        // Map common Shona words to their IPA pronunciation
        let wordMappings: [String: String] = [
            // Greetings
            "mhoro": "m̥oɾo",           // Hello
            "mangwanani": "maŋɡʷanani", // Good morning  
            "masikati": "masikati",      // Good afternoon
            "manheru": "manheɾu",        // Good evening
            "makadii": "makadi:",        // How are you?
            
            // Common responses
            "ndiri": "ndiɾi",           // I am
            "zvakanaka": "zʋakanaka",    // Fine/good
            "tatenda": "tatenda",        // Thank you
            "sara": "saɾa",              // Stay well
            
            // Family
            "baba": "baba",              // Father
            "amai": "amai",              // Mother
            "mukoma": "mukoma",          // Elder brother
            "hanzvadzi": "hanzvadzi",    // Sister
            "mwana": "mʷana",            // Child
            
            // Food
            "sadza": "sadza",            // Staple food
            "doro": "doɾo",              // Beer
            "mvura": "mvuɾa",            // Water
            "nyama": "ɲama",             // Meat
            
            // Time/Seasons
            "zuva": "zuva",              // Sun/day
            "mwedzi": "mʷedzi",          // Moon/month
            "chirimo": "tʃiɾimo",        // Spring
            "zhizha": "ʒiʒa"             // Summer
        ]
        
        // Check if we have a direct mapping for the word
        if let ipaMapping = wordMappings[text] {
            return ipaMapping
        }
        
        // If no direct mapping, apply phonetic rules
        return applyIPATransformation(text)
    }
    
    private func applyIPATransformation(_ text: String) -> String {
        var result = text
        
        // Basic Shona phonetic rules
        let transformations: [(String, String)] = [
            // Aspirated consonants
            ("mh", "m̥"),   // Voiceless m
            ("nh", "n̥"),   // Voiceless n
            ("bh", "b̤"),   // Breathy b
            ("dh", "d̤"),   // Breathy d
            ("vh", "v̤"),   // Breathy v
            
            // Fricatives
            ("zh", "ʒ"),   // Like 'zh' in measure
            ("sv", "sv"),  // Keep as is
            ("zv", "zv"),  // Keep as is
            
            // Prenasalized consonants
            ("mb", "ᵐb"), 
            ("nd", "ⁿd"),
            ("ng", "ⁿɡ"),
            ("nz", "ⁿz"),
            
            // Clicks and other consonants
            ("r", "ɾ"),    // Tap/flap r
            ("ny", "ɲ"),   // Palatal nasal
            ("ch", "tʃ"),  // Voiceless postalveolar affricate
            
            // Vowels (Shona has 5 pure vowels)
            // Keep them mostly as is since they're close to IPA
        ]
        
        for (shona, ipa) in transformations {
            result = result.replacingOccurrences(of: shona, with: ipa)
        }
        
        return result
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}