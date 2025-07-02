import SwiftUI

struct ListenAndRepeatExerciseView: View {
    let exercise: Exercise
    @Binding var selectedAnswer: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(exercise.question)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // TODO: Play audio
            }) {
                Image(systemName: "speaker.3.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
            }
            
            Text("Audio feature coming soon!")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            selectedAnswer = exercise.correctAnswer
        }
    }
}