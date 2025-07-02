import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @ObservedObject var lessonManager: LessonManager
    let onDismissToHome: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                
                if !lesson.words.isEmpty {
                    vocabularySection
                }
                
                if !lesson.phrases.isEmpty {
                    phrasesSection
                }
                
                startLessonButton
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Unit \(lesson.unit) • Lesson \(lesson.lessonNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lesson.description)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("⭐ \(lesson.xpReward) XP")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            if lesson.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var vocabularySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vocabulary")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(lesson.words) { word in
                    WordCardView(word: word)
                }
            }
        }
    }
    
    private var phrasesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Phrases")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(lesson.phrases) { phrase in
                    PhraseCardView(phrase: phrase)
                }
            }
        }
    }
    
    private var startLessonButton: some View {
        NavigationLink(destination: ExerciseView(lesson: lesson, lessonManager: lessonManager, onDismissToHome: onDismissToHome)) {
            HStack {
                Spacer()
                Text(lesson.isCompleted ? "Practice Again" : "Start Lesson")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.green)
            .cornerRadius(12)
        }
        .disabled(!lesson.isUnlocked && !lesson.isCompleted)
    }
}


#Preview {
    NavigationView {
        LessonDetailView(
            lesson: Lesson(
                title: "Basic Greetings",
                description: "Learn how to greet people in Shona",
                unit: 1,
                lessonNumber: 1,
                words: [
                    ShonaWord(shona: "Mhoro", english: "Hello", pronunciation: "m-HO-ro", category: .greetings, difficulty: .beginner)
                ],
                phrases: [
                    ShonaPhrase(shona: "Makadii?", english: "How are you?", pronunciation: "ma-ka-DEE", context: "Formal greeting", difficulty: .beginner)
                ],
                exercises: [],
                xpReward: 50,
                isCompleted: false,
                isUnlocked: true
            ),
            lessonManager: LessonManager(),
            onDismissToHome: {}
        )
    }
}