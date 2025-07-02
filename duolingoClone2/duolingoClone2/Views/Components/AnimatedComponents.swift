import SwiftUI

// MARK: - Animated Lesson Circle
struct AnimatedLessonCircle: View {
    let lesson: Lesson
    let size: CGFloat
    @State private var isAnimating = false
    @State private var showPulse = false
    
    init(lesson: Lesson, size: CGFloat = 80) {
        self.lesson = lesson
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Pulse effect for available lessons
            if lesson.isUnlocked && !lesson.isCompleted {
                Circle()
                    .stroke(Color.duolingoBlue.opacity(0.3), lineWidth: 3)
                    .scaleEffect(showPulse ? 1.3 : 1.0)
                    .opacity(showPulse ? 0 : 1)
                    .animation(
                        Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: false),
                        value: showPulse
                    )
            }
            
            // Main circle
            Circle()
                .fill(circleGradient)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: 4)
                )
                .overlay(
                    iconView
                )
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
        }
        .onAppear {
            if lesson.isUnlocked && !lesson.isCompleted {
                showPulse = true
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
    
    private var circleGradient: LinearGradient {
        if lesson.isCompleted {
            return LinearGradient(
                colors: [Color.duolingoGreen, Color.duolingoGreen.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if lesson.isUnlocked {
            return LinearGradient(
                colors: [Color.duolingoBlue, Color.duolingoPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.duolingoGrayMedium, Color.duolingoGrayLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderColor: Color {
        if lesson.isCompleted {
            return Color.white
        } else if lesson.isUnlocked {
            return Color.white.opacity(0.8)
        } else {
            return Color.duolingoGrayDark
        }
    }
    
    private var shadowColor: Color {
        if lesson.isCompleted {
            return Color.duolingoGreen.opacity(0.4)
        } else if lesson.isUnlocked {
            return Color.duolingoBlue.opacity(0.4)
        } else {
            return Color.black.opacity(0.1)
        }
    }
    
    private var iconView: some View {
        Group {
            if lesson.isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.3, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "book.fill")
                    .font(.system(size: size * 0.25, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Bouncy Button
struct BouncyButton<Content: View>: View {
    let content: Content
    let action: () -> Void
    @State private var isPressed = false
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.duolingoBounce, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.duolingoQuick) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Animated XP Counter
struct AnimatedXPCounter: View {
    let xp: Int
    let label: String
    @State private var displayedXP = 0
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .foregroundColor(.duolingoYellow)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.duolingoBounce, value: isAnimating)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(displayedXP)")
                    .font(.duolingoHeadline)
                    .foregroundColor(.duolingoTextPrimary)
                
                Text(label)
                    .font(.duolingoSmall)
                    .foregroundColor(.duolingoTextSecondary)
            }
        }
        .onAppear {
            animateCounter()
        }
        .onChange(of: xp) { _ in
            animateCounter()
        }
    }
    
    private func animateCounter() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimating = true
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if displayedXP < xp {
                displayedXP += max(1, (xp - displayedXP) / 20)
            } else {
                displayedXP = xp
                timer.invalidate()
                withAnimation(.duolingoBounce) {
                    isAnimating = false
                }
            }
        }
        timer.fire()
    }
}

// MARK: - Animated Streak Counter
struct AnimatedStreakCounter: View {
    let streak: Int
    let label: String
    @State private var flameScale: CGFloat = 1.0
    @State private var flameOpacity: Double = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            Text("🔥")
                .font(.system(size: 24))
                .scaleEffect(flameScale)
                .opacity(flameOpacity)
                .animation(
                    Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: flameScale
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streak)")
                    .font(.duolingoHeadline)
                    .foregroundColor(.duolingoTextPrimary)
                
                Text(label)
                    .font(.duolingoSmall)
                    .foregroundColor(.duolingoTextSecondary)
            }
        }
        .onAppear {
            withAnimation {
                flameScale = 1.1
                flameOpacity = 0.8
            }
        }
    }
}

// MARK: - Slide In Animation
struct SlideInView<Content: View>: View {
    let content: Content
    let delay: Double
    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0
    
    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }
    
    var body: some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.duolingoBounce.delay(delay)) {
                    offset = 0
                    opacity = 1
                }
            }
    }
}

// MARK: - Scale In Animation
struct ScaleInView<Content: View>: View {
    let content: Content
    let delay: Double
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.duolingoBounce.delay(delay)) {
                    scale = 1.0
                    opacity = 1
                }
            }
    }
}

// MARK: - Confetti Animation
struct ConfettiView: View {
    @State private var confettiParticles: [ConfettiParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiParticles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            startConfetti()
        }
    }
    
    private func startConfetti() {
        for i in 0..<50 {
            let particle = ConfettiParticle(
                id: i,
                position: CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: -20),
                color: [Color.duolingoYellow, Color.duolingoGreen, Color.duolingoBlue, Color.duolingoPink].randomElement()!,
                size: CGFloat.random(in: 4...12),
                opacity: 1.0
            )
            confettiParticles.append(particle)
            
            withAnimation(.linear(duration: Double.random(in: 2...4)).delay(Double(i) * 0.05)) {
                if let index = confettiParticles.firstIndex(where: { $0.id == particle.id }) {
                    confettiParticles[index].position.y = UIScreen.main.bounds.height + 20
                    confettiParticles[index].opacity = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            confettiParticles.removeAll()
        }
    }
}

struct ConfettiParticle {
    let id: Int
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}