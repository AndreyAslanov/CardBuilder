import UIKit

final class PlayerSelectedViewController: UIViewController {
    private let playerSelectedLabel = UILabel()
    private let playerSelectedValueLabel = UILabel()
    private let closeButton = UIButton()
    var selectedPlayer: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationBar.standardAppearance = appearance
        }

        navigationItem.title = L.playerGenerator()

        let backButton = UIBarButtonItem(customView: createBackButton())
        navigationItem.leftBarButtonItem = backButton

        setupUI()
        configure()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#232323")
        
        playerSelectedLabel.do { make in
            make.text = L.playerSelected()
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.numberOfLines = 2
            make.textAlignment = .center
        }        
        
        playerSelectedValueLabel.do { make in
            make.font = .systemFont(ofSize: 96, weight: .bold)
            make.textColor = .white
            make.textAlignment = .center
        }
        
        closeButton.do { make in
            make.setTitle(L.close(), for: .normal)
            make.backgroundColor = UIColor(hex: "#01D451")
            make.layer.cornerRadius = 12
            make.clipsToBounds = true
            make.setTitleColor(UIColor(hex: "#232323"), for: .normal)
            make.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            make.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        }
        
        view.addSubviews(
            playerSelectedLabel, playerSelectedValueLabel, closeButton
        )
        
        playerSelectedLabel.snp.makeConstraints { make in
            if UIDevice.isIphoneBelowX {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(146)
            } else {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(196)
            }
            
            make.centerX.equalToSuperview()
            make.width.equalTo(257)
        }
        
        playerSelectedValueLabel.snp.makeConstraints { make in
            make.top.equalTo(playerSelectedLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(playerSelectedValueLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(66)
            make.height.equalTo(45)
        }
    }

    private func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(L.back(), for: .normal)
        button.setTitleColor(.white, for: .normal)

        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)

        let chevronImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        button.setImage(chevronImage, for: .normal)
        button.tintColor = .white

        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        button.semanticContentAttribute = .forceLeftToRight
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)

        button.frame.size = CGSize(width: 120, height: 44)

        return button
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    private func configure() {
        if let player = selectedPlayer {
            playerSelectedValueLabel.text = "\(player)"
        }
    }
}
