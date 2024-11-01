import SnapKit
import UIKit

final class StatisticsViewController: UIViewController {
    private let statisticsLabel = UILabel()
    
    private let winsView = StatisticsView(type: .wins)
    private let defeatsView = StatisticsView(type: .defeats)
    private let hoursView = StatisticsView(type: .hours)
    private let gameView = StatisticsView(type: .game)
    
    private let editButton = UIButton()
    var updatedStatModel: StatisticsModel?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.black
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        view.backgroundColor = UIColor(hex: "#1F1F1F")

        drawself()
        
        if let model = StatisticsDataManager.shared.loadStatistic() {
            updatedStatModel = model
            winsView.updateValue(with: model.wins)
            defeatsView.updateValue(with: model.defeats)
            hoursView.updateValue(with: model.hours)
            gameView.updateValue(with: model.game)
        } else {
            print("No model found")
        }
    }

    private func drawself() {
        statisticsLabel.do { make in
            make.text = L.statistics()
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textColor = UIColor(hex: "#00913E")
            make.textAlignment = .left
        }
        
        editButton.do { make in
            make.setTitle(L.edit(), for: .normal)
            make.backgroundColor = UIColor(hex: "#01D451")
            make.layer.cornerRadius = 12
            make.clipsToBounds = true
            make.setTitleColor(UIColor(hex: "#232323"), for: .normal)
            make.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            make.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        }
        
        view.addSubviews(statisticsLabel, winsView, defeatsView, hoursView, gameView, editButton)

        statisticsLabel.snp.makeConstraints { make in
            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(27)
            } else {
                make.top.equalToSuperview().offset(57)
            }
            make.leading.equalToSuperview().offset(15)
        }
        
        winsView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.width.equalToSuperview().dividedBy(2).offset(-22.5)
            make.height.equalTo(117)
        }
        
        defeatsView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.trailing.equalToSuperview().inset(15)
            make.width.equalToSuperview().dividedBy(2).offset(-22.5)
            make.height.equalTo(117)
        }
        
        hoursView.snp.makeConstraints { make in
            make.top.equalTo(winsView.snp.bottom).offset(15)
            make.trailing.leading.equalToSuperview().inset(15)
            make.height.equalTo(117)
        }        
        
        gameView.snp.makeConstraints { make in
            make.top.equalTo(hoursView.snp.bottom).offset(15)
            make.trailing.leading.equalToSuperview().inset(15)
            make.height.equalTo(117)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(gameView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
        }
    }
    
    @objc private func didTapEdit() {
        let isEditing = updatedStatModel != nil
        let newStatVC = NewStatisticsViewController(isEditing: isEditing)
        
        newStatVC.delegate = self
        
        if let model = updatedStatModel {
            newStatVC.stat = model
            newStatVC.statId = model.id
        } else {
            print("Creating new stat, no existing model found")
        }
        
        newStatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(newStatVC, animated: true)
    }
}

// MARK: - NewStatisticsDelegate
extension StatisticsViewController: NewStatisticsDelegate {
    func didAddStat(_ model: StatisticsModel) {
        StatisticsDataManager.shared.saveStatistic(model)
        updatedStatModel = model
        
        winsView.updateValue(with: model.wins)
        defeatsView.updateValue(with: model.defeats)
        hoursView.updateValue(with: model.hours)
        gameView.updateValue(with: model.game)
    }
}
