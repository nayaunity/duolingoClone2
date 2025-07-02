//
//  ContentView.swift
//  duolingoClone2
//
//  Created by Nyaradzo Bere on 7/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var lessonManager = LessonManager()
    
    var body: some View {
        TabView {
            HomeView(lessonManager: lessonManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Learn")
                }
            
            ProfileView(lessonManager: lessonManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.green)
    }
}

#Preview {
    ContentView()
}
