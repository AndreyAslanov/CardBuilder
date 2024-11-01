import Foundation

final class GameDataManager {
    static let shared = GameDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let gameKey = "gameKey"
    private let selectedCardsKey = "selectedCardsKey"
    
    // MARK: - Save a game
    func saveGame(_ game: GameModel) {
        var games = loadGames() ?? []
        if let index = games.firstIndex(where: { $0.id == game.id }) {
            games[index] = game
        } else {
            games.append(game)
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(games)
            userDefaults.set(encoded, forKey: gameKey)
        } catch {
            print("Failed to save games: \(error.localizedDescription)")
        }
    }
    
    func saveGames(_ games: [GameModel]) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(games)
            userDefaults.set(encoded, forKey: gameKey)
        } catch {
            print("Failed to save games: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load all games
    func loadGames() -> [GameModel] {
        guard let data = userDefaults.data(forKey: gameKey) else { return [] }
        do {
            return try JSONDecoder().decode([GameModel].self, from: data)
        } catch {
            print("Failed to decode games: \(error)")
            return []
        }
    }
    
    // MARK: - Load a specific game by ID
    func loadGame(withId id: UUID) -> GameModel? {
        let games = loadGames()
        return games.first { $0.id == id }
    }
    
    // MARK: - Delete a game by ID
    func deleteGame(withId id: UUID) {
        var games = loadGames() ?? []
        games.removeAll { $0.id == id }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(games)
            userDefaults.set(encoded, forKey: gameKey)
        } catch {
            print("Failed to delete game: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update a game
    func updateGame(withId id: UUID,
                    nameGame: String? = nil,
                    players: String? = nil,
                    gameTime: String? = nil,
                    rules: String? = nil,
                    cards: [Int]? = nil) {
        var games = loadGames() ?? []
        
        if let index = games.firstIndex(where: { $0.id == id }) {
            var updatedGame = games[index]
            
            if let nameGame = nameGame { updatedGame.nameGame = nameGame }
            if let players = players { updatedGame.players = players }
            if let gameTime = gameTime { updatedGame.gameTime = gameTime }
            if let rules = rules { updatedGame.rules = rules }
            if let cards = cards { updatedGame.cards = cards }
            
            games[index] = updatedGame
            saveGames(games)
            
            print("Game updated successfully.")
        } else {
            print("Game not found for update.")
        }
    }
    
    // MARK: - Delete all games
    func deleteAllGames() {
        let games: [GameModel] = []
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(games)
            userDefaults.set(encoded, forKey: gameKey)
        } catch {
            print("Failed to delete all games: \(error.localizedDescription)")
        }
    }

    // Save a selected cards
    func saveSelectedCards(_ cards: [Int]) {
        let cardsData = cards.map { String($0) }.joined(separator: ",")
        userDefaults.set(cardsData, forKey: selectedCardsKey)
    }
    
    // Load a selected cards
    func loadSelectedCards() -> [Int] {
        guard let cardsString = userDefaults.string(forKey: selectedCardsKey) else {
            return []
        }
        return cardsString.split(separator: ",").compactMap { Int($0) }
    }
}
