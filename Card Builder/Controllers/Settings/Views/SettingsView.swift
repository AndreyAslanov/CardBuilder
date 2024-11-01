import SnapKit
import UIKit

protocol SettingsViewDelegate: AnyObject {
    func didTapView(type: SettingsView.SelfType)
}

final class SettingsView: UIControl {
    enum SelfType {
        case shareApp
        case usagePolicy
        case rateApp

        var title: String {
            switch self {
            case .shareApp: return L.shareApp()
            case .usagePolicy: return L.usagePolicy()
            case .rateApp: return L.rateApp()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .shareApp: return R.image.settings_share_icon()
            case .usagePolicy: return R.image.settings_policy_icon()
            case .rateApp: return R.image.settings_rate_icon()
            }
        }
    }

    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let stackView = UIStackView()
    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    private let type: SelfType
    weak var delegate: SettingsViewDelegate?

    init(type: SelfType) {
        self.type = type
        super.init(frame: .zero)
        setupView()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white.withAlphaComponent(0.05)
        
        layer.cornerRadius = 10
        imageView.image = type.image
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.do { make in
            make.textColor = .white
            make.font = .systemFont(ofSize: 15, weight: .medium)
            make.text = type.title
        }
        
        stackView.do { make in
            make.axis = .vertical
            make.spacing = 5
            make.alignment = .center
            make.distribution = .fillProportionally
            make.isUserInteractionEnabled = false
        }
        
        stackView.addArrangedSubviews([imageView, titleLabel])
        addSubviews(stackView)
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func configureAppearance() {
        alpha = isHighlighted ? 0.5 : 1
    }

    @objc private func didTapView() {
        delegate?.didTapView(type: type)
    }
}
