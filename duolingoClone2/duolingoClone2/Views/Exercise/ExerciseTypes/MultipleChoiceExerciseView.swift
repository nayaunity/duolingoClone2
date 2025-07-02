import SwiftUI

struct MultipleChoiceExerciseView: View {
    let exercise: Exercise
    @Binding var selectedAnswer: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(exercise.question)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(exercise.options ?? [], id: \.self) { option in
                    Button(action: {
                        selectedAnswer = option
                    }) {
                        HStack {
                            Text(option)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(selectedAnswer == option ? .white : .primary)
                            Spacer()
                        }
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