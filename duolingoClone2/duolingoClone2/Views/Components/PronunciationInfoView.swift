import SwiftUI

struct PronunciationInfoView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🗣️ Authentic Shona Pronunciation")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("This app uses International Phonetic Alphabet (IPA) mappings to provide more accurate Shona pronunciation than standard English text-to-speech.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Shona Sounds")
                            .font(.headline)
                        
                        PronunciationGuideRow(
                            letter: "mh",
                            description: "Aspirated 'm' - like 'm' with a puff of air",
                            example: "mhoro (hello)"
                        )
                        
                        PronunciationGuideRow(
                            letter: "zh",
                            description: "Like 'zh' in 'measure'",
                            example: "zhizha (summer)"
                        )
                        
                        PronunciationGuideRow(
                            letter: "r",
                            description: "Rolled/tapped 'r' sound",
                            example: "sara (stay well)"
                        )
                        
                        PronunciationGuideRow(
                            letter: "ny",
                            description: "Like 'ny' in 'canyon'",
                            example: "nyama (meat)"
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vowels")
                            .font(.headline)
                        
                        Text("Shona has 5 pure vowels that are always pronounced the same way:")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        PronunciationGuideRow(letter: "a", description: "Like 'a' in 'father'", example: "baba")
                        PronunciationGuideRow(letter: "e", description: "Like 'e' in 'get'", example: "sekuru")
                        PronunciationGuideRow(letter: "i", description: "Like 'ee' in 'see'", example: "makadii")
                        PronunciationGuideRow(letter: "o", description: "Like 'o' in 'note'", example: "mhoro")
                        PronunciationGuideRow(letter: "u", description: "Like 'oo' in 'food'", example: "mvura")
                    }
                    
                    Text("💡 The audio uses advanced phonetic mapping to help you learn authentic Shona pronunciation that will be understood in Zimbabwe.")
                        .font(.callout)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Pronunciation Guide")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

struct PronunciationGuideRow: View {
    let letter: String
    let description: String
    let example: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(letter)
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(width: 30, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(description)
                    .font(.body)
                
                Text(example)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}