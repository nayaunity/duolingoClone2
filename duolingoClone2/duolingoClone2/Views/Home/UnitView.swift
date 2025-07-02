import SwiftUI

struct UnitView: View {
    let unit: Int
    @ObservedObject var lessonManager: LessonManager
    @State private var showLessons = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Unit Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unit \(unit)")
                        .font(.duolingoTitle)
                        .foregroundColor(.duolingoTextPrimary)
                    
                    Text(unitDescription)
                        .font(.duolingoBody)
                        .foregroundColor(.duolingoTextSecondary)
                }
                
                Spacer()
                
                // Unit progress indicator
                ZStack {
                    Circle()
                        .stroke(Color.duolingoGrayLight, lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: unitProgress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.duolingoGreen, Color.duolingoBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: unitProgress)
                    
                    Text("\(Int(unitProgress * 100))%")
                        .font(.duolingoSmall)
                        .fontWeight(.bold)
                        .foregroundColor(.duolingoTextPrimary)
                }
            }
            
            // Lesson Path
            LazyVStack(spacing: 30) {
                ForEach(Array(lessonManager.getLessonsForUnit(unit).enumerated()), id: \.element.id) { index, lesson in
                    HStack {
                        if index % 2 == 0 {
                            // Left aligned lesson
                            LessonCardView(lesson: lesson, lessonManager: lessonManager)
                            Spacer()
                        } else {
                            // Right aligned lesson
                            Spacer()
                            LessonCardView(lesson: lesson, lessonManager: lessonManager)
                        }
                    }
                    .opacity(showLessons ? 1 : 0)
                    .offset(x: showLessons ? 0 : (index % 2 == 0 ? -100 : 100))
                    .animation(.duolingoBounce.delay(Double(index) * 0.2), value: showLessons)
                    
                    // Path connector (except for last lesson)
                    if index < lessonManager.getLessonsForUnit(unit).count - 1 {
                        pathConnector
                            .opacity(showLessons ? 1 : 0)
                            .animation(.duolingoEaseInOut.delay(Double(index) * 0.2 + 0.1), value: showLessons)
                    }
                }
            }
        }
        .padding(20)
        .duolingoCard()
        .onAppear {
            withAnimation(.duolingoBounce.delay(0.3)) {
                showLessons = true
            }
        }
    }
    
    private var unitDescription: String {
        switch unit {
        case 1:
            return "Learn basic greetings and family words"
        case 2:
            return "Explore colors and everyday vocabulary"
        default:
            return "Continue your Shona journey"
        }
    }
    
    private var unitProgress: Double {
        let lessons = lessonManager.getLessonsForUnit(unit)
        guard !lessons.isEmpty else { return 0 }
        let completed = lessons.filter { $0.isCompleted }.count
        return Double(completed) / Double(lessons.count)
    }
    
    private var pathConnector: some View {
        VStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(Color.duolingoGrayMedium)
                    .frame(width: 6, height: 6)
            }
        }
    }
}