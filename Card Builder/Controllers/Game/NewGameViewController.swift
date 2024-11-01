import UIKit

protocol NewGameDelegate: AnyObject {
    func didAddGame(_ model: GameModel)
    func didUpdateGame(_ model: GameModel)
}

final class NewGameViewController: UIViewController {
    private let nameGameView = AppTextFieldView(type: .nameGame)
    private let playersView = AppTextFieldView(type: .players)
    private let gameTimeView = AppTextFieldView(type: .gameTime)
    private let rulesView = AppTextFieldView(type: .rules)
    private let basicCardsLabel = UILabel()

    weak var delegate: NewGameDelegate?
    var game: GameModel?
    var gameId: UUID?
    private var isEditingMode: Bool
    
    private let cards = MockCardsData.shared.cards
    private var selectedCards: [Int] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    init(gameId: UUID? = nil, isEditing: Bool) {
        self.gameId = gameId
        isEditingMode = isEditing
        super.init(nibName: nil, bundle: nil)
        if let gameId = gameId {
            self.gameId = gameId
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

        navigationItem.title = isEditingMode ? L.editGame() : L.createGame()

        let backButton = UIBarButtonItem(customView: createBackButton())
        navigationItem.leftBarButtonItem = backButton
        
        let saveButton = UIBarButtonItem(title: L.save(), style: .plain, target: self, action: isEditingMode ? #selector(didTapEdit) : #selector(didTapAdd))
        saveButton.tintColor = UIColor(hex: "#01D451")
        navigationItem.rightBarButtonItem = saveButton

        setupUI()
        setupTextFields()
        updateAddButtonState()

        if isEditingMode {
            configure(with: game)
        }

        let textFields = [
            nameGameView.textField,
            playersView.textField,
            gameTimeView.textField,
            rulesView.textField
        ]

        let textViews = [
            nameGameView.textView
        ]

        let textFieldsToMove = [
            nameGameView.textField,
            playersView.textField,
            gameTimeView.textField,
            rulesView.textField
        ]

        let textViewsToMove = [
            nameGameView.textView
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

        nameGameView.delegate = self
        playersView.delegate = self
        gameTimeView.delegate = self
        rulesView.delegate = self
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#232323")
        
        basicCardsLabel.do { make in
            make.text = L.basicCards()
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .left
        }

        view.addSubviews(
            nameGameView, playersView, gameTimeView, rulesView, basicCardsLabel, collectionView
        )

        nameGameView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
        }

        playersView.snp.makeConstraints { make in
            make.top.equalTo(nameGameView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
        }

        gameTimeView.snp.makeConstraints { make in
            make.top.equalTo(playersView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
        }
        
        rulesView.snp.makeConstraints { make in
            make.top.equalTo(gameTimeView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
        }
        
        basicCardsLabel.snp.makeConstraints { make in
            make.top.equalTo(rulesView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(15)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(basicCardsLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
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
        button.addTarget(self, action: isEditingMode ? #selector(didTapEdit) : #selector(didTapAdd), for: .touchUpInside)

        button.semanticContentAttribute = .forceLeftToRight
        button.contentHorizontalAlignment = .right
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)

        button.frame.size = CGSize(width: 120, height: 44)

        return button
    }

    private func setupTextFields() {
        [nameGameView.textField,
         playersView.textField,
         gameTimeView.textField,
         rulesView.textField
        ].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    private func updateAddButtonState() {
        guard let saveButton = navigationItem.rightBarButtonItem else { return }
        let allFieldsFilled = [
            nameGameView.textField,
            playersView.textField,
            gameTimeView.textField,
            rulesView.textField
        ].allSatisfy {
            $0.text?.isEmpty == false
        }

        saveButton.isEnabled = allFieldsFilled
        saveButton.customView?.alpha = saveButton.isEnabled ? 1.0 : 0.5
    }

    private func saveGame() {
        guard let nameGame = nameGameView.textField.text,
              let players = playersView.textField.text,
              let gameTime = gameTimeView.textField.text,
              let rules = rulesView.textField.text else { return }

        let id = UUID()

        game = GameModel(
            id: id,
            nameGame: nameGame,
            players: players,
            gameTime: gameTime,
            rules: rules,
            cards: selectedCards
        )
    }

    @objc private func didTapAdd() {
        saveGame()
        if let game = game {
            if let existingTrainingIndex = loadGame().firstIndex(where: { $0.id == game.id }) {
                delegate?.didAddGame(game)
            } else {
                delegate?.didAddGame(game)
            }
        } else {
            print("TrainingModel is nil in didTapAdd")
        }
        didTapBack()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateAddButtonState()
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapEdit() {
        guard let gameId = gameId else {
            print("No gameId provided")
            return
        }

        let updatedNameGame = nameGameView.textField.text ?? ""
        let updatedPlayers = playersView.textField.text ?? ""
        let updatedGameTime = gameTimeView.textField.text ?? ""
        let updatedRules = rulesView.textField.text ?? ""

        GameDataManager.shared.updateGame(
            withId: gameId,
            nameGame: updatedNameGame,
            players: updatedPlayers,
            gameTime: updatedGameTime,
            rules: updatedRules,
            cards: selectedCards
        )

        if let updatedGame = GameDataManager.shared.loadGame(withId: gameId) {
            delegate?.didUpdateGame(updatedGame)
        } else {
            print("Failed to load updated model")
        }

        didTapBack()
    }

    // MARK: - Data Persistence Methods
    private func loadGame() -> [GameModel] {
        return GameDataManager.shared.loadGames()
    }

    private func configure(with model: GameModel?) {
        guard let model = model else { return }
        nameGameView.textField.text = model.nameGame
        playersView.textField.text = model.players
        gameTimeView.textField.text = model.gameTime
        rulesView.textField.text = model.rules

        selectedCards = model.cards
        collectionView.reloadData()
        updateAddButtonState()
    }
}

// MARK: - AppTextFieldDelegate
extension NewGameViewController: AppTextFieldDelegate {
    func didTapTextField(type: AppTextFieldView.TextFieldType) {
        updateAddButtonState()
    }
}

// MARK: - KeyBoard Apparance
extension NewGameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewGameViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillShow(notification as Notification)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillHide(notification as Notification)
    }
}

// MARK: - UICollectionViewDataSource
extension NewGameViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (cards.count + 4) / 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let startIndex = section * 5
        let endIndex = min(startIndex + 5, cards.count)
        return endIndex - startIndex
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.reuseIdentifier, for: indexPath) as? CardCell else {
            fatalError("Unable to dequeue CategoryCell")
        }
        
        let cardIndex = indexPath.section * 5 + indexPath.item
        if cardIndex < cards.count {
            let cardItem = cards[cardIndex]
            cell.delegate = self
            cell.configure(with: cardItem)
            cell.contentView.alpha = selectedCards.contains(cardIndex) ? 1.0 : 0.6
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 5) - 11
        let height: CGFloat = 96
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
}

// MARK: - CardCellDelegate
extension NewGameViewController: CardCellDelegate {
    func didTapCardCell(at index: Int, isSelected: Bool) {
        if isSelected {
            selectedCards.append(index)
        } else {
            selectedCards.removeAll(where: { $0 == index })
        }
    }
}
