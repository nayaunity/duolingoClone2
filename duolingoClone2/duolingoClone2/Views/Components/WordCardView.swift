import SwiftUI

struct WordCardView: View {
    let word: ShonaWord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.shona)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(word.english)
                    .font(.body)
                    .foregroundColor(.secondary)
                Text(word.pronunciation)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.blue)
            }
            Spacer()
            
            VStack {
                Image(systemName: "speaker.2.fill")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        // TODO: Add audio playback
                    }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}