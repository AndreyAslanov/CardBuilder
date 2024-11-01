import UIKit

protocol NewStatisticsDelegate: AnyObject {
    func didAddStat(_ model: StatisticsModel)
}

final class NewStatisticsViewController: UIViewController {
    private let winsGameView = AppTextFieldView(type: .wins)
    private let defeatsView = AppTextFieldView(type: .defeats)
    private let hoursTimeView = AppTextFieldView(type: .hours)
    private let gameView = AppTextFieldView(type: .game)

    weak var delegate: NewStatisticsDelegate?
    var stat: StatisticsModel?
    var statId: UUID?
    private var isEditingMode: Bool

    init(statId: UUID? = nil, isEditing: Bool) {
        self.statId = statId
        isEditingMode = isEditing
        super.init(nibName: nil, bundle: nil)
        if let statId = statId {
            self.statId = statId
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationBar.standardAppearance = appearance
        }

        navigationItem.title = L.editStatistics()

        let backButton = UIBarButtonItem(customView: createBackButton())
        navigationItem.leftBarButtonItem = backButton

        let saveButton = UIBarButtonItem(title: L.save(), style: .plain, target: self, action: #selector(didTapAdd))
        saveButton.tintColor = UIColor(hex: "#01D451")
        navigationItem.rightBarButtonItem = saveButton

        setupUI()
        setupTextFields()
        updateAddButtonState()

        if isEditingMode {
            configure(with: stat)
        }

        let textFields = [
            winsGameView.textField,
            defeatsView.textField,
            hoursTimeView.textField,
            gameView.textField
        ]

        let textViews = [
            winsGameView.textView
        ]

        let textFieldsToMove = [
            winsGameView.textField,
            defeatsView.textField,
            hoursTimeView.textField,
            gameView.textField
        ]

        let textViewsToMove = [
            winsGameView.textView
        ]

        KeyboardManager.shared.configureKeyboard(
            for: self,
            targetView: view,
            textFields: textFields,
            textViews: textViews,
            moveFor: textFieldsToMove,
            moveFor: textViewsToMove,
            with: .done
        )

        winsGameView.delegate = self
        defeatsView.delegate = self
        hoursTimeView.delegate = self
        gameView.delegate = self
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#232323")

        view.addSubviews(
            winsGameView, defeatsView, hoursTimeView, gameView
        )

        winsGameView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
        }

        defeatsView.snp.makeConstraints { make in
            make.top.equalTo(winsGameView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
        }

        hoursTimeView.snp.makeConstraints { make in
            make.top.equalTo(defeatsView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
        }
        
        gameView.snp.makeConstraints { make in
            make.top.equalTo(hoursTimeView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
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
    
    private func createSaveButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(L.save(), for: .normal)
        button.setTitleColor(UIColor(hex: "#01D451"), for: .normal)

        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)

        button.semanticContentAttribute = .forceLeftToRight
        button.contentHorizontalAlignment = .right
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)

        button.frame.size = CGSize(width: 120, height: 44)

        return button
    }

    private func setupTextFields() {
        [winsGameView.textField,
         defeatsView.textField,
         hoursTimeView.textField,
         gameView.textField
        ].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    private func updateAddButtonState() {
        guard let saveButton = navigationItem.rightBarButtonItem else { return }
        let allFieldsFilled = [
            winsGameView.textField,
            defeatsView.textField,
            hoursTimeView.textField,
            gameView.textField
        ].allSatisfy {
            $0.text?.isEmpty == false
        }

        saveButton.isEnabled = allFieldsFilled
        saveButton.customView?.alpha = saveButton.isEnabled ? 1.0 : 0.5
    }

    private func saveStat() {
        guard let winsGame = winsGameView.textField.text,
              let defeat = defeatsView.textField.text,
              let hoursTime = hoursTimeView.textField.text,
              let game = gameView.textField.text else { return }

        let id = UUID()

        stat = StatisticsModel(
            id: id,
            wins: winsGame,
            defeats: defeat,
            hours: hoursTime,
            game: game
        )
    }

    @objc private func didTapAdd() {
        saveStat()
        if let stat = stat {
            StatisticsDataManager.shared.saveStatistic(stat)
            delegate?.didAddStat(stat)
        } else {
            print("StatModel is nil in didTapAdd")
        }
        didTapBack()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateAddButtonState()
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Data Persistence Methods
    private func loadStat() -> StatisticsModel? {
        return StatisticsDataManager.shared.loadStatistic()
    }

    private func configure(with model: StatisticsModel?) {
        guard let model = model else { return }
        winsGameView.textField.text = model.wins
        defeatsView.textField.text = model.defeats
        hoursTimeView.textField.text = model.hours
        gameView.textField.text = model.game

        updateAddButtonState()
    }
}

// MARK: - AppTextFieldDelegate
extension NewStatisticsViewController: AppTextFieldDelegate {
    func didTapTextField(type: AppTextFieldView.TextFieldType) {
        updateAddButtonState()
    }
}

// MARK: - KeyBoard Apparance
extension NewStatisticsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewStatisticsViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillShow(notification as Notification)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillHide(notification as Notification)
    }
}
