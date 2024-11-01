import UIKit

protocol GameProfileDelegate: AnyObject {
    func didDeleteModel(withId id: UUID)
    func didUpdateGame(_ model: GameModel)
}

final class GameProfileViewController: UIViewController {
    private let quantitiesPlayersView = AverageView(type: .quantitiesPlayers)
    private let gameTimeView = AverageView(type: .gameTime)
    private let rulesView = UIView()
    private let rulesLabel = UILabel()
    private let rulesValueLabel = UILabel()
    private let cardsView = UIView()
    private let cardsLabel = UILabel()

    weak var delegate: GameProfileDelegate?
    var game: GameModel?
    var gameId: UUID?
    private var isEditingMode: Bool
    var updatedGame: GameModel?
    
    private var isGameUpdated = false
    
    private let cards = MockCardsData.shared.cards
    private var selectedCards: [Int] = []
    private var filteredCards: [CardModel] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
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

        navigationItem.title = game?.nameGame

        let backButton = UIBarButtonItem(customView: createBackButton())
        navigationItem.leftBarButtonItem = backButton
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .plain, target: self, action: #selector(deleteGame))
        let editButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editGame))
        
        deleteButton.tintColor = UIColor(hex: "#01D451")
        editButton.tintColor = UIColor(hex: "#01D451")
        navigationItem.rightBarButtonItems = [editButton, deleteButton]

        setupUI()
        loadSelectedCards()
        collectionView.reloadData()

        configure(with: game)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#232323")
        
        rulesView.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.05)
            make.layer.cornerRadius = 12
        }        
        
        cardsView.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.05)
            make.layer.cornerRadius = 12
        }
        
        rulesLabel.do { make in
            make.text = L.rules()
            make.font = .systemFont(ofSize: 13)
            make.textColor = .white
            make.textAlignment = .left
        }          
        
        cardsLabel.do { make in
            make.text = L.basicCards()
            make.font = .systemFont(ofSize: 13)
            make.textColor = .white
            make.textAlignment = .left
        }        
        
        rulesValueLabel.do { make in
            make.font = .systemFont(ofSize: 16)
            make.textColor = .white
            make.textAlignment = .left
            make.numberOfLines = 11
        }

        rulesView.addSubviews(rulesLabel, rulesValueLabel)
        cardsView.addSubviews(cardsLabel, collectionView)
        view.addSubviews(
            quantitiesPlayersView, gameTimeView, rulesView, cardsView
        )
        
        quantitiesPlayersView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(117)
            make.width.equalToSuperview().dividedBy(2).offset(-21)
        }
        
        gameTimeView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(117)
            make.width.equalToSuperview().dividedBy(2).offset(-21)
        }
        
        rulesView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(quantitiesPlayersView.snp.bottom).offset(15)
        }
        
        rulesLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.leading.equalToSuperview().offset(20)
        }
        
        rulesValueLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(rulesLabel.snp.bottom).offset(11)
            make.bottom.equalToSuperview().inset(23)
        }
        
        cardsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(rulesView.snp.bottom).offset(15)
            make.height.equalTo(171)
        }
        
        cardsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.leading.equalToSuperview().offset(20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(cardsLabel.snp.bottom).offset(11)
            make.leading.trailing.equalToSuperview().inset(37.5)
            make.bottom.equalToSuperview().inset(23)
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
        if isGameUpdated, let updatedGame = updatedGame {
            delegate?.didUpdateGame(updatedGame)
        }
        navigationController?.popViewController(animated: true)
    }

    @objc private func deleteGame() {
        let alertController = UIAlertController(title: L.delete(), message: L.deleteThis(), preferredStyle: .alert)
        let closeAction = UIAlertAction(title: L.cancel(), style: .default, handler: nil)
        let deleteAction = UIAlertAction(title: L.delete(), style: .destructive) { [weak self] _ in
            guard let self = self, let gameId = self.gameId else { return }

            GameDataManager.shared.deleteGame(withId: gameId)
            self.delegate?.didDeleteModel(withId: gameId)
            self.didTapBack()
        }

        alertController.addAction(closeAction)
        alertController.addAction(deleteAction)
        alertController.view.tintColor = UIColor(hex: "#0A84FF")
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }

    @objc private func editGame() {
        let newGameVC = NewGameViewController(isEditing: true)
        newGameVC.delegate = self
        newGameVC.game = game
        newGameVC.gameId = gameId
        newGameVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(newGameVC, animated: true)
    }

    // MARK: - Data Persistence Methods
    private func loadGame() -> [GameModel] {
        return GameDataManager.shared.loadGames()
    }

    private func configure(with model: GameModel?) {
        guard let model = model else { return }
        quantitiesPlayersView.updateValue(with: model.players)
        gameTimeView.updateValue(with: model.gameTime)
        rulesValueLabel.text = model.rules

        selectedCards = model.cards
        loadSelectedCards()
        collectionView.reloadData()
    }
    
    private func loadSelectedCards() {
        filteredCards = cards.filter { selectedCards.contains($0.index) }
    }
}

// MARK: - UICollectionViewDataSource
extension GameProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.reuseIdentifier, for: indexPath) as? CardCell else {
            fatalError("Unable to dequeue GenreCell")
        }
        
        let cardItem = filteredCards[indexPath.item]
        cell.configure(with: cardItem)
        cell.isUserInteractionEnabled = false
        cell.contentView.alpha = 1.0
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 63
        let height: CGFloat = 96
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
}

// MARK: - CardCellDelegate
extension GameProfileViewController: CardCellDelegate {
    func didTapCardCell(at index: Int, isSelected: Bool) {
        if isSelected {
            selectedCards.append(index)
        } else {
            selectedCards.removeAll(where: { $0 == index })
        }
    }
}

// MARK: - NewGameDelegate
extension GameProfileViewController: NewGameDelegate {
    func didAddGame(_ model: GameModel) {
    }
    
    func didUpdateGame(_ model: GameModel) {
        configure(with: model)
        updatedGame = model
        isGameUpdated = true
    }
}
