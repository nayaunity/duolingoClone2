import SwiftUI

struct LessonCardView: View {
    let lesson: Lesson
    @ObservedObject var lessonManager: LessonManager
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: LessonDetailView(lesson: lesson, lessonManager: lessonManager)) {
            VStack(spacing: 12) {
                // Animated lesson circle
                AnimatedLessonCircle(lesson: lesson, size: 80)
                
                // Lesson title
                Text(lesson.title)
                    .font(.duolingoSubheadline)
                    .foregroundColor(.duolingoTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // XP reward badge
                if !lesson.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.duolingoYellow)
                            .font(.system(size: 12))
                        
                        Text("\(lesson.xpReward) XP")
                            .font(.duolingoSmall)
                            .foregroundColor(.duolingoTextSecondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.duolingoYellow.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .frame(width: 140, height: 160)
            .padding(16)
            .background(Color.duolingoCardBackground)
            .cornerRadius(20)
            .duolingoShadow(
                color: lesson.isCompleted ? Color.duolingoGreen.opacity(0.2) :
                       lesson.isUnlocked ? Color.duolingoBlue.opacity(0.2) :
                       Color.black.opacity(0.1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.duolingoQuick, value: isPressed)
        }
        .disabled(!lesson.isUnlocked && !lesson.isCompleted)
        .opacity(lesson.isUnlocked || lesson.isCompleted ? 1.0 : 0.6)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.duolingoQuick) {
                isPressed = pressing
            }
        }, perform: {})
    }
}