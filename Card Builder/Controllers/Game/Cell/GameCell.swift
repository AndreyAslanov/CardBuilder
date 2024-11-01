import SnapKit
import UIKit

protocol GameCellDelegate: AnyObject {
    func didTapOpen(with model: GameModel)
}

class GameCell: UICollectionViewCell {
    static let reuseIdentifier = "GameCell"
    weak var delegate: GameCellDelegate?
    var gameModel: GameModel?

    private let nameGameLabel = UILabel()
    private let nameGameValueLabel = UILabel()   
    private let nameStackView = UIStackView()
    
    private let playersLabel = UILabel()
    private let playersValueLabel = UILabel()
    private let playersStackView = UIStackView()
    
    private let gameTimeLabel = UILabel()
    private let gameTimeValueLabel = UILabel()
    private let gameTimeStackView = UIStackView()
    
    private let firstView = UIView()
    private let secondView = UIView()
    
    private let arrowImageView = UIImageView()
    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white.withAlphaComponent(0.05)
        layer.cornerRadius = 10
        arrowImageView.image = R.image.game_arrow()
        
        [nameGameLabel, playersLabel, gameTimeLabel].forEach { label in
            label.do { make in
                make.font = .systemFont(ofSize: 12)
                make.textColor = UIColor(hex: "#999999")
                make.textAlignment = .left
            }
        }
        
        [nameGameValueLabel, playersValueLabel, gameTimeValueLabel].forEach { label in
            label.do { make in
                make.font = .systemFont(ofSize: 15)
                make.textColor = .white
                make.textAlignment = .left
                make.numberOfLines = 2
            }
        }
        
        nameGameLabel.text = L.nameGameLabel()
        playersLabel.text = L.playersLabel()
        gameTimeLabel.text = L.gameTimeLabel()
        
        [nameStackView, playersStackView, gameTimeStackView].forEach { stackView in
            stackView.do { make in
                make.axis = .vertical
                make.spacing = 5
                make.alignment = .leading
                make.distribution = .fillProportionally
            }
        }
        
        [firstView, secondView].forEach { view in
            view.do { make in
                make.backgroundColor = UIColor(hex: "#01D451")
                make.layer.cornerRadius = 0.5
            }
        }

        nameStackView.addArrangedSubviews([nameGameLabel, nameGameValueLabel])
        playersStackView.addArrangedSubviews([playersLabel, playersValueLabel])
        gameTimeStackView.addArrangedSubviews([gameTimeLabel, gameTimeValueLabel])
        
        contentView.addSubviews(
            nameStackView, playersStackView, gameTimeStackView,
            firstView, secondView, arrowImageView
        )
        
        nameStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(71)
        }
        
        firstView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(15.75)
            make.width.equalTo(1)
            make.leading.equalTo(nameStackView.snp.trailing).offset(20)
            make.trailing.equalTo(playersStackView.snp.leading).offset(-20)
        }
        
        playersStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(firstView.snp.trailing).offset(20)
            make.trailing.equalTo(secondView.snp.leading).offset(-20)
            make.width.equalTo(71)
        }
        
        secondView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(15.75)
            make.width.equalTo(1)
            make.leading.equalTo(playersStackView.snp.trailing).offset(20)
            make.trailing.equalTo(gameTimeStackView.snp.leading).offset(-20)
        }
        
        gameTimeStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(secondView.snp.trailing).offset(20)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-20)
            make.width.equalTo(71)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
            make.width.equalTo(11)
        }
    }
    
    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }
    
    @objc private func handleTap() {
        guard let model = gameModel else { return }
        delegate?.didTapOpen(with: model)
    }

    func configure(with model: GameModel) {
        gameModel = model
        nameGameValueLabel.text = model.nameGame
        playersValueLabel.text = model.players
        gameTimeValueLabel.text = model.gameTime
    }
}
