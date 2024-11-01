import SnapKit
import UIKit

final class SettingsViewController: UIViewController {
    private let settingsLabel = UILabel()
    
    private let homeVC = GameViewController()
    private let trainingVC = StatisticsViewController()
    
    private let shareAppView: SettingsView
    private let usagePolicyView: SettingsView
    private let rateAppView: SettingsView

    init() {
        shareAppView = SettingsView(type: .shareApp)
        usagePolicyView = SettingsView(type: .usagePolicy)
        rateAppView = SettingsView(type: .rateApp)
        
        super.init(nibName: nil, bundle: nil)
        
        shareAppView.delegate = self
        usagePolicyView.delegate = self
        rateAppView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#1F1F1F")
        drawself()
    }

    private func drawself() {
        settingsLabel.do { make in
            make.text = L.settings()
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textColor = UIColor(hex: "#00913E")
            make.textAlignment = .left
        }
        
        view.addSubviews(settingsLabel, usagePolicyView, rateAppView, shareAppView)
        
        settingsLabel.snp.makeConstraints { make in
            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(27)
            } else {
                make.top.equalToSuperview().offset(57)
            }
            make.leading.equalToSuperview().offset(16)
        }
        
        rateAppView.snp.makeConstraints { make in
            make.top.equalTo(settingsLabel.snp.bottom).offset(27)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(shareAppView.snp.leading).offset(-20)
            make.width.equalToSuperview().dividedBy(2).offset(-25)
            make.height.equalTo(100)
        }
        
        shareAppView.snp.makeConstraints { make in
            make.top.equalTo(settingsLabel.snp.bottom).offset(27)
            make.trailing.equalToSuperview().inset(15)
            make.leading.equalTo(rateAppView.snp.trailing).offset(20)
            make.width.equalToSuperview().dividedBy(2).offset(-25)
            make.height.equalTo(100)
        }
        
        usagePolicyView.snp.makeConstraints { make in
            make.top.equalTo(shareAppView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(100)
        }
    }
}

// MARK: - ProfileViewDelegate
extension SettingsViewController: SettingsViewDelegate {
    func didTapView(type: SettingsView.SelfType) {
        switch type {
        case .shareApp:
            AppActions.shared.shareApp()
        case .usagePolicy:
            AppActions.shared.showUsagePolicy()
        case .rateApp:
            AppActions.shared.rateApp()
        }
    }
}
