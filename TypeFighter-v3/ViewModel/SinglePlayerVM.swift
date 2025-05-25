import Foundation
import Combine

class SinglePlayerVM: ObservableObject {
    // Engine and state machine
    private let gameEngine: GameEngine
    private let stateMachine: GameStateMachine
    
    // Timer for continuous UI updates
    private var uiUpdateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
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
    private let wordGenerator: WordGenerating

    // Update the init method to store the word generator reference
    init() {
        // Initialize all stored properties first
        let initialGameList = WordListSinglePlayer()
        initialGameList.fillList()
        self.gameList = initialGameList
        
        // Create word generator and store reference
        
        //Old Swe list/Impl
        //self.wordGenerator = WordListGenerator(wordList: initialGameList)
        
        //Eng list for testing / wordgenerating
        self.wordGenerator = RandomWordGenerator(wordLimit: 15)

        
        // Create game engine with the word generator
        let initialDifficulty: Difficulty = .easy
        self.gameEngine = GameEngine(difficulty: initialDifficulty, wordGenerating: self.wordGenerator)
        
        // Create state machine with engine
        self.stateMachine = GameStateMachine(gameEngine: self.gameEngine)
        
        // Now all stored properties are initialized, we can set up callbacks
        setupStateMachineCallbacks()
        
        // Set up publisher subscriptions
        setupSubscriptions()
        
        // Start continuous UI updates
        startUIUpdateTimer()
        
        // Log initialization
        print("SinglePlayerVM initialized with \(gameList.gameWords.count) words in the pool")
    }
    
    deinit {
        stopUIUpdateTimer()
    }
    
    // Expose game engine to the falling words controller
    func getGameEngine() -> GameEngine {
        return gameEngine
    }
    
    private func setupStateMachineCallbacks() {
        stateMachine.onGameStart = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.gameRunning = true
                self.isTimerRunning = true
                self.playerLife = 3
                
                // Update the gameList.words to match what's in gameEngine
                self.syncGameEngineWithGameList()
                
                print("Game started!")
            }
        }
        
        stateMachine.onGamePause = { [weak self] in
            DispatchQueue.main.async {
                self?.isTimerRunning = false
                print("Game paused")
            }
        }
        
        stateMachine.onGameResume = { [weak self] in
            DispatchQueue.main.async {
                self?.isTimerRunning = true
                print("Game resumed")
            }
        }
        
        stateMachine.onGameWin = { [weak self] in
            DispatchQueue.main.async {
                self?.gameWon = true
                self?.gameRunning = false
                print("Game won!")
            }
        }
        
        stateMachine.onGameLose = { [weak self] in
            DispatchQueue.main.async {
                self?.gameLost = true
                self?.gameRunning = false
                print("Game lost!")
            }
        }
        
        stateMachine.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.gameState = state
                print("Game state changed to: \(state.displayName)")
            }
        }
    }
    
    private func setupSubscriptions() {
        // Subscribe to game engine changes
        gameEngine.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.syncGameEngineWithUI()
            }
            .store(in: &cancellables)
    }
    
    // CRITICAL FIX: Continuous UI update timer
    private func startUIUpdateTimer() {
        stopUIUpdateTimer()
        
        uiUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateUI()
            }
        }
        
        // Ensure timer runs on main run loop
        if let timer = uiUpdateTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopUIUpdateTimer() {
        uiUpdateTimer?.invalidate()
        uiUpdateTimer = nil
    }
    
    private func updateUI() {
        guard gameRunning else { return }
        
        // Sync all UI properties with game engine
        if elapsedTime != gameEngine.elapsedTime {
            elapsedTime = gameEngine.elapsedTime
        }
        
        if score != gameEngine.score {
            score = gameEngine.score
        }
        
        if wordsPerMinute != gameEngine.wordsPerMinute {
            wordsPerMinute = gameEngine.wordsPerMinute
        }
        
        if playerLife != gameEngine.lives {
            playerLife = gameEngine.lives
        }
        
        // Sync words
        syncGameEngineWithGameList()
    }
    
    // Sync the game engine's words with gameList.words for display
    private func syncGameEngineWithGameList() {
        // Only update if there are actual changes
        let engineWordIds = Set(gameEngine.words.map { $0.id })
        let gameListWordIds = Set(gameList.words.map { $0.id })
        
        if engineWordIds != gameListWordIds {
            gameList.words = gameEngine.words
            objectWillChange.send()
            print("Synced game engine words (\(gameEngine.words.count)) with gameList")
        }
    }
    
    // Sync UI properties with game engine
    private func syncGameEngineWithUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.elapsedTime = self.gameEngine.elapsedTime
            self.score = self.gameEngine.score
            self.wordsPerMinute = self.gameEngine.wordsPerMinute
            self.playerLife = self.gameEngine.lives
            
            self.syncGameEngineWithGameList()
        }
    }
    
    // Called when a word is missed (reached the bottom line)
    func wordMissed(wordId: UUID) {
        print("Word missed with ID: \(wordId)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // First, tell the game engine to remove the word
            self.gameEngine.removeWord(wordId)
            
            // Then explicitly decrement the lives in the game engine
            self.gameEngine.decrementLives()
            
            // Update playerLife to show in UI
            self.playerLife = self.gameEngine.lives
            
            // Sync the game list with the engine
            self.syncGameEngineWithGameList()
            
            // Check if game is over due to losing all lives
            self.checkDead()
            
            // Force UI update
            self.objectWillChange.send()
            
            print("Lives remaining: \(self.playerLife)")
        }
    }
        
    func testing(letter: Character) {
        let result = gameEngine.processUserInput(letter: letter)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update UI based on result
            switch result {
            case .noMatch:
                // Handle no match case - leave text as is
                break
                
            case .partialMatch(_, _):
                // Update UI to show partial match
                self.userText = self.gameEngine.currentTypedWord
                
            case .completeMatch(wordId: _, score: _):
                // Word completed - clear text field immediately
                self.userText = ""
                
                // Make sure the UI is updated to remove the word immediately
                self.syncGameEngineWithGameList()
                
                // Force UI refresh
                self.objectWillChange.send()
                
                // Check if game is won or lost
                self.stateMachine.checkGameStatus()
                
                return // Exit early
            }
            
            // Sync game engine with game list for non-complete matches
            self.syncGameEngineWithGameList()
        }
    }

    
    func handleBackspace() {
        gameEngine.handleBackspace()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.userText = self.gameEngine.currentTypedWord
        }
    }
    
    func resetWord() {
        DispatchQueue.main.async { [weak self] in
            self?.userText = ""
        }
    }
    
    func restartGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Reset game state
            self.gameWon = false
            self.gameLost = false
            self.userText = ""
            self.elapsedTime = 0.0
            self.score = 0
            
            // IMPORTANT: Reset the word generator pool to prevent repetition
            self.wordGenerator.resetPool()
            
            // Ensure we have words in the game
            self.gameList.fillList()
            
            // Start the game
            self.stateMachine.startGame()
            
            print("Game restarted with fresh word pool")
        }
    }
    
    func checkDead() {
        stateMachine.checkGameStatus()
        
        // Keep playerLife in sync with gameEngine's lives
        playerLife = gameEngine.lives
    }
}
