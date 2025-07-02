import SwiftUI

struct ExerciseView: View {
    let lesson: Lesson
    @ObservedObject var lessonManager: LessonManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentExerciseIndex = 0
    @State private var selectedAnswer = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var correctAnswers = 0
    @State private var showLessonComplete = false
    
    var currentExercise: Exercise? {
        lesson.exercises.indices.contains(currentExerciseIndex) ? lesson.exercises[currentExerciseIndex] : nil
    }
    
    var progress: Double {
        guard !lesson.exercises.isEmpty else { return 0 }
        return Double(currentExerciseIndex) / Double(lesson.exercises.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if let exercise = currentExercise {
                exerciseContentView(exercise: exercise)
            } else {
                lessonCompleteView
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showLessonComplete) {
            LessonCompleteView(
                lesson: lesson,
                correctAnswers: correctAnswers,
                totalQuestions: lesson.exercises.count,
                lessonManager: lessonManager
            ) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(currentExerciseIndex + 1)/\(lesson.exercises.count)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func exerciseContentView(exercise: Exercise) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            switch exercise.type {
            case .translation:
                TranslationExerciseView(exercise: exercise, selectedAnswer: $selectedAnswer)
            case .multipleChoice:
                MultipleChoiceExerciseView(exercise: exercise, selectedAnswer: $selectedAnswer)
            case .fillInBlank:
                FillInBlankExerciseView(exercise: exercise, selectedAnswer: $selectedAnswer)
            case .matchPairs:
                MatchPairsExerciseView(exercise: exercise, selectedAnswer: $selectedAnswer)
            case .listenAndRepeat:
                ListenAndRepeatExerciseView(exercise: exercise, selectedAnswer: $selectedAnswer)
            }
            
            Spacer()
            
            if showResult {
                resultView
            } else {
                checkAnswerButton
            }
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isCorrect ? .green : .red)
                
                Spacer()
            }
            
            if !isCorrect, let exercise = currentExercise {
                Text("Correct answer: \(exercise.correctAnswer)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Button(action: nextExercise) {
                HStack {
                    Spacer()
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(isCorrect ? Color.green : Color.red)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var checkAnswerButton: some View {
        Button(action: checkAnswer) {
            HStack {
                Spacer()
                Text("Check Answer")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(selectedAnswer.isEmpty ? Color.gray : Color.blue)
            .cornerRadius(12)
        }
        .disabled(selectedAnswer.isEmpty)
        .padding(.horizontal)
    }
    
    private var lessonCompleteView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            Text("Lesson Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You got \(correctAnswers) out of \(lesson.exercises.count) correct")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                showLessonComplete = true
            }) {
                HStack {
                    Spacer()
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .onAppear {
            lessonManager.completeLesson(lesson)
        }
    }
    
    private func checkAnswer() {
        guard let exercise = currentExercise else { return }
        
        isCorrect = selectedAnswer.lowercased() == exercise.correctAnswer.lowercased()
        if isCorrect {
            correctAnswers += 1
        }
        showResult = true
    }
    
    private func nextExercise() {
        currentExerciseIndex += 1
        selectedAnswer = ""
        showResult = false
        isCorrect = false
    }
}


#Preview {
    ExerciseView(
        lesson: Lesson(
            title: "Basic Greetings",
            description: "Learn how to greet people in Shona",
            unit: 1,
            lessonNumber: 1,
            words: [],
            phrases: [],
            exercises: [
                Exercise(type: .translation, question: "Translate: Hello", correctAnswer: "Mhoro", options: ["Mhoro", "Mangwanani", "Masikati", "Manheru"], shonaText: nil, englishText: nil, audioFileName: nil)
            ],
            xpReward: 50,
            isCompleted: false,
            isUnlocked: true
        ),
        lessonManager: LessonManager()
    )
}