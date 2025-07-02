import SwiftUI

struct FillInBlankExerciseView: View {
    let exercise: Exercise
    @Binding var selectedAnswer: String
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        SlideInView(delay: 0.3) {
            VStack(spacing: 40) {
                // Question
                Text(exercise.question)
                    .font(.duolingoHeadline)
                    .foregroundColor(.duolingoTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Text input
                VStack(spacing: 12) {
                    TextField("Type your answer", text: $selectedAnswer)
                        .font(.duolingoBody)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.duolingoCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isTextFieldFocused ? Color.duolingoBlue : Color.duolingoGrayLight,
                                    lineWidth: 2
                                )
                        )
                        .cornerRadius(16)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    // Hint text
                    Text("Tap here to type your answer")
                        .font(.duolingoSmall)
                        .foregroundColor(.duolingoTextSecondary)
                        .opacity(selectedAnswer.isEmpty ? 1 : 0)
                        .animation(.duolingoEaseInOut, value: selectedAnswer.isEmpty)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
    }
}