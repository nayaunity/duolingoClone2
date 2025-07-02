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
        return createAllLessons()
    }
    
    private func createAllLessons() -> [Lesson] {
        var allLessons: [Lesson] = []
        
        // Unit 1: Basics
        allLessons.append(contentsOf: createUnit1Lessons())
        
        // Unit 2: Food & Daily Life
        allLessons.append(contentsOf: createUnit2Lessons())
        
        // Unit 3: Time & Weather
        allLessons.append(contentsOf: createUnit3Lessons())
        
        // Unit 4: Actions & Verbs
        allLessons.append(contentsOf: createUnit4Lessons())
        
        // Unit 5: Places & Directions
        allLessons.append(contentsOf: createUnit5Lessons())
        
        // Unit 6: Shopping & Money
        allLessons.append(contentsOf: createUnit6Lessons())
        
        return allLessons
    }
    
    private func createUnit1Lessons() -> [Lesson] {
        // Lesson 1: Basic Greetings
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
            Exercise(type: .translation, question: "Translate: How are you?", correctAnswer: "Makadii?", options: ["Makadii?", "Mhoro", "Chisarai", "Ndiri right"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .fillInBlank, question: "Complete: Ndinonzi _____ (My name is John)", correctAnswer: "John", options: nil, shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        // Lesson 2: Family Members
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
            ShonaPhrase(shona: "Baba vangu", english: "My father", pronunciation: "BA-ba va-ngu", context: "Referring to your father", difficulty: .beginner),
            ShonaPhrase(shona: "Amai vangu", english: "My mother", pronunciation: "a-MAI va-ngu", context: "Referring to your mother", difficulty: .beginner)
        ]
        
        let familyExercises = [
            Exercise(type: .translation, question: "Translate: Father", correctAnswer: "Baba", options: ["Baba", "Amai", "Mwana", "Sekuru"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Mbuya' mean?", correctAnswer: "Grandmother", options: ["Grandmother", "Grandfather", "Mother", "Sister"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .translation, question: "Translate: My family", correctAnswer: "Mhuri yangu", options: ["Mhuri yangu", "Baba vangu", "Amai vangu", "Mwana wangu"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        // Lesson 3: Numbers 1-10
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
        
        // Lesson 4: Basic Colors
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
        
        // Lesson 5: Body Parts
        let bodyWords = [
            ShonaWord(shona: "Musoro", english: "Head", pronunciation: "mu-SO-ro", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Maziso", english: "Eyes", pronunciation: "ma-ZI-so", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Mhino", english: "Nose", pronunciation: "m-HI-no", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Muromo", english: "Mouth", pronunciation: "mu-RO-mo", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Maoko", english: "Hands", pronunciation: "ma-O-ko", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Makumbo", english: "Legs", pronunciation: "ma-KUM-bo", category: .family, difficulty: .beginner)
        ]
        
        let bodyExercises = [
            Exercise(type: .translation, question: "Translate: Head", correctAnswer: "Musoro", options: ["Musoro", "Maziso", "Mhino", "Muromo"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Maoko' mean?", correctAnswer: "Hands", options: ["Hands", "Legs", "Eyes", "Mouth"], shonaText: nil, englishText: nil, audioFileName: nil)
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
                description: "Learn to count from one to ten",
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
                description: "Learn basic color names",
                unit: 1,
                lessonNumber: 4,
                words: colorsWords,
                phrases: [],
                exercises: colorsExercises,
                xpReward: 50,
                isCompleted: false,
                isUnlocked: false
            ),
            Lesson(
                title: "Body Parts",
                description: "Learn names of body parts",
                unit: 1,
                lessonNumber: 5,
                words: bodyWords,
                phrases: [],
                exercises: bodyExercises,
                xpReward: 55,
                isCompleted: false,
                isUnlocked: false
            )
        ]
    }
    
    private func createUnit2Lessons() -> [Lesson] {
        // Lesson 1: Common Foods
        let foodWords = [
            ShonaWord(shona: "Sadza", english: "Cornmeal staple", pronunciation: "SA-dza", category: .food, difficulty: .beginner),
            ShonaWord(shona: "Nyama", english: "Meat", pronunciation: "nya-MA", category: .food, difficulty: .beginner),
            ShonaWord(shona: "Mufrinji", english: "Bread", pronunciation: "mu-FRIN-ji", category: .food, difficulty: .beginner),
            ShonaWord(shona: "Mvura", english: "Water", pronunciation: "m-VU-ra", category: .food, difficulty: .beginner),
            ShonaWord(shona: "Mukaka", english: "Milk", pronunciation: "mu-KA-ka", category: .food, difficulty: .beginner),
            ShonaWord(shona: "Mazai", english: "Eggs", pronunciation: "ma-ZAI", category: .food, difficulty: .beginner),
            ShonaWord(shona: "Miriwo", english: "Vegetables", pronunciation: "mi-RI-wo", category: .food, difficulty: .beginner)
        ]
        
        let foodPhrases = [
            ShonaPhrase(shona: "Ndinoda kudya", english: "I want to eat", pronunciation: "n-di-no-da ku-dya", context: "Expressing hunger", difficulty: .beginner),
            ShonaPhrase(shona: "Ndinoda mvura", english: "I want water", pronunciation: "n-di-no-da m-vu-ra", context: "Asking for water", difficulty: .beginner),
            ShonaPhrase(shona: "Chikafu chakanaka", english: "Good food", pronunciation: "chi-ka-fu cha-ka-na-ka", context: "Complimenting food", difficulty: .beginner)
        ]
        
        let foodExercises = [
            Exercise(type: .translation, question: "Translate: Water", correctAnswer: "Mvura", options: ["Mvura", "Mukaka", "Sadza", "Nyama"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What is 'Sadza'?", correctAnswer: "Cornmeal staple", options: ["Cornmeal staple", "Meat", "Water", "Bread"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .fillInBlank, question: "Complete: Ndinoda _____ (I want water)", correctAnswer: "mvura", options: nil, shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        // Lesson 2: Household Items
        let householdWords = [
            ShonaWord(shona: "Imba", english: "House", pronunciation: "IM-ba", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Kamuri", english: "Room", pronunciation: "ka-MU-ri", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Mubhedi", english: "Bed", pronunciation: "mu-BHE-di", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Tafura", english: "Table", pronunciation: "ta-FU-ra", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Chigaro", english: "Chair", pronunciation: "chi-GA-ro", category: .family, difficulty: .beginner),
            ShonaWord(shona: "Musuwo", english: "Door", pronunciation: "mu-SU-wo", category: .family, difficulty: .beginner)
        ]
        
        let householdExercises = [
            Exercise(type: .translation, question: "Translate: House", correctAnswer: "Imba", options: ["Imba", "Kamuri", "Tafura", "Chigaro"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Mubhedi' mean?", correctAnswer: "Bed", options: ["Bed", "Table", "Chair", "Door"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        // Lesson 3: Clothing
        let clothingWords = [
            ShonaWord(shona: "Shangu", english: "Shoes", pronunciation: "SHA-ngu", category: .clothing, difficulty: .beginner),
            ShonaWord(shona: "Hembe", english: "Shirt", pronunciation: "HEM-be", category: .clothing, difficulty: .beginner),
            ShonaWord(shona: "Dhirezi", english: "Dress", pronunciation: "dhi-RE-zi", category: .clothing, difficulty: .beginner),
            ShonaWord(shona: "Bhurukwa", english: "Trousers", pronunciation: "bhu-RU-kwa", category: .clothing, difficulty: .beginner),
            ShonaWord(shona: "Nguo", english: "Clothes", pronunciation: "n-GUO", category: .clothing, difficulty: .beginner)
        ]
        
        let clothingExercises = [
            Exercise(type: .translation, question: "Translate: Shoes", correctAnswer: "Shangu", options: ["Shangu", "Hembe", "Dhirezi", "Bhurukwa"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Nguo' mean?", correctAnswer: "Clothes", options: ["Clothes", "Shoes", "Shirt", "Dress"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        return [
            Lesson(
                title: "Common Foods",
                description: "Learn names of everyday foods",
                unit: 2,
                lessonNumber: 1,
                words: foodWords,
                phrases: foodPhrases,
                exercises: foodExercises,
                xpReward: 60,
                isCompleted: false,
                isUnlocked: false
            ),
            Lesson(
                title: "Household Items",
                description: "Learn words for things around the house",
                unit: 2,
                lessonNumber: 2,
                words: householdWords,
                phrases: [],
                exercises: householdExercises,
                xpReward: 55,
                isCompleted: false,
                isUnlocked: false
            ),
            Lesson(
                title: "Clothing",
                description: "Learn names of clothing items",
                unit: 2,
                lessonNumber: 3,
                words: clothingWords,
                phrases: [],
                exercises: clothingExercises,
                xpReward: 55,
                isCompleted: false,
                isUnlocked: false
            )
        ]
    }
    
    private func createUnit3Lessons() -> [Lesson] {
        // Lesson 1: Days and Time
        let timeWords = [
            ShonaWord(shona: "Zuva", english: "Day", pronunciation: "ZU-va", category: .time, difficulty: .intermediate),
            ShonaWord(shona: "Svondo", english: "Week", pronunciation: "s-VON-do", category: .time, difficulty: .intermediate),
            ShonaWord(shona: "Mwedzi", english: "Month", pronunciation: "m-WE-dzi", category: .time, difficulty: .intermediate),
            ShonaWord(shona: "Gore", english: "Year", pronunciation: "GO-re", category: .time, difficulty: .intermediate),
            ShonaWord(shona: "Mangwanani", english: "Morning", pronunciation: "man-gwa-NA-ni", category: .time, difficulty: .intermediate),
            ShonaWord(shona: "Masikati", english: "Afternoon", pronunciation: "ma-si-KA-ti", category: .time, difficulty: .intermediate),
            ShonaWord(shona: "Manheru", english: "Evening", pronunciation: "man-HE-ru", category: .time, difficulty: .intermediate)
        ]
        
        let timePhrases = [
            ShonaPhrase(shona: "Chii chinguva?", english: "What time is it?", pronunciation: "chii chi-n-gu-va", context: "Asking for time", difficulty: .intermediate),
            ShonaPhrase(shona: "Zuva rino", english: "Today", pronunciation: "zu-va ri-no", context: "Referring to today", difficulty: .intermediate),
            ShonaPhrase(shona: "Mangwana", english: "Tomorrow", pronunciation: "man-gwa-na", context: "Referring to tomorrow", difficulty: .intermediate)
        ]
        
        let timeExercises = [
            Exercise(type: .translation, question: "Translate: Day", correctAnswer: "Zuva", options: ["Zuva", "Svondo", "Mwedzi", "Gore"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Mwedzi' mean?", correctAnswer: "Month", options: ["Month", "Week", "Year", "Day"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .fillInBlank, question: "Complete: _____ rino (Today)", correctAnswer: "Zuva", options: nil, shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        // Lesson 2: Weather
        let weatherWords = [
            ShonaWord(shona: "Mvura", english: "Rain", pronunciation: "m-VU-ra", category: .weather, difficulty: .intermediate),
            ShonaWord(shona: "Zuva", english: "Sun", pronunciation: "ZU-va", category: .weather, difficulty: .intermediate),
            ShonaWord(shona: "Mhepo", english: "Wind", pronunciation: "m-HE-po", category: .weather, difficulty: .intermediate),
            ShonaWord(shona: "Shando", english: "Cold", pronunciation: "SHAN-do", category: .weather, difficulty: .intermediate),
            ShonaWord(shona: "Kupisa", english: "Hot", pronunciation: "ku-PI-sa", category: .weather, difficulty: .intermediate),
            ShonaWord(shona: "Makore", english: "Clouds", pronunciation: "ma-KO-re", category: .weather, difficulty: .intermediate)
        ]
        
        let weatherPhrases = [
            ShonaPhrase(shona: "Mvura inonaya", english: "It is raining", pronunciation: "m-vu-ra i-no-na-ya", context: "Describing rain", difficulty: .intermediate),
            ShonaPhrase(shona: "Kunotonhora", english: "It is cold", pronunciation: "ku-no-to-nho-ra", context: "Describing cold weather", difficulty: .intermediate),
            ShonaPhrase(shona: "Kunopisa", english: "It is hot", pronunciation: "ku-no-pi-sa", context: "Describing hot weather", difficulty: .intermediate)
        ]
        
        let weatherExercises = [
            Exercise(type: .translation, question: "Translate: Rain", correctAnswer: "Mvura", options: ["Mvura", "Zuva", "Mhepo", "Shando"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Kupisa' mean?", correctAnswer: "Hot", options: ["Hot", "Cold", "Wind", "Rain"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .translation, question: "Translate: It is raining", correctAnswer: "Mvura inonaya", options: ["Mvura inonaya", "Kunotonhora", "Kunopisa", "Mhepo inovhuvhuta"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        return [
            Lesson(
                title: "Time & Days",
                description: "Learn about time and days of the week",
                unit: 3,
                lessonNumber: 1,
                words: timeWords,
                phrases: timePhrases,
                exercises: timeExercises,
                xpReward: 65,
                isCompleted: false,
                isUnlocked: false
            ),
            Lesson(
                title: "Weather",
                description: "Learn to describe the weather",
                unit: 3,
                lessonNumber: 2,
                words: weatherWords,
                phrases: weatherPhrases,
                exercises: weatherExercises,
                xpReward: 65,
                isCompleted: false,
                isUnlocked: false
            )
        ]
    }
    
    private func createUnit4Lessons() -> [Lesson] {
        // Lesson 1: Common Verbs
        let verbWords = [
            ShonaWord(shona: "Kudya", english: "To eat", pronunciation: "ku-DYA", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kunwa", english: "To drink", pronunciation: "ku-NWA", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kufamba", english: "To walk", pronunciation: "ku-FAM-ba", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kumira", english: "To stand", pronunciation: "ku-MI-ra", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kugara", english: "To sit", pronunciation: "ku-GA-ra", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kurara", english: "To sleep", pronunciation: "ku-RA-ra", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kuona", english: "To see", pronunciation: "ku-O-na", category: .family, difficulty: .intermediate)
        ]
        
        let verbPhrases = [
            ShonaPhrase(shona: "Ndinoda kudya", english: "I want to eat", pronunciation: "n-di-no-da ku-dya", context: "Expressing desire to eat", difficulty: .intermediate),
            ShonaPhrase(shona: "Ndiri kufamba", english: "I am walking", pronunciation: "n-di-ri ku-fam-ba", context: "Present continuous action", difficulty: .intermediate),
            ShonaPhrase(shona: "Ndinoona", english: "I see", pronunciation: "n-di-no-o-na", context: "Present action", difficulty: .intermediate)
        ]
        
        let verbExercises = [
            Exercise(type: .translation, question: "Translate: To eat", correctAnswer: "Kudya", options: ["Kudya", "Kunwa", "Kufamba", "Kumira"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Kurara' mean?", correctAnswer: "To sleep", options: ["To sleep", "To sit", "To stand", "To walk"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .fillInBlank, question: "Complete: Ndinoda _____ (I want to eat)", correctAnswer: "kudya", options: nil, shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        // Lesson 2: Daily Activities
        let activityWords = [
            ShonaWord(shona: "Kushanda", english: "To work", pronunciation: "ku-SHAN-da", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kuenda", english: "To go", pronunciation: "ku-EN-da", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kuuya", english: "To come", pronunciation: "ku-U-ya", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kutamba", english: "To play", pronunciation: "ku-TAM-ba", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kuverenga", english: "To read", pronunciation: "ku-ve-REN-ga", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kunyora", english: "To write", pronunciation: "ku-nyo-RA", category: .family, difficulty: .intermediate)
        ]
        
        let activityPhrases = [
            ShonaPhrase(shona: "Ndiri kuenda kushanda", english: "I am going to work", pronunciation: "n-di-ri ku-en-da ku-shan-da", context: "Daily routine", difficulty: .intermediate),
            ShonaPhrase(shona: "Ndinotamba neball", english: "I play football", pronunciation: "n-di-no-tam-ba ne-ball", context: "Talking about hobbies", difficulty: .intermediate)
        ]
        
        let activityExercises = [
            Exercise(type: .translation, question: "Translate: To work", correctAnswer: "Kushanda", options: ["Kushanda", "Kuenda", "Kuuya", "Kutamba"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Kuverenga' mean?", correctAnswer: "To read", options: ["To read", "To write", "To play", "To work"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        return [
            Lesson(
                title: "Common Verbs",
                description: "Learn essential action words",
                unit: 4,
                lessonNumber: 1,
                words: verbWords,
                phrases: verbPhrases,
                exercises: verbExercises,
                xpReward: 70,
                isCompleted: false,
                isUnlocked: false
            ),
            Lesson(
                title: "Daily Activities",
                description: "Learn about everyday actions",
                unit: 4,
                lessonNumber: 2,
                words: activityWords,
                phrases: activityPhrases,
                exercises: activityExercises,
                xpReward: 70,
                isCompleted: false,
                isUnlocked: false
            )
        ]
    }
    
    private func createUnit5Lessons() -> [Lesson] {
        // Lesson 1: Places
        let placeWords = [
            ShonaWord(shona: "Chitoro", english: "Shop/Store", pronunciation: "chi-TO-ro", category: .transportation, difficulty: .intermediate),
            ShonaWord(shona: "Chipatara", english: "Hospital", pronunciation: "chi-pa-TA-ra", category: .transportation, difficulty: .intermediate),
            ShonaWord(shona: "Chikoro", english: "School", pronunciation: "chi-KO-ro", category: .transportation, difficulty: .intermediate),
            ShonaWord(shona: "Machira", english: "Market", pronunciation: "ma-CHI-ra", category: .transportation, difficulty: .intermediate),
            ShonaWord(shona: "Bhazi", english: "Bus", pronunciation: "BHA-zi", category: .transportation, difficulty: .intermediate),
            ShonaWord(shona: "Motokari", english: "Car", pronunciation: "mo-to-KA-ri", category: .transportation, difficulty: .intermediate)
        ]
        
        let placePhrases = [
            ShonaPhrase(shona: "Ndiri kuenda kuchitoro", english: "I am going to the shop", pronunciation: "n-di-ri ku-en-da ku-chi-to-ro", context: "Going somewhere", difficulty: .intermediate),
            ShonaPhrase(shona: "Kune chikoro kupi?", english: "Where is the school?", pronunciation: "ku-ne chi-ko-ro ku-pi", context: "Asking for directions", difficulty: .intermediate)
        ]
        
        let placeExercises = [
            Exercise(type: .translation, question: "Translate: Shop", correctAnswer: "Chitoro", options: ["Chitoro", "Chipatara", "Chikoro", "Machira"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Chipatara' mean?", correctAnswer: "Hospital", options: ["Hospital", "School", "Market", "Shop"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .fillInBlank, question: "Complete: Ndiri kuenda ku_____ (I am going to the shop)", correctAnswer: "chitoro", options: nil, shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        return [
            Lesson(
                title: "Places & Transport",
                description: "Learn about places and transportation",
                unit: 5,
                lessonNumber: 1,
                words: placeWords,
                phrases: placePhrases,
                exercises: placeExercises,
                xpReward: 75,
                isCompleted: false,
                isUnlocked: false
            )
        ]
    }
    
    private func createUnit6Lessons() -> [Lesson] {
        // Lesson 1: Shopping & Money
        let moneyWords = [
            ShonaWord(shona: "Mari", english: "Money", pronunciation: "MA-ri", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kutenga", english: "To buy", pronunciation: "ku-TEN-ga", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kutengesa", english: "To sell", pronunciation: "ku-ten-GE-sa", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Mutengo", english: "Price", pronunciation: "mu-TEN-go", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Chinhu", english: "Thing/Item", pronunciation: "CHI-nhu", category: .family, difficulty: .intermediate),
            ShonaWord(shona: "Kukwira", english: "Expensive", pronunciation: "ku-KWI-ra", category: .family, difficulty: .intermediate)
        ]
        
        let moneyPhrases = [
            ShonaPhrase(shona: "Mutengo unosvika sei?", english: "How much does it cost?", pronunciation: "mu-ten-go u-no-svi-ka sei", context: "Asking about price", difficulty: .intermediate),
            ShonaPhrase(shona: "Ndinoda kutenga", english: "I want to buy", pronunciation: "n-di-no-da ku-ten-ga", context: "Shopping", difficulty: .intermediate),
            ShonaPhrase(shona: "Hazvina mari", english: "I don't have money", pronunciation: "ha-zvi-na ma-ri", context: "No money", difficulty: .intermediate)
        ]
        
        let moneyExercises = [
            Exercise(type: .translation, question: "Translate: Money", correctAnswer: "Mari", options: ["Mari", "Mutengo", "Chinhu", "Kutenga"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .multipleChoice, question: "What does 'Kutenga' mean?", correctAnswer: "To buy", options: ["To buy", "To sell", "Money", "Price"], shonaText: nil, englishText: nil, audioFileName: nil),
            Exercise(type: .translation, question: "Translate: How much does it cost?", correctAnswer: "Mutengo unosvika sei?", options: ["Mutengo unosvika sei?", "Ndinoda kutenga", "Hazvina mari", "Chinhu chakanaka"], shonaText: nil, englishText: nil, audioFileName: nil)
        ]
        
        return [
            Lesson(
                title: "Shopping & Money",
                description: "Learn about buying and selling",
                unit: 6,
                lessonNumber: 1,
                words: moneyWords,
                phrases: moneyPhrases,
                exercises: moneyExercises,
                xpReward: 80,
                isCompleted: false,
                isUnlocked: false
            )
        ]
    }
}