import SwiftUI

struct MultipleChoiceExerciseView: View {
    let exercise: Exercise
    @Binding var selectedAnswer: String
    
    var body: some View {
        SlideInView(delay: 0.3) {
            VStack(spacing: 30) {
                // Question
                Text(exercise.question)
                    .font(.duolingoHeadline)
                    .foregroundColor(.duolingoTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Answer options
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                    ForEach(Array((exercise.options ?? []).enumerated()), id: \.element) { index, option in
                        ScaleInView(delay: Double(index) * 0.1) {
                            Button(action: {
                                withAnimation(.duolingoQuick) {
                                    selectedAnswer = option
                                }
                            }) {
                                HStack {
                                    Text(option)
                                        .font(.duolingoBody)
                                        .foregroundColor(.duolingoTextPrimary)
                                    Spacer()
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                            }
                            .buttonStyle(DuolingoOptionButtonStyle(
                                isSelected: selectedAnswer == option,
                                isCorrect: nil,
                                isIncorrect: nil
                            ))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    let sampleExercise = Exercise(
        type: .multipleChoice,
        question: "What does 'Mhoro' mean?",
        correctAnswer: "Hello",
        options: ["Hello", "Goodbye", "Thank you", "Please"],
        shonaText: nil,
        englishText: nil,
        audioFileName: nil
    )
    
    MultipleChoiceExerciseView(exercise: sampleExercise, selectedAnswer: .constant(""))
        .padding()
}