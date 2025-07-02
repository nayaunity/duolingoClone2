import SwiftUI

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