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
    @Published var userText: String = ""
    @Published var gameWon: Bool = false
    @Published var gameLost: Bool = false
    @Published var gameRunning: Bool = false
    @Published var isTimerRunning: Bool = false
    @Published var difficulty: Difficulty = .easy {
        didSet {
            gameEngine.difficulty = difficulty
            print("Difficulty changed to: \(difficulty.rawValue)")
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
        
        // Log initialization
        print("SinglePlayerVM initialized with \(gameList.gameWords.count) words in the pool")
    }
    
    private func setupStateMachineCallbacks() {
        stateMachine.onGameStart = { [weak self] in
            guard let self = self else { return }
            self.gameRunning = true
            self.isTimerRunning = true
            self.playerLife = 3
            
            // Update the gameList.words to match what's in gameEngine
            DispatchQueue.main.async {
                self.syncGameEngineWithGameList()
            }
            
            print("Game started!")
        }
        
        stateMachine.onGamePause = { [weak self] in
            self?.isTimerRunning = false
            print("Game paused")
        }
        
        stateMachine.onGameResume = { [weak self] in
            self?.isTimerRunning = true
            print("Game resumed")
        }
        
        stateMachine.onGameWin = { [weak self] in
            self?.gameWon = true
            self?.gameRunning = false
            print("Game won!")
        }
        
        stateMachine.onGameLose = { [weak self] in
            self?.gameLost = true
            self?.gameRunning = false
            print("Game lost!")
        }
        
        stateMachine.onStateChange = { [weak self] state in
            self?.gameState = state
            print("Game state changed to: \(state.displayName)")
        }
    }
    
    private func setupSubscriptions() {
        // We'll use a simple approach for now instead of Combine
    }
    
    // Sync the game engine's words with our gameList.words for display
    private func syncGameEngineWithGameList() {
        // Clear current visible words
        gameList.words = gameEngine.words
        
        // Log the sync operation
        print("Synced game engine words (\(gameEngine.words.count)) with gameList")
    }
    
    // MARK: - Public methods (API)
    
    func testing(letter: Character) {
        let result = gameEngine.processUserInput(letter: letter)
        
        // Update UI based on result
        switch result {
        case .noMatch:
            // Handle no match case
            break
            
        case .partialMatch(_, _):
            // Update UI to show partial match
            userText = gameEngine.currentTypedWord
            
        case .completeMatch(_, _):
            // Handle completed word
            userText = ""
            
            // Check if game is won or lost
            stateMachine.checkGameStatus()
        }
        
        // Sync the game list with the engine state
        syncGameEngineWithGameList()
    }
    
    func handleBackspace() {
        gameEngine.handleBackspace()
        userText = gameEngine.currentTypedWord
    }
    
    func resetWord() {
        userText = ""
    }
    
    func restartGame() {
        // Reset game state
        gameWon = false
        gameLost = false
        userText = ""
        elapsedTime = 0.0
        score = 0
        
        // Ensure we have words in the game
        gameList.fillList()
        
        // Start the game
        stateMachine.startGame()
        
        print("Game restarted with \(gameList.gameWords.count) words in the pool")
    }
    
    func checkDead() {
        stateMachine.checkGameStatus()
        
        // Keep playerLife in sync with gameEngine's lives
        playerLife = gameEngine.lives
    }
}
