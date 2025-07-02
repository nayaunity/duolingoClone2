import SwiftUI

class NavigationCoordinator: ObservableObject {
    @Published var selectedLesson: Lesson?
    @Published var showingExercise = false
    @Published var showingLessonDetail = false
    
    func startLesson(_ lesson: Lesson) {
        selectedLesson = lesson
        showingLessonDetail = false
        showingExercise = true
    }
    
    func finishLesson() {
        showingExercise = false
        showingLessonDetail = false
        selectedLesson = nil
    }
    
    func goToLessonDetail(_ lesson: Lesson) {
        selectedLesson = lesson
        showingLessonDetail = true
    }
    
    func dismissToHome() {
        showingExercise = false
        showingLessonDetail = false
        selectedLesson = nil
    }
}