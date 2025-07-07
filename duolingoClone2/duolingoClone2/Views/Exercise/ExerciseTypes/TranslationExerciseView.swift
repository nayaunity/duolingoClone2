import SwiftUI

struct TranslationExerciseView: View {
    let exercise: Exercise
    @Binding var selectedAnswer: String
    
    var body: some View {
        SlideInView(delay: 0.3) {
            VStack(spacing: 30) {
                // Instruction
                Text("Translate this word:")
                    .font(.duolingoHeadline)
                    .foregroundColor(.duolingoTextPrimary)
                
                // Word to translate
                VStack(spacing: 12) {
                    Text(exercise.question.replacingOccurrences(of: "Translate: ", with: ""))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.duolingoBlue)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.duolingoBlue.opacity(0.1))
                        .cornerRadius(16)
                        .duolingoShadow(radius: 4, y: 2)
                    
                    // Audio button placeholder
                    Button(action: {}) {
                        Image(systemName: "speaker.2.fill")
                            .font(.title2)
                            .foregroundColor(.duolingoBlue)
                            .padding(12)
                            .background(Color.duolingoCardBackground)
                            .clipShape(Circle())
                            .duolingoShadow(radius: 4, y: 2)
                    }
                }
                
                // Answer options
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(Array((exercise.options ?? []).enumerated()), id: \.element) { index, option in
                        ScaleInView(delay: Double(index) * 0.1) {
                            Button(action: {
                                withAnimation(.duolingoQuick) {
                                    selectedAnswer = option
                                }
                            }) {
                                Text(option)
                                    .font(.duolingoBody)
                                    .foregroundColor(.duolingoTextPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 12)
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
        type: .translation,
        question: "Translate: Hello",
        correctAnswer: "Mhoro",
        options: ["Mhoro", "Mangwanani", "Masikati", "Manheru"],
        shonaText: nil,
        englishText: nil,
        audioFileName: nil
    )
    
    TranslationExerciseView(exercise: sampleExercise, selectedAnswer: .constant(""))
        .padding()
}