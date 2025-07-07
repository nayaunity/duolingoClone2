import SwiftUI

struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    let sampleAchievement = Achievement(
        title: "First Lesson",
        description: "Complete your first lesson",
        iconName: "star.fill",
        xpRequired: 50,
        streakRequired: nil,
        isUnlocked: true,
        unlockedDate: nil
    )
    
    AchievementCardView(achievement: sampleAchievement)
        .padding()
}