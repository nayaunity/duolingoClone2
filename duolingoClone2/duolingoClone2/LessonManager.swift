import Foundation
import SwiftUI

class LessonManager: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var userProgress = UserProgress()
    
    init() {
        loadLessons()
        loadUserProgress()
        updateLessonAvailability()
    }
    
    func loadLessons() {
        lessons = createSampleLessons()
    }
    
    func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: "userProgress"),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = progress
        }
    }
    
    func saveUserProgress() {
        if let data = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(data, forKey: "userProgress")
        }
    }
    
    func completeLesson(_ lesson: Lesson) {
        userProgress.completedLessons.insert(lesson.id)
        userProgress.totalXP += lesson.xpReward
        
        updateStreak()
        unlockNextLesson(after: lesson)
        checkAchievements()
        saveUserProgress()
        updateLessonAvailability()
    }
    
    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastStudy = userProgress.lastStudyDate {
            let lastStudyDay = Calendar.current.startOfDay(for: lastStudy)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                userProgress.currentStreak += 1
            } else if daysDifference > 1 {
                userProgress.currentStreak = 1
            }
        } else {
            userProgress.currentStreak = 1
        }
        
        userProgress.longestStreak = max(userProgress.longestStreak, userProgress.currentStreak)
        userProgress.lastStudyDate = Date()
    }
    
    func unlockNextLesson(after lesson: Lesson) {
        let nextLessonNumber = lesson.lessonNumber + 1
        if let nextLesson = lessons.first(where: { $0.unit == lesson.unit && $0.lessonNumber == nextLessonNumber }) {
            userProgress.unlockedLessons.insert(nextLesson.id)
        } else if let nextUnitFirstLesson = lessons.first(where: { $0.unit == lesson.unit + 1 && $0.lessonNumber == 1 }) {
            userProgress.unlockedLessons.insert(nextUnitFirstLesson.id)
        }
    }
    
    func updateLessonAvailability() {
        for i in lessons.indices {
            lessons[i].isCompleted = userProgress.completedLessons.contains(lessons[i].id)
            lessons[i].isUnlocked = userProgress.unlockedLessons.contains(lessons[i].id) || 
                                   (lessons[i].unit == 1 && lessons[i].lessonNumber == 1)
        }
    }
    
    func checkAchievements() {
        var newAchievements: [Achievement] = []
        
        if userProgress.currentStreak >= 7 && !userProgress.achievements.contains(where: { $0.title == "Week Warrior" }) {
            newAchievements.append(Achievement(
                title: "Week Warrior",
                description: "Study for 7 days in a row",
                iconName: "flame.fill",
                xpRequired: nil,
                streakRequired: 7,
                isUnlocked: true,
                unlockedDate: Date()
            ))
        }
        
        if userProgress.totalXP >= 1000 && !userProgress.achievements.contains(where: { $0.title == "XP Master" }) {
            newAchievements.append(Achievement(
                title: "XP Master",
                description: "Earn 1000 XP",
                iconName: "star.fill",
                xpRequired: 1000,
                streakRequired: nil,
                isUnlocked: true,
                unlockedDate: Date()
            ))
        }
        
        userProgress.achievements.append(contentsOf: newAchievements)
    }
    
    func isLessonAvailable(_ lesson: Lesson) -> Bool {
        return lesson.isUnlocked || (lesson.unit == 1 && lesson.lessonNumber == 1)
    }
    
    func getLessonsForUnit(_ unit: Int) -> [Lesson] {
        return lessons.filter { $0.unit == unit }.sorted { $0.lessonNumber < $1.lessonNumber }
    }
    
    func getUnits() -> [Int] {
        return Array(Set(lessons.map { $0.unit })).sorted()
    }
}

extension LessonManager {
    func createSampleLessons() -> [Lesson] {
        let greetingsWords = [
            ShonaWord(shona: "Mhoro", english: "Hello", pronunciation: "m-HO-ro", category: .greetings, difficulty: .beginner),
            ShonaWord(shona: "Mangwanani", english: "Good morning", pronunciation: "man-gwa-NA-nee", category: .greetings, difficulty: .beginner),
            ShonaWord(shona: "Masikati", english: "Good afternoon", pronunciation: "ma-see-KA-tee", category: .greetings, difficulty: .beginner),
            ShonaWord(shona: "Manheru", english: "Good evening", pronunciation: "man-HE-ru", category: .greetings, difficulty: .beginner),
            ShonaWord(shona: "Chisarai", english: "Goodbye", pronunciation: "chee-sa-RAI", category: .greetings, difficulty: .beginner)
        ]
        
        let greetingsPhrases = [
            ShonaPhrase(shona: "Makadii?", english: "How are you?", pronunciation: "ma-ka-DEE", context: "Formal greeting", difficulty: .beginner),
            ShonaPhrase(shona: "Ndiri right", english: "I am fine", pronunciation: "n-dee-ree right", context: "Response to greeting", difficulty: .beginner),
            ShonaPhrase(shona: "Ndinonzi...", english: "My name is...", pronunciation: "n-dee-no-nzee", context: "Introducing yourself", difficulty: .beginner)
        ]
        
        let greetingsExercises = [
            Exercise(type: .translation, question: "Translate: Hello", correctAnswer: "Mhoro", options: ["Mhoro", "Mangwanani", "Masikati", "Manheru"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Mangwanani' mean?", correctAnswer: "Good morning", options: ["Good morning", "Good afternoon", "Good evening", "Hello"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .translation, question: "Translate: How are you?", correctAnswer: "Makadii?", options: ["Makadii?", "Mhoro", "Chisarai", "Ndiri right"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        let familyWords = [
            ShonaWord(shona: "Baba", english: "Father", pronunciation: "BA-ba", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Amai", english: "Mother", pronunciation: "a-MAI", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Mwana", english: "Child", pronunciation: "m-WA-na", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Mukoma", english: "Older brother", pronunciation: "mu-KO-ma", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Hanzvadzi", english: "Sister", pronunciation: "han-zva-dzee", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Sekuru", english: "Grandfather", pronunciation: "se-KU-ru", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Mbuya", english: "Grandmother", pronunciation: "m-BU-ya", category: .family, difficulty: .beginner)
        ]
        
        let familyPhrases = [
            ShonaPhrase(shona: "Mhuri yangu", english: "My family", pronunciation: "m-hu-ree ya-ngu", context: "Talking about family", difficulty: .beginner),
            ShonaPhrase(shona: "Baba vangu", english: "My father", pronunciation: "BA-ba va-ngu", context: "Referring to your father", difficulty: .beginner)
        ]
        
        let familyExercises = [
            Exercise(type: .translation, question: "Translate: Father", correctAnswer: "Baba", options: ["Baba", "Amai", "Mwana", "Sekuru"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Mbuya' mean?", correctAnswer: "Grandmother", options: ["Grandmother", "Grandfather", "Mother", "Sister"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .translation, question: "Translate: My family", correctAnswer: "Mhuri yangu", options: ["Mhuri yangu", "Baba vangu", "Amai vangu", "Mwana wangu"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        let numbersWords = [
            ShonaWord(shona: "Motsi", english: "One", pronunciation: "MO-tsee", category: .numbers, difficulty: .beginner),
            ShonaWord(shona: "Piri", english: "Two", pronunciation: "PEE-ree", category: .numbers, difficulty: .beginner),
            ShonaWord(shona: "Tatu", english: "Three", pronunciation: "TA-tu", category: .numbers, difficulty: .beginner),
            ShonaWord(shona: "China", english: "Four", pronunciation: "CHEE-na", category: .numbers, difficulty: .beginner),
            ShonaWord(shona: "Shanu", english: "Five", pronunciation: "SHA-nu", category: .numbers, difficulty: .beginner),
            ShonaWord(shona: "Tanhatu", english: "Six", pronunciation: "tan-HA-tu", category: .numbers, difficulty: .beginner),
            ShonaWord(shona: "Nomwe", english: "Seven", pronunciation: "NO-mwe", category: .numbers, difficulty: .beginner),
            ShonaWord(shona: "Sere", english: "Eight", pronunciation: "SE-re", category: .numbers, difficulty: .beginner),
            ShonaWord(shona: "Pfumbamwe", english: "Nine", pronunciation: "pfum-ba-mwe", category: .numbers, difficulty: .beginner),
            ShonaWord(shona: "Gumi", english: "Ten", pronunciation: "GU-mee", category: .numbers, difficulty: .beginner)
        ]
        
        let numbersExercises = [
            Exercise(type: .translation, question: "Translate: Five", correctAnswer: "Shanu", options: ["Shanu", "China", "Tatu", "Sere"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Gumi' mean?", correctAnswer: "Ten", options: ["Ten", "Nine", "Eight", "Seven"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .translation, question: "Translate: Three", correctAnswer: "Tatu", options: ["Tatu", "Piri", "China", "Motsi"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        let colorsWords = [
            ShonaWord(shona: "Mutema", english: "Black", pronunciation: "mu-TE-ma", category: .colors, difficulty: .beginner),
            ShonaWord(shona: "Muchena", english: "White", pronunciation: "mu-CHE-na", category: .colors, difficulty: .beginner),
            ShonaWord(shona: "Mutsvuku", english: "Red", pronunciation: "mu-tsvu-ku", category: .colors, difficulty: .beginner),
            ShonaWord(shona: "Girini", english: "Green", pronunciation: "gee-REE-nee", category: .colors, difficulty: .beginner),
            ShonaWord(shona: "Bhuruu", english: "Blue", pronunciation: "bhu-RUU", category: .colors, difficulty: .beginner),
            ShonaWord(shona: "Yero", english: "Yellow", pronunciation: "YE-ro", category: .colors, difficulty: .beginner)
        ]
        
        let colorsExercises = [
            Exercise(type: .translation, question: "Translate: Red", correctAnswer: "Mutsvuku", options: ["Mutsvuku", "Mutema", "Muchena", "Girini"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Muchena' mean?", correctAnswer: "White", options: ["White", "Black", "Blue", "Green"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        return [
            Lesson(
                title: "Basic Greetings",
                description: "Learn how to greet people in Shona",
                unit: 1,
                lessonNumber: 1,
                words: greetingsWords,
                phrases: greetingsPhrases,
                exercises: greetingsExercises,
                xpReward: 50,
                isCompleted: false,
                isUnlocked: true
            ),
            Lesson(
                title: "Family Members",
                description: "Learn words for family members",
                unit: 1,
                lessonNumber: 2,
                words: familyWords,
                phrases: familyPhrases,
                exercises: familyExercises,
                xpReward: 50,
                isCompleted: false,
                isUnlocked: false
            ),
            Lesson(
                title: "Numbers 1-10",
                description: "Learn to count from one to ten in Shona",
                unit: 1,
                lessonNumber: 3,
                words: numbersWords,
                phrases: [],
                exercises: numbersExercises,
                xpReward: 60,
                isCompleted: false,
                isUnlocked: false
            ),
            Lesson(
                title: "Colors",
                description: "Learn basic color names in Shona",
                unit: 2,
                lessonNumber: 1,
                words: colorsWords,
                phrases: [],
                exercises: colorsExercises,
                xpReward: 50,
                isCompleted: false,
                isUnlocked: false
            )
        ]
    }
}