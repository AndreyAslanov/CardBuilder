import SnapKit
import UIKit

protocol AddGameViewDelegate: AnyObject {
    func didTapAddButton()
}

final class AddGameView: UIControl {
    weak var delegate: AddGameViewDelegate?
    
    private let title = UILabel()
    private let subtitle = UILabel()
    private let buttonView = UIView()
    private let plusImageView = UIImageView()
    private let addLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
        setupConstraints()
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        plusImageView.image = R.image.game_plus_icon()

        title.do { make in
            make.text = L.createGameLabel()
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .center
            make.isUserInteractionEnabled = false
        }        
        
        subtitle.do { make in
            make.text = L.createGameSublabel()
            make.font = .systemFont(ofSize: 16)
            make.textColor = UIColor(hex: "#999999")
            make.textAlignment = .center
            make.numberOfLines = 2
            make.isUserInteractionEnabled = false
        }
        
        buttonView.do { make in
            make.backgroundColor = UIColor(hex: "#01D451")
            make.layer.cornerRadius = 12
            make.clipsToBounds = true
        }
        
        stackView.do { make in
            make.axis = .horizontal
            make.spacing = 5
            make.alignment = .center
            make.distribution = .fillProportionally
        }
        
        addLabel.do { make in
            make.text = L.create()
            make.textColor = UIColor(hex: "#232323")
            make.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        }
        
        stackView.addArrangedSubviews([plusImageView, addLabel])
        buttonView.addSubviews(stackView)
        addSubviews(title, subtitle, buttonView)
    }

    private func setupConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.width.equalTo(174)
            make.centerX.equalToSuperview()
        }

        buttonView.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addViewTapped))
        buttonView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func addViewTapped() {
        delegate?.didTapAddButton()
    }
    
    func updateTitle(with newText: String) {
        title.text = newText
    }
}
