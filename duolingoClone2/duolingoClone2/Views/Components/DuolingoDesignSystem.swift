import SwiftUI

// MARK: - Duolingo Colors
extension Color {
    static let duolingoGreen = Color(red: 88/255, green: 204/255, blue: 2/255)
    static let duolingoBlue = Color(red: 28/255, green: 176/255, blue: 246/255)
    static let duolingoRed = Color(red: 255/255, green: 77/255, blue: 77/255)
    static let duolingoYellow = Color(red: 255/255, green: 205/255, blue: 0/255)
    static let duolingoOrange = Color(red: 255/255, green: 154/255, blue: 0/255)
    static let duolingoPurple = Color(red: 206/255, green: 113/255, blue: 244/255)
    static let duolingoPink = Color(red: 255/255, green: 133/255, blue: 198/255)
    
    // Background colors
    static let duolingoBackground = Color(red: 235/255, green: 243/255, blue: 255/255)
    static let duolingoCardBackground = Color.white
    static let duolingoGrayLight = Color(red: 247/255, green: 247/255, blue: 247/255)
    static let duolingoGrayMedium = Color(red: 189/255, green: 189/255, blue: 189/255)
    static let duolingoGrayDark = Color(red: 119/255, green: 119/255, blue: 119/255)
    
    // Text colors
    static let duolingoTextPrimary = Color(red: 58/255, green: 67/255, blue: 84/255)
    static let duolingoTextSecondary = Color(red: 119/255, green: 119/255, blue: 119/255)
}

// MARK: - Duolingo Fonts
extension Font {
    static let duolingoTitle = Font.custom("Nunito", size: 28).weight(.bold)
    static let duolingoHeadline = Font.custom("Nunito", size: 20).weight(.bold)
    static let duolingoSubheadline = Font.custom("Nunito", size: 16).weight(.semibold)
    static let duolingoBody = Font.custom("Nunito", size: 16).weight(.regular)
    static let duolingoBodyBold = Font.custom("Nunito", size: 16).weight(.bold)
    static let duolingoCaption = Font.custom("Nunito", size: 14).weight(.medium)
    static let duolingoSmall = Font.custom("Nunito", size: 12).weight(.regular)
}

// MARK: - Duolingo Button Styles
struct DuolingoButtonStyle: ButtonStyle {
    let color: Color
    let textColor: Color
    let isEnabled: Bool
    
    init(color: Color = .duolingoGreen, textColor: Color = .white, isEnabled: Bool = true) {
        self.color = color
        self.textColor = textColor
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.duolingoBodyBold)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled ? color : Color.duolingoGrayMedium)
                    .shadow(
                        color: isEnabled ? color.opacity(0.3) : Color.clear,
                        radius: configuration.isPressed ? 2 : 6,
                        x: 0,
                        y: configuration.isPressed ? 2 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DuolingoOptionButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isCorrect: Bool?
    let isIncorrect: Bool?
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.duolingoBody)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .stroke(borderColor, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect, isCorrect {
            return Color.duolingoGreen.opacity(0.1)
        } else if let isIncorrect = isIncorrect, isIncorrect {
            return Color.duolingoRed.opacity(0.1)
        } else if isSelected {
            return Color.duolingoBlue.opacity(0.1)
        } else {
            return Color.duolingoCardBackground
        }
    }
    
    private var borderColor: Color {
        if let isCorrect = isCorrect, isCorrect {
            return Color.duolingoGreen
        } else if let isIncorrect = isIncorrect, isIncorrect {
            return Color.duolingoRed
        } else if isSelected {
            return Color.duolingoBlue
        } else {
            return Color.duolingoGrayLight
        }
    }
    
    private var foregroundColor: Color {
        if let isCorrect = isCorrect, isCorrect {
            return Color.duolingoGreen
        } else if let isIncorrect = isIncorrect, isIncorrect {
            return Color.duolingoRed
        } else {
            return Color.duolingoTextPrimary
        }
    }
}

// MARK: - Duolingo Card Style
struct DuolingoCardStyle: ViewModifier {
    let shadowColor: Color
    
    init(shadowColor: Color = Color.black.opacity(0.1)) {
        self.shadowColor = shadowColor
    }
    
    func body(content: Content) -> some View {
        content
            .background(Color.duolingoCardBackground)
            .cornerRadius(16)
            .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
    }
}

extension View {
    func duolingoCard(shadowColor: Color = Color.black.opacity(0.1)) -> some View {
        modifier(DuolingoCardStyle(shadowColor: shadowColor))
    }
}

// MARK: - Duolingo Progress Bar
struct DuolingoProgressBar: View {
    let progress: Double
    let height: CGFloat
    
    init(progress: Double, height: CGFloat = 16) {
        self.progress = progress
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.duolingoGrayLight)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [Color.duolingoGreen, Color.duolingoBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Duolingo Animations
extension Animation {
    static let duolingoBounce = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    static let duolingoEaseInOut = Animation.easeInOut(duration: 0.3)
    static let duolingoQuick = Animation.easeInOut(duration: 0.15)
}

// MARK: - Duolingo Shadow Styles
extension View {
    func duolingoShadow(color: Color = Color.black.opacity(0.1), radius: CGFloat = 8, x: CGFloat = 0, y: CGFloat = 4) -> some View {
        self.shadow(color: color, radius: radius, x: x, y: y)
    }
    
    func duolingoButtonShadow(color: Color = Color.duolingoGreen.opacity(0.3)) -> some View {
        self.shadow(color: color, radius: 6, x: 0, y: 4)
    }
}