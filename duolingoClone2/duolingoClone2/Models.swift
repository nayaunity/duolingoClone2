import Foundation

struct ShonaWord: Codable, Identifiable {
    let id = UUID()
    let shona: String
    let english: String
    let pronunciation: String
    let category: WordCategory
    let difficulty: DifficultyLevel
}

struct ShonaPhrase: Codable, Identifiable {
    let id = UUID()
    let shona: String
    let english: String
    let pronunciation: String
    let context: String
    let difficulty: DifficultyLevel
}

struct Lesson: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let unit: Int
    let lessonNumber: Int
    let words: [ShonaWord]
    let phrases: [ShonaPhrase]
    let exercises: [Exercise]
    let xpReward: Int
    var isCompleted: Bool = false
    var isUnlocked: Bool = false
}

struct Exercise: Codable, Identifiable {
    let id = UUID()
    let type: ExerciseType
    let question: String
    let correctAnswer: String
    let options: [String]?
    let shonaText: String?
    let englishText: String?
    let audioFileName: String?
}

struct UserProgress: Codable {
    var totalXP: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var completedLessons: Set<UUID> = []
    var unlockedLessons: Set<UUID> = []
    var lastStudyDate: Date?
    var achievements: [Achievement] = []
}

struct Achievement: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let xpRequired: Int?
    let streakRequired: Int?
    var isUnlocked: Bool = false
    let unlockedDate: Date?
}

enum WordCategory: String, CaseIterable, Codable {
    case greetings = "Greetings"
    case family = "Family"
    case food = "Food"
    case colors = "Colors"
    case numbers = "Numbers"
    case animals = "Animals"
    case clothing = "Clothing"
    case transportation = "Transportation"
    case time = "Time"
    case weather = "Weather"
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum ExerciseType: String, CaseIterable, Codable {
    case translation = "Translation"
    case multipleChoice = "Multiple Choice"
    case fillInBlank = "Fill in the Blank"
    case matchPairs = "Match Pairs"
    case listenAndRepeat = "Listen and Repeat"
}