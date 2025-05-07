import Foundation


class SinglePlayerVM: ObservableObject {
    // Engine and state machine
    private let gameEngine: GameEngine
    private let stateMachine: GameStateMachine
    
    // Published properties for UI binding
    @Published var gameState: GameState = .notStarted
    @Published var playerLife: Int = 3
    @Published var elapsedTime: Double = 0.0
    @Published var score: Int = 0
    @Published var wordsPerMinute: Double = 0.0
    @Published var gameList: WordListSinglePlayer
    //Nånting skumt med ord spawningen, allt ser ut att fungera men jag tror att gamelist.words inte fylls korrekt från gamelist.gamewords eller liknande
    @Published var userText: String = ""
    @Published var gameWon: Bool = false
    @Published var gameLost: Bool = false
    @Published var gameRunning: Bool = false
    @Published var isTimerRunning: Bool = false
    @Published var difficulty: Difficulty = .easy {
        didSet {
            gameEngine.difficulty = difficulty
        }
    }
    
    init() {
        // Initialize all stored properties first
        let initialGameList = WordListSinglePlayer()
        initialGameList.fillList()
        self.gameList = initialGameList
        
        // Create word generator with the local variable
        let wordGenerator = WordListGenerator(wordList: initialGameList)
        
        // Create game engine with local variable
        let initialDifficulty: Difficulty = .easy
        self.gameEngine = GameEngine(difficulty: initialDifficulty, wordGenerating: wordGenerator)
        
        // Create state machine with engine
        self.stateMachine = GameStateMachine(gameEngine: self.gameEngine)
        
        // Now all stored properties are initialized, we can set up callbacks
        setupStateMachineCallbacks()
        
        // Set up publisher subscriptions
        setupSubscriptions()
    }
    
    private func setupStateMachineCallbacks() {
        stateMachine.onGameStart = { [weak self] in
            self?.gameRunning = true
            self?.isTimerRunning = true
        }
        
        stateMachine.onGamePause = { [weak self] in
            self?.isTimerRunning = false
        }
        
        stateMachine.onGameResume = { [weak self] in
            self?.isTimerRunning = true
        }
        
        stateMachine.onGameWin = { [weak self] in
            self?.gameWon = true
            self?.gameRunning = false
        }
        
        stateMachine.onGameLose = { [weak self] in
            self?.gameLost = true
            self?.gameRunning = false
        }
        
        stateMachine.onStateChange = { [weak self] state in
            self?.gameState = state
        }
    }
    
    private func setupSubscriptions() {
        // Combine api??
    }
    
    // MARK: - Public methods (API)
    
    func testing(letter: Character) {
        
        let result = gameEngine.processUserInput(letter: letter)
        
        // Update UI based on result
        switch result {
        case .noMatch:
            // Handle no match case
            break
            
        case .partialMatch(let wordId, let progress):
            // Update UI to show partial match
            userText = gameEngine.currentTypedWord
            
        case .completeMatch(let wordId, let score):
            // Handle completed word
            userText = ""
            
            // Check if game is won or lost
            stateMachine.checkGameStatus()
        }
    }
    
    func handleBackspace() {

        gameEngine.handleBackspace()
        userText = gameEngine.currentTypedWord
    }
    
    func resetWord() {
        userText = ""
    }
    
    func restartGame() {
        gameWon = false
        gameLost = false
        stateMachine.startGame()
    }
    
    func addWordToGame() {
        // This is now handled internally by the game engine
    }
    
    func checkDead() {
        stateMachine.checkGameStatus()
    }
}
