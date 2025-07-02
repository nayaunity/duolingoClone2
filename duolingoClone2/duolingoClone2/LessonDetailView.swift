import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @ObservedObject var lessonManager: LessonManager
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
        NavigationLink(destination: ExerciseView(lesson: lesson, lessonManager: lessonManager)) {
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

struct WordCardView: View {
    let word: ShonaWord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.shona)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(word.english)
                    .font(.body)
                    .foregroundColor(.secondary)
                Text(word.pronunciation)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.blue)
            }
            Spacer()
            
            VStack {
                Image(systemName: "speaker.2.fill")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        // TODO: Add audio playback
                    }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct PhraseCardView: View {
    let phrase: ShonaPhrase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(phrase.shona)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(phrase.english)
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text(phrase.pronunciation)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.blue)
                }
                Spacer()
                
                Image(systemName: "speaker.2.fill")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        // TODO: Add audio playback
                    }
            }
            
            Text(phrase.context)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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
            lessonManager: LessonManager()
        )
    }
}