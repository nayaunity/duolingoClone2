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
    @State private var shuffledExercises: [Exercise] = []
    
    init(lesson: Lesson, lessonManager: LessonManager) {
        self.lesson = lesson
        self.lessonManager = lessonManager
        
        // Initialize shuffled exercises immediately
        self._shuffledExercises = State(initialValue: lesson.exercises.map { exercise in
            exercise.withShuffledOptions()
        })
    }
    
    var currentExercise: Exercise? {
        shuffledExercises.indices.contains(currentExerciseIndex) ? shuffledExercises[currentExerciseIndex] : nil
    }
    
    var progress: Double {
        guard !shuffledExercises.isEmpty else { return 0 }
        return Double(currentExerciseIndex) / Double(shuffledExercises.count)
    }
    
    var hasCompletedAllExercises: Bool {
        return !shuffledExercises.isEmpty && currentExerciseIndex >= shuffledExercises.count
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.duolingoBackground, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if let exercise = currentExercise {
                    exerciseContentView(exercise: exercise)
                } else if hasCompletedAllExercises {
                    lessonCompleteView
                } else {
                    // This happens when there are no exercises in the lesson
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.duolingoGrayMedium)
                        
                        Text("No exercises available")
                            .font(.duolingoHeadline)
                            .foregroundColor(.duolingoTextPrimary)
                        
                        Text("This lesson doesn't have any exercises yet.")
                            .font(.duolingoBody)
                            .foregroundColor(.duolingoTextSecondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Go Back")
                                .font(.duolingoBodyBold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.duolingoBlue)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showLessonComplete) {
            LessonCompleteView(
                lesson: lesson,
                correctAnswers: correctAnswers,
                totalQuestions: shuffledExercises.count,
                lessonManager: lessonManager
            ) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // Close button
                BouncyButton(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.duolingoTextPrimary)
                        .padding(12)
                        .background(Color.duolingoCardBackground)
                        .clipShape(Circle())
                        .duolingoShadow(radius: 4, y: 2)
                }
                
                Spacer()
                
                // Progress indicator
                Text("\(currentExerciseIndex + 1)/\(shuffledExercises.count)")
                    .font(.duolingoHeadline)
                    .foregroundColor(.duolingoTextPrimary)
            }
            
            // Animated progress bar
            DuolingoProgressBar(progress: progress, height: 12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
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
        SlideInView(delay: 0) {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(isCorrect ? .duolingoGreen : .duolingoRed)
                        .scaleEffect(isCorrect ? 1.2 : 1.0)
                        .animation(.duolingoBounce, value: isCorrect)
                    
                    VStack(alignment: .leading) {
                        Text(isCorrect ? "Excellent!" : "Not quite")
                            .font(.duolingoTitle)
                            .foregroundColor(isCorrect ? .duolingoGreen : .duolingoRed)
                        
                        if !isCorrect, let exercise = currentExercise {
                            Text("Correct answer: \(exercise.correctAnswer)")
                                .font(.duolingoBody)
                                .foregroundColor(.duolingoTextSecondary)
                        }
                    }
                    
                    Spacer()
                }
                
                Button(action: nextExercise) {
                    Text("Continue")
                        .font(.duolingoBodyBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isCorrect ? Color.duolingoGreen : Color.duolingoRed)
                        .cornerRadius(16)
                        .duolingoButtonShadow(color: isCorrect ? Color.duolingoGreen.opacity(0.3) : Color.duolingoRed.opacity(0.3))
                }
                .buttonStyle(DuolingoButtonStyle(color: isCorrect ? .duolingoGreen : .duolingoRed))
            }
            .padding(24)
            .background(Color.duolingoCardBackground)
            .cornerRadius(20)
            .duolingoShadow()
            .padding(.horizontal, 20)
        }
    }
    
    private var checkAnswerButton: some View {
        Button(action: checkAnswer) {
            Text("Check Answer")
        }
        .buttonStyle(DuolingoButtonStyle(
            color: .duolingoGreen,
            isEnabled: !selectedAnswer.isEmpty
        ))
        .disabled(selectedAnswer.isEmpty)
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
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
            // Only complete the lesson if we haven't already
            if !lesson.isCompleted {
                lessonManager.completeLesson(lesson)
            }
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