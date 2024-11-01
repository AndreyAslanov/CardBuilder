import Foundation

final class StatisticsDataManager {
    static let shared = StatisticsDataManager()
    private let userDefaultsKey = "statisticsData"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func saveStatistic(_ statistic: StatisticsModel) {
        do {
            let data = try encoder.encode(statistic)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save statistic: \(error)")
        }
    }
    
    func loadStatistic() -> StatisticsModel? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return nil
        }
        
        do {
            let statistic = try decoder.decode(StatisticsModel.self, from: data)
            return statistic
        } catch {
            print("Failed to load statistic: \(error)")
            return nil
        }
    }
    
    func deleteStatistic() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func updateStatistic(_ updatedStatistic: StatisticsModel) {
        saveStatistic(updatedStatistic)  
    }
    
    func clearStatistic() {
        deleteStatistic()
    }
}
