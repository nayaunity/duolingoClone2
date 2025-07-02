import SwiftUI

struct LessonCompleteView: View {
    let lesson: Lesson
    let correctAnswers: Int
    let totalQuestions: Int
    let lessonManager: LessonManager
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.yellow)
                
                Text("Lesson Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("You earned \(lesson.xpReward) XP!")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 12) {
                Text("Results")
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Correct Answers:")
                    Spacer()
                    Text("\(correctAnswers)/\(totalQuestions)")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Accuracy:")
                    Spacer()
                    Text("\(Int(Double(correctAnswers) / Double(totalQuestions) * 100))%")
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Button(action: onDismiss) {
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
        }
        .padding()
    }
}