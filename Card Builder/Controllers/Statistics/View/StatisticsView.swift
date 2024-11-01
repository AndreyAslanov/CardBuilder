import SnapKit
import UIKit

final class StatisticsView: UIControl {
    enum StatisticsType {
        case wins
        case defeats
        case hours
        case game

        var title: String {
            switch self {
            case .wins: return L.quantityWins()
            case .defeats: return L.quantityDefeats()
            case .hours: return L.hoursGames()
            case .game: return L.favoriteGame()
            }
        }
        
        var value: String {
            switch self {
            case .wins: return "0"
            case .defeats: return "0"
            case .hours: return "0 h"
            case .game: return "None"
            }
        }
    }

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let stackView = UIStackView()
    private let type: StatisticsType

    init(type: StatisticsType) {
        self.type = type
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white.withAlphaComponent(0.05)
        layer.cornerRadius = 12
        
        titleLabel.do { make in
            make.textColor = .white
            make.font = .systemFont(ofSize: 13)
            make.text = type.title
        }
        
        valueLabel.do { make in
            make.textColor = .white
            make.font = .systemFont(ofSize: 20, weight: .semibold)
            make.text = type.value
        }
        
        stackView.do { make in
            make.axis = .vertical
            make.alignment = .center
            make.spacing = 11
            make.distribution = .fillProportionally
        }
        
        stackView.addArrangedSubviews([titleLabel, valueLabel])
        addSubviews(stackView)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func updateTitle(with newText: String) {
        titleLabel.text = newText
    }
    
    func updateValue(with newText: String) {
        valueLabel.text = newText
    }
}
