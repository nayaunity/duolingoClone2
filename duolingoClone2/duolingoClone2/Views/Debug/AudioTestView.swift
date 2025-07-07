import SwiftUI
import AVFoundation

struct AudioTestView: View {
    @State private var message = "Tap to test audio"
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Debug Test")
                .font(.title)
                .padding()
            
            Text(message)
                .padding()
                .multilineTextAlignment(.center)
            
            Button("Test Basic TTS") {
                testBasicTTS()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Test Enhanced TTS") {
                testEnhancedTTS()
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("List Available Voices") {
                listVoices()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    func testBasicTTS() {
        message = "Testing basic TTS..."
        
        let utterance = AVSpeechUtterance(string: "Hello world")
        utterance.rate = 0.5
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            message = "Basic TTS should have played"
        }
    }
    
    func testEnhancedTTS() {
        message = "Testing enhanced TTS..."
        
        let utterance = AVSpeechUtterance(string: "mhoro")
        utterance.rate = 0.4
        utterance.volume = 1.0
        
        // Try to find South African English voice
        if let voice = AVSpeechSynthesisVoice(language: "en-ZA") {
            utterance.voice = voice
            message = "Using South African English voice"
        } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
            message = "Using US English voice (fallback)"
        }
        
        speechSynthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            message = "Enhanced TTS should have played"
        }
    }
    
    func listVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        message = "Found \(voices.count) voices:\n"
        
        // Show first few voices
        for voice in voices.prefix(5) {
            message += "\(voice.name) (\(voice.language))\n"
        }
        
        // Look for African voices specifically
        let africanVoices = voices.filter { voice in
            voice.language.contains("ZA") || voice.language.contains("NG") || voice.language.contains("KE")
        }
        
        if !africanVoices.isEmpty {
            message += "\nAfrican voices found:\n"
            for voice in africanVoices {
                message += "\(voice.name) (\(voice.language))\n"
            }
        } else {
            message += "\nNo African voices found"
        }
    }
}

#Preview {
    AudioTestView()
}