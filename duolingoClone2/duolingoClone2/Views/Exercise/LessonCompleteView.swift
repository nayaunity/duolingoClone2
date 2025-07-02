import SwiftUI

struct LessonCompleteView: View {
    let lesson: Lesson
    let correctAnswers: Int
    let totalQuestions: Int
    let lessonManager: LessonManager
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    @State private var animateElements = false
    
    var accuracy: Int {
        Int(Double(correctAnswers) / Double(totalQuestions) * 100)
    }
    
    var passedLesson: Bool {
        let wrongAnswers = totalQuestions - correctAnswers
        return wrongAnswers <= 1
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: passedLesson ? 
                    [Color.duolingoYellow.opacity(0.3), Color.duolingoBackground] :
                    [Color.duolingoOrange.opacity(0.3), Color.duolingoBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Confetti (only if passed)
            if showConfetti && passedLesson {
                ConfettiView()
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    // Trophy and celebration
                    VStack(spacing: 20) {
                        Image(systemName: passedLesson ? "trophy.fill" : "arrow.clockwise.circle.fill")
                            .font(.system(size: 120))
                            .foregroundColor(passedLesson ? .duolingoYellow : .duolingoOrange)
                            .scaleEffect(animateElements ? 1.0 : 0.5)
                            .animation(.duolingoBounce.delay(0.2), value: animateElements)
                        
                        VStack(spacing: 8) {
                            Text(passedLesson ? "Lesson Complete!" : "Try Again!")
                                .font(.duolingoTitle)
                                .foregroundColor(.duolingoTextPrimary)
                                .opacity(animateElements ? 1 : 0)
                                .animation(.duolingoEaseInOut.delay(0.5), value: animateElements)
                            
                            Text(passedLesson ? "Excellent work!" : "You can only have 1 wrong answer to pass")
                                .font(.duolingoHeadline)
                                .foregroundColor(.duolingoTextSecondary)
                                .opacity(animateElements ? 1 : 0)
                                .animation(.duolingoEaseInOut.delay(0.7), value: animateElements)
                        }
                        
                        // XP earned (only if passed)
                        if passedLesson {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.duolingoYellow)
                                    .font(.title2)
                                
                                Text("+\(lesson.xpReward) XP")
                                    .font(.duolingoTitle)
                                    .foregroundColor(.duolingoOrange)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.duolingoYellow.opacity(0.2))
                            .cornerRadius(20)
                            .scaleEffect(animateElements ? 1.0 : 0.8)
                            .animation(.duolingoBounce.delay(0.9), value: animateElements)
                        }
                    }
                    
                    // Results card
                    VStack(spacing: 20) {
                        Text("Your Results")
                            .font(.duolingoHeadline)
                            .foregroundColor(.duolingoTextPrimary)
                        
                        VStack(spacing: 16) {
                            resultRow(
                                icon: "checkmark.circle.fill",
                                title: "Correct Answers",
                                value: "\(correctAnswers)/\(totalQuestions)",
                                color: .duolingoGreen
                            )
                            
                            resultRow(
                                icon: "target",
                                title: "Accuracy",
                                value: "\(accuracy)%",
                                color: accuracy >= 80 ? .duolingoGreen : accuracy >= 60 ? .duolingoYellow : .duolingoRed
                            )
                            
                            if accuracy == 100 {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.duolingoYellow)
                                    Text("Perfect Score!")
                                        .font(.duolingoBodyBold)
                                        .foregroundColor(.duolingoYellow)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(24)
                    .duolingoCard()
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 50)
                    .animation(.duolingoBounce.delay(1.1), value: animateElements)
                    
                    // Continue button
                    Button(action: onDismiss) {
                        Text(passedLesson ? "Back to Lessons" : "Try Again")
                    }
                    .buttonStyle(DuolingoButtonStyle(color: passedLesson ? .duolingoGreen : .duolingoOrange))
                    .opacity(animateElements ? 1 : 0)
                    .animation(.duolingoEaseInOut.delay(1.3), value: animateElements)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }
        }
        .onAppear {
            animateElements = true
            if passedLesson {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = true
                }
            }
        }
    }
    
    private func resultRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 30)
            
            Text(title)
                .font(.duolingoBody)
                .foregroundColor(.duolingoTextPrimary)
            
            Spacer()
            
            Text(value)
                .font(.duolingoBodyBold)
                .foregroundColor(color)
        }
    }
}
