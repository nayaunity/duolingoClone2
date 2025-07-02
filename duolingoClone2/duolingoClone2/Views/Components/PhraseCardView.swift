import SwiftUI

struct PhraseCardView: View {
    let phrase: ShonaPhrase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(phrase.shona)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(phrase.english)
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text(phrase.pronunciation)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.blue)
                }
                Spacer()
                
                Image(systemName: "speaker.2.fill")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        // TODO: Add audio playback
                    }
            }
            
            Text(phrase.context)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}