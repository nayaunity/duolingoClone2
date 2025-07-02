import SwiftUI

struct TranslationExerciseView: View {
    let exercise: Exercise
    @Binding var selectedAnswer: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Translate this word:")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(exercise.question.replacingOccurrences(of: "Translate: ", with: ""))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(exercise.options ?? [], id: \.self) { option in
                    Button(action: {
                        selectedAnswer = option
                    }) {
                        Text(option)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(selectedAnswer == option ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedAnswer == option ? Color.blue : Color(.systemGray5))
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
    }
}