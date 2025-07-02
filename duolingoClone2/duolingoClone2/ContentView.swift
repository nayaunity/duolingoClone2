//
//  ContentView.swift
//  duolingoClone2
//
//  Created by Nyaradzo Bere on 7/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var lessonManager = LessonManager()
    
    var body: some View {
        TabView {
            HomeView(lessonManager: lessonManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Learn")
                }
            
            ProfileView(lessonManager: lessonManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.green)
    }
}

struct HomeView: View {
    @ObservedObject var lessonManager: LessonManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    
                    ForEach(lessonManager.getUnits(), id: \.self) { unit in
                        UnitView(unit: unit, lessonManager: lessonManager)
                    }
                }
                .padding()
            }
            .navigationTitle("Learn Shona")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("🔥 \(lessonManager.userProgress.currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("⭐ \(lessonManager.userProgress.totalXP)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct UnitView: View {
    let unit: Int
    @ObservedObject var lessonManager: LessonManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unit \(unit)")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(lessonManager.getLessonsForUnit(unit)) { lesson in
                    LessonCardView(lesson: lesson, lessonManager: lessonManager)
                }
            }
            .padding(.horizontal)
        }
    }
}

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

struct StatRowView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            Text(title)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
}

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
    ContentView()
}
