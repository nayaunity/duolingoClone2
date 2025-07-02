import SwiftUI

struct LessonCardView: View {
    let lesson: Lesson
    @ObservedObject var lessonManager: LessonManager
    
    var body: some View {
        NavigationLink(destination: LessonDetailView(lesson: lesson, lessonManager: lessonManager)) {
            VStack(spacing: 8) {
                Circle()
                    .fill(lesson.isCompleted ? Color.green : (lesson.isUnlocked ? Color.blue : Color.gray))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: lesson.isCompleted ? "checkmark" : "book.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    )
                
                Text(lesson.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .disabled(!lesson.isUnlocked && !lesson.isCompleted)
        .opacity(lesson.isUnlocked || lesson.isCompleted ? 1.0 : 0.5)
    }
}