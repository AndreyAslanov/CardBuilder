import UIKit
import SnapKit

final class GeneratorViewController: UIViewController {
    
    private let textField = UITextField()
    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L.generate(), for: .normal)
        button.backgroundColor = UIColor(hex: "#01D451")
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.setTitleColor(UIColor(hex: "#232323"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.isHidden = true
        button.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let numberPadStackView = UIStackView()
    private var numberButtons: [UIButton] = []
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⌫", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .white.withAlphaComponent(0.05)
        button.layer.cornerRadius = 43
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTextFieldObserver()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(hex: "#232323")
        navigationItem.title = L.playerGenerator()
        
        textField.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.05)
            make.layer.cornerRadius = 12
            make.font = .systemFont(ofSize: 15)
            make.textColor = .white
            make.textAlignment = .left
            make.setLeftPaddingPoints(16)
            
            let placeholderColor = UIColor(hex: "#636365")
            let placeholderFont = UIFont.systemFont(ofSize: 15)
            let placeholderText = L.enterNumberPlayers()
            
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [
                    NSAttributedString.Key.foregroundColor: placeholderColor,
                    NSAttributedString.Key.font: placeholderFont
                ]
            )
        }
        
        view.addSubview(textField)
        view.addSubview(numberPadStackView)
        view.addSubview(generateButton)
        
        numberPadStackView.axis = .vertical
        numberPadStackView.alignment = .fill
        numberPadStackView.distribution = .fillEqually
        numberPadStackView.spacing = 25
        
        setupConstraints()
        createNumberPad()
    }
    
    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            if UIDevice.isIphoneBelowX {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            } else {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(25)
            }
            
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
        }
        
        numberPadStackView.snp.makeConstraints { make in
            if UIDevice.isIphoneBelowX {
                make.top.equalTo(textField.snp.bottom).offset(30)
            } else {
                make.top.equalTo(textField.snp.bottom).offset(43)
            }
            
            make.centerX.equalToSuperview()
            if UIDevice.isIphoneBelowX {
                make.height.equalTo(380)
                make.width.equalTo(278)
            } else {
                make.height.equalTo(419)
                make.width.equalTo(308)
            }
        }
        
        generateButton.snp.makeConstraints { make in
            make.top.equalTo(numberPadStackView.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(45)
        }
    }
    
    private func createNumberPad() {
        let numbers = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["", "0", "delete"]
        ]
        
        for row in numbers {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 25
            numberPadStackView.addArrangedSubview(rowStackView)
            
            for number in row {
                let button: UIButton
                if number == "delete" {
                    button = deleteButton
                } else if number == "" {
                    let emptyView = UIView()
                    rowStackView.addArrangedSubview(emptyView)
                    continue
                } else {
                    button = createNumberButton(with: number)
                    numberButtons.append(button)
                }
                rowStackView.addArrangedSubview(button)
            }
        }
    }
    
    private func createNumberButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .white.withAlphaComponent(0.05)
        if UIDevice.isIphoneBelowX {
            button.layer.cornerRadius = 38
        } else {
            button.layer.cornerRadius = 43
        }
        button.clipsToBounds = true
        button.snp.makeConstraints { make in
            if UIDevice.isIphoneBelowX {
                make.width.height.equalTo(76)
            } else {
                make.width.height.equalTo(86)
            }
        }
        button.addTarget(self, action: #selector(numberButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func numberButtonTapped(_ sender: UIButton) {
        guard let number = sender.currentTitle else { return }
        textField.text = (textField.text ?? "") + number
        updateGenerateButtonVisibility()
    }
    
    @objc private func deleteButtonTapped() {
        guard var text = textField.text, !text.isEmpty else { return }
        text.removeLast()
        textField.text = text
        updateGenerateButtonVisibility()
    }
    
    @objc private func generateButtonTapped() {
        guard let text = textField.text, let playerCount = Int(text), playerCount > 0 else { return }
        
        let randomPlayer = Int.random(in: 1...playerCount)
        let playerSelectedViewController = PlayerSelectedViewController()
        playerSelectedViewController.selectedPlayer = randomPlayer
        navigationController?.pushViewController(playerSelectedViewController, animated: true)
    }

    private func setupTextFieldObserver() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc private func textFieldDidChange() {
        updateGenerateButtonVisibility()
    }

    private func updateGenerateButtonVisibility() {
        generateButton.isHidden = textField.text?.isEmpty ?? true
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
