import SwiftUI

struct MatchPairsExerciseView: View {
    let exercise: Exercise
    @Binding var selectedAnswer: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(exercise.question)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Feature coming soon!")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            selectedAnswer = exercise.correctAnswer
        }
    }
}