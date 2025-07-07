import SwiftUI

struct ProfileView: View {
    @ObservedObject var lessonManager: LessonManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeaderView
                    
                    statsView
                    
                    achievementsView
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var profileHeaderView: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 80, height: 80)
                .overlay(
                    Text("👤")
                        .font(.largeTitle)
                )
            
            Text("Shona Learner")
                .font(.title2)
                .fontWeight(.bold)
        }
    }
    
    private var statsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title3)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                StatRowView(icon: "⭐", title: "Total XP", value: "\(lessonManager.userProgress.totalXP)")
                StatRowView(icon: "🔥", title: "Current Streak", value: "\(lessonManager.userProgress.currentStreak) days")
                StatRowView(icon: "🏆", title: "Longest Streak", value: "\(lessonManager.userProgress.longestStreak) days")
                StatRowView(icon: "📚", title: "Lessons Completed", value: "\(lessonManager.userProgress.completedLessons.count)")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var achievementsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.title3)
                .fontWeight(.bold)
            
            if lessonManager.userProgress.achievements.isEmpty {
                Text("Complete lessons to unlock achievements!")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(lessonManager.userProgress.achievements) { achievement in
                        AchievementCardView(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView(lessonManager: LessonManager())
}