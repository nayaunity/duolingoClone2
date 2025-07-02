import SwiftUI

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