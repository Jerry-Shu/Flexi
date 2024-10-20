import SwiftUI

struct EvaluationPageView: View {
    @State private var isLoading = true
    @State private var dataReceived = false
    @State private var animationProgress: CGFloat = 0.0
    @State private var scoreText = ""
    @State private var totalScoreText = ""
    @State private var overallEvaluationText = ""
    @State private var nextLevelText = ""
    @State private var evaluationTextsArray = ["", "", "", ""]
    @State private var nextLevelIssuesArray = [(issue: String, suggestion: String)](repeating: ("", ""), count: 4)
    @State private var wellDoneText = ""
    @State private var showLoadingBar = false
    @State private var showScore = false
    @State private var showOverallEvaluation = false
    @State private var showEvaluationPoints = false
    @State private var showNextLevel = false
    @State private var evaluationTextIndex = 0
    @State private var nextLevelIssueIndex = 0

    let evaluationTexts = [
        "The individual is attempting a deadlift movement with a specialized barbell.",
        "The grip on the barbell appears correct, with hands placed outside the legs.",
        "The stance width seems appropriate for a conventional deadlift.",
        "There are significant form issues that need to be addressed for safety and effectiveness."
    ]

    let nextLevelIssues = [
        ("Rounded back", "Suggestion: Keep your back straight by engaging your core and lats."),
        ("Improper hip hinge", "Suggestion: Practice hinging at the hips while keeping your back neutral."),
        ("Lack of core engagement", "Suggestion: Brace your core before initiating the lift."),
        ("Barbell too far from body", "Suggestion: Keep the barbell close to your body throughout the lift.")
    ]

    var body: some View {
        ZStack {
            if isLoading {
                // Loading view while data is being fetched
                LoadingView()
                    .onAppear {
                        checkDataStatus()
                    }
            } else {
                // Main evaluation page view
                ScrollView {
                    VStack(alignment: .leading) {
                        // Play button at the top
                        HStack {
                            Spacer()
                            Button(action: {
                                // Add functionality here if needed
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.blue)
                                    .padding(.top, 20)
                                    .padding(.trailing, 20)
                            }
                        }

                        // Title
                        if !wellDoneText.isEmpty {
                            Text(wellDoneText)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 20)
                                .padding(.horizontal, 20)
                        }

                        if showLoadingBar {
                            Spacer().frame(height: 20)

                            // Score Circle
                            ZStack {
                                Circle()
                                    .trim(from: 0.0, to: 1.0)
                                    .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                    .frame(width: 180, height: 180)
                                    .rotationEffect(.degrees(270))

                                Circle()
                                    .trim(from: 0.0, to: animationProgress)
                                    .stroke(AngularGradient(gradient: Gradient(colors: [Color.yellow]), center: .center), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                    .frame(width: 180, height: 180)
                                    .rotationEffect(.degrees(270))
                                    .animation(.easeInOut(duration: 2.0), value: animationProgress)

                                VStack {
                                    Image(systemName: "figure.stand")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                }
                            }
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .center)

                            // Display Score below the circle
                            if showScore {
                                HStack {
                                    Text(scoreText)
                                        .font(.system(size: 50))
                                        .fontWeight(.bold)
                                        .padding(.top, 10) // Space between circle and score

                                    Text(totalScoreText)
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }

                        if showOverallEvaluation {
                            Spacer().frame(height: 30)

                            // Overall Evaluation Section
                            HStack(spacing: 10) {
                                Image(systemName: "trophy.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.yellow)
                                Text(overallEvaluationText)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 20)
                            Divider()
                                .background(Color.yellow)
                                .padding(.horizontal, 20)

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(0..<evaluationTextIndex, id: \.self) { index in
                                    EvaluationPoint(number: index + 1, text: evaluationTextsArray[index])
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        if showNextLevel {
                            Spacer().frame(height: 30)

                            // Next Level Section
                            HStack(spacing: 10) {
                                Image(systemName: "flame.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.yellow)
                                Text(nextLevelText)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 20)
                            Divider()
                                .background(Color.yellow)
                                .padding(.horizontal, 20)

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(0..<nextLevelIssueIndex, id: \.self) { index in
                                    IssuePoint(text: nextLevelIssuesArray[index].issue, suggestion: nextLevelIssuesArray[index].suggestion)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer()
                    }
                    .background(Color.white.edgesIgnoringSafeArea(.all))
                    .onAppear {
                        // Start the sequence after data is received
                        startEvaluationSequence()
                    }
                }
            }
        }
    }

    // MARK: - Check Data Status

    private func checkDataStatus() {
        // Simulate checking data from the backend every 1 second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if dataReceived {
                isLoading = false  // Stop loading when data is received
                timer.invalidate()  // Stop the timer once data is available
            } else {
                // Simulate backend data reception (replace this with real data fetching logic)
                // Here we simulate data reception after 5 seconds for demonstration purposes
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.dataReceived = true
                }
            }
        }
    }

    // MARK: - Animation Functions

    private func startEvaluationSequence() {
        typeWriterEffect(for: "Well Done!", target: $wellDoneText, perCharacterDelay: 0.01) {
            // After 'Well Done!' appears
            showLoadingBar = true
            withAnimation(.easeInOut(duration: 2.0)) {
                animationProgress = 0.65
            }
            // After loading bar animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showScore = true
                typeWriterEffect(for: "65", target: $scoreText, perCharacterDelay: 0.01) {
                    typeWriterEffect(for: "/100", target: $totalScoreText, perCharacterDelay: 0.01) {
                        showOverallEvaluation = true
                        typeWriterEffect(for: "Overall Evaluation", target: $overallEvaluationText, perCharacterDelay: 0.01) {
                            startEvaluationTextAnimation()
                        }
                    }
                }
            }
        }
    }

    private func startEvaluationTextAnimation(at index: Int = 0) {
        if index < evaluationTexts.count {
            typeWriterEffect(for: evaluationTexts[index], target: $evaluationTextsArray[index], perCharacterDelay: 0.02) {
                evaluationTextIndex = index + 1
                startEvaluationTextAnimation(at: index + 1)
            }
        } else {
            // All evaluation texts are done, proceed to 'Next Level'
            showNextLevel = true
            typeWriterEffect(for: "Next Level", target: $nextLevelText, perCharacterDelay: 0.01) {
                startNextLevelIssuesAnimation()
            }
        }
    }

    private func startNextLevelIssuesAnimation(at index: Int = 0) {
        if index < nextLevelIssues.count {
            let issue = nextLevelIssues[index].0
            let suggestion = nextLevelIssues[index].1
            typeWriterEffect(for: issue, target: Binding<String>(
                get: { self.nextLevelIssuesArray[index].issue },
                set: { self.nextLevelIssuesArray[index].issue = $0 }
            ), perCharacterDelay: 0.02) {
                typeWriterEffect(for: suggestion, target: Binding<String>(
                    get: { self.nextLevelIssuesArray[index].suggestion },
                    set: { self.nextLevelIssuesArray[index].suggestion = $0 }
                ), perCharacterDelay: 0.02) {
                    nextLevelIssueIndex = index + 1
                    startNextLevelIssuesAnimation(at: index + 1)
                }
            }
        }
    }

    // MARK: - Typewriter Effect Function

    private func typeWriterEffect(for text: String, target: Binding<String>, delayBeforeStart: Double = 0.0, perCharacterDelay: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeStart) {
            target.wrappedValue = ""
            var currentIndex = 0
            let timer = Timer.scheduledTimer(withTimeInterval: perCharacterDelay, repeats: true) { timer in
                if currentIndex < text.count {
                    let index = text.index(text.startIndex, offsetBy: currentIndex)
                    target.wrappedValue.append(text[index])
                    currentIndex += 1
                } else {
                    timer.invalidate()
                    completion()
                }
            }
            RunLoop.current.add(timer, forMode: .common)
        }
    }
}

// MARK: - Supporting Views

struct EvaluationPoint: View {
    var number: Int
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: 20, height: 20)
            Text(text)
                .font(.body)
        }
    }
}

struct IssuePoint: View {
    var text: String
    var suggestion: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                Text(text)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            Text(suggestion)
                .font(.body)
                .foregroundColor(.gray)
                .padding(.leading, 30)
        }
    }
}

struct EvaluationPageView_Previews: PreviewProvider {
    static var previews: some View {
        EvaluationPageView()
    }
}
