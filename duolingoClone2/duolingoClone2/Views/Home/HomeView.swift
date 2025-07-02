import SwiftUI

struct HomeView: View {
    @ObservedObject var lessonManager: LessonManager
    @State private var showWelcomeAnimation = true
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.duolingoBackground, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        headerView
                        
                        ForEach(Array(lessonManager.getUnits().enumerated()), id: \.element) { index, unit in
                            SlideInView(delay: Double(index) * 0.1) {
                                UnitView(unit: unit, lessonManager: lessonManager)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Learn Shona")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.duolingoOrange)
                    }
                }
            }
            .navigationDestination(for: Lesson.self) { lesson in
                LessonDetailView(
                    lesson: lesson,
                    lessonManager: lessonManager,
                    onDismissToHome: {
                        navigationPath = NavigationPath()
                    }
                )
            }
        }
    }
    
    private var headerView: some View {
        ScaleInView(delay: 0.2) {
            VStack(spacing: 16) {
                // Welcome message
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back!")
                            .font(.duolingoHeadline)
                            .foregroundColor(.duolingoTextPrimary)
                        
                        Text("Ready to learn Shona?")
                            .font(.duolingoBody)
                            .foregroundColor(.duolingoTextSecondary)
                    }
                    
                    Spacer()
                    
                    // Mascot placeholder
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.duolingoGreen, Color.duolingoBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("🦉")
                                .font(.title2)
                        )
                }
                
                // Stats row
                HStack(spacing: 20) {
                    AnimatedStreakCounter(
                        streak: lessonManager.userProgress.currentStreak,
                        label: "Day streak"
                    )
                    
                    Spacer()
                    
                    AnimatedXPCounter(
                        xp: lessonManager.userProgress.totalXP,
                        label: "Total XP"
                    )
                }
            }
            .padding(20)
            .duolingoCard(shadowColor: Color.duolingoBlue.opacity(0.15))
        }
    }
}