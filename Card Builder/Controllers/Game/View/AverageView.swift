import SnapKit
import UIKit

final class AverageView: UIControl {
    enum AverageType {
        case time
        case players
        case games
        
        case quantitiesPlayers
        case gameTime

        var title: String {
            switch self {
            case .time: return L.averageTime()
            case .players: return L.averagePlayers()
            case .games: return L.averageGames()
                
            case .quantitiesPlayers: return L.quantitiesPlayers()
            case .gameTime: return L.gameTime()
            }
        }
        
        var value: String {
            switch self {
            case .time: return "0 min"
            case .players: return "0"
            case .games: return "0"
                
            case .quantitiesPlayers: return "0"
            case .gameTime: return "0 min"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .time: return R.image.average_time_icon()
            case .players: return R.image.average_players_icon()
            case .games: return R.image.average_game_icon()
                
            case .quantitiesPlayers: return R.image.average_players_icon()
            case .gameTime: return R.image.average_time_icon()
            }
        }
    }

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let imageView = UIImageView()
    private let type: AverageType

    init(type: AverageType) {
        self.type = type
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white.withAlphaComponent(0.05)
        
        layer.cornerRadius = 20
        imageView.image = type.image
        imageView.contentMode = .scaleAspectFit
        
        imageView.layer.cornerRadius = 20
        imageView.layer.maskedCorners = [.layerMaxXMaxYCorner] 
        imageView.clipsToBounds = true
        
        titleLabel.do { make in
            make.textColor = .white
            make.font = .systemFont(ofSize: 13)
            make.text = type.title
        }        
        
        valueLabel.do { make in
            make.textColor = .white
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.text = type.value
        }
        
        addSubviews(imageView, titleLabel, valueLabel)
        
        if type == .time {
            imageView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(40)
                make.centerX.equalToSuperview()
                make.size.equalTo(90)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(30)
                make.leading.equalToSuperview().offset(8.5)
            }
            
            valueLabel.snp.makeConstraints { make in
                make.leading.equalTo(titleLabel.snp.leading)
                make.top.equalTo(titleLabel.snp.bottom)
            }
        } else {
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(24)
                make.leading.trailing.equalToSuperview().inset(11)
            }
            
            imageView.snp.makeConstraints { make in
                make.bottom.trailing.equalToSuperview()
            }
            
            valueLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().inset(13)
            }
        }
    }
    
    func updateTitle(with newText: String) {
        titleLabel.text = newText
    }
    
    func updateValue(with newText: String) {
        valueLabel.text = newText
    }
}
