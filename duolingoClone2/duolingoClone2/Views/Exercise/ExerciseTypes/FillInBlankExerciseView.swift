import SwiftUI

struct FillInBlankExerciseView: View {
    let exercise: Exercise
    @Binding var selectedAnswer: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(exercise.question)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            TextField("Type your answer", text: $selectedAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3)
        }
        .padding()
    }
}