import SwiftUI

struct AudioQualityInfoView: View {
    @StateObject private var audioManager = AuthenticShonaAudioManager()
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎯 Authentic Shona Pronunciation")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("This app uses multiple methods to provide the most authentic Shona pronunciation possible.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Quality Levels
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Audio Quality Levels")
                            .font(.headline)
                        
                        QualityLevelRow(
                            color: .green,
                            label: "NATIVE",
                            title: "Native Speaker Recordings",
                            description: "Actual recordings from Zimbabwean Shona speakers - the gold standard for pronunciation."
                        )
                        
                        QualityLevelRow(
                            color: .purple,
                            label: "AI-SHONA",
                            title: "Hugging Face Shona AI Model",
                            description: "State-of-the-art AI model specifically trained on Shona speech - requires API key for full access."
                        )
                        
                        QualityLevelRow(
                            color: .blue,
                            label: "SHONA",
                            title: "Google Translate Shona TTS",
                            description: "Online text-to-speech specifically trained on Shona language - very authentic."
                        )
                        
                        QualityLevelRow(
                            color: .orange,
                            label: "ENHANCED",
                            title: "African-Optimized TTS",
                            description: "Uses South African English and other African voices for better pronunciation."
                        )
                        
                        QualityLevelRow(
                            color: .gray,
                            label: "BASIC",
                            title: "Standard TTS",
                            description: "Fallback option - not ideal for learning authentic pronunciation."
                        )
                    }
                    
                    // Current Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What You're Getting")
                            .font(.headline)
                        
                        Text("Most words currently use ENHANCED quality (African-optimized TTS). AI-SHONA quality (Hugging Face model) is available with API authentication for incredibly authentic pronunciation.")
                            .font(.body)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Adding Native Recordings")
                            .font(.headline)
                        
                        Text(audioManager.getQualityImprovementTips())
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Demo Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Try It Out")
                            .font(.headline)
                        
                        Text("Tap the speaker icons throughout the app. You'll hear much better pronunciation using African-optimized voices. For incredibly authentic AI-powered Shona, add a Hugging Face API key.")
                            .font(.body)
                        
                        HStack {
                            Button(action: {
                                audioManager.speakShona("mhoro")
                            }) {
                                HStack {
                                    Image(systemName: "speaker.2.fill")
                                    Text("mhoro")
                                    Text("(hello)")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Audio Quality")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

struct QualityLevelRow: View {
    let color: Color
    let label: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(color)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}