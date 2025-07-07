import Foundation
import AVFoundation

class OnlinePronunciationService: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isLoading = false
    @Published var isPlaying = false
    
    /// Attempts to get authentic Shona pronunciation from online sources
    func getAuthenticPronunciation(for word: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        // Method 1: Try Google Translate TTS with Shona language code
        tryGoogleTranslateTTS(for: word) { [weak self] success in
            if success {
                self?.isLoading = false
                completion(true)
                return
            }
            
            // Method 2: Try other online pronunciation sources
            self?.tryAlternativeSources(for: word) { success in
                self?.isLoading = false
                completion(success)
            }
        }
    }
    
    private func tryGoogleTranslateTTS(for word: String, completion: @escaping (Bool) -> Void) {
        // Google Translate TTS API with Shona language code (sn)
        // This is a free API that supports Shona pronunciation
        
        let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? word
        let urlString = "https://translate.google.com/translate_tts?ie=UTF-8&q=\(encodedWord)&tl=sn&client=tw-ob"
        
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                self?.playAudioData(data) { success in
                    completion(success)
                }
            }
        }.resume()
    }
    
    private func tryAlternativeSources(for word: String, completion: @escaping (Bool) -> Void) {
        // Try other sources like:
        // 1. Azure Cognitive Services (has better African language support)
        // 2. Amazon Polly (has some African voices)
        // 3. Coqui TTS (open source, can be trained on Shona)
        
        tryAzureTTS(for: word, completion: completion)
    }
    
    private func tryAzureTTS(for word: String, completion: @escaping (Bool) -> Void) {
        // Azure Cognitive Services TTS with African voices
        // This would require an API key but provides much better pronunciation
        
        // For now, return false since we don't have API key
        // In production, you would:
        // 1. Set up Azure Cognitive Services account
        // 2. Use African English or available African language voices
        // 3. Make authenticated requests
        
        completion(false)
    }
    
    private func playAudioData(_ data: Data, completion: @escaping (Bool) -> Void) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
            
            isPlaying = true
            if audioPlayer?.play() == true {
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Failed to play audio data: \(error)")
            completion(false)
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
        isLoading = false
    }
}

extension OnlinePronunciationService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}