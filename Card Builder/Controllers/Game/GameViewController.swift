import SnapKit
import UIKit

final class GameViewController: UIViewController {
    private let mainLabel = UILabel()
    
    private let averageTimeView = AverageView(type: .time)
    private let averagePlayersView = AverageView(type: .players)
    private let averageGamesView = AverageView(type: .games)
    
    private let addGameView = AddGameView()
    private var games: [GameModel] = [] {
         didSet {
             saveGames(games)
         }
     }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: GameCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.black
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        view.backgroundColor = UIColor(hex: "#1F1F1F")

        let plusBarButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        plusBarButton.tintColor = .white
        navigationItem.rightBarButtonItem = plusBarButton

        drawself()
        games = loadGames()
        addGameView.delegate = self
        updateViewVisibility()
    }

    private func drawself() {
        mainLabel.do { make in
            make.text = L.game()
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textColor = UIColor(hex: "#00913E")
            make.textAlignment = .left
        }

        view.addSubviews(
            mainLabel, averageTimeView, averagePlayersView, averageGamesView, 
            collectionView, addGameView
        )

        mainLabel.snp.makeConstraints { make in
            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(27)
            } else {
                make.top.equalToSuperview().offset(57)
            }
            make.leading.equalToSuperview().offset(15)
        }
        
        averageTimeView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(23)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(240)
            make.width.equalToSuperview().dividedBy(2).offset(-21)
            make.width.equalTo(174)
        }
        
        averagePlayersView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(23)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(averageTimeView.snp.height).dividedBy(2).offset(-4.5)
            make.width.equalToSuperview().dividedBy(2).offset(-21)
            make.width.equalTo(174)
        }
        
        averageGamesView.snp.makeConstraints { make in
            make.top.equalTo(averagePlayersView.snp.bottom).offset(9)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(averageTimeView.snp.height).dividedBy(2).offset(-4.5)
            make.width.equalToSuperview().dividedBy(2).offset(-21)
            make.width.equalTo(174)
        }

        addGameView.snp.makeConstraints { make in
            make.top.equalTo(averageGamesView.snp.bottom).offset(61)
            make.leading.trailing.equalToSuperview().inset(61)
            make.height.equalTo(130)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(averageGamesView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
        }
    }

    private func updateViewVisibility() {
        let isEmpty = games.isEmpty
        addGameView.isHidden = !isEmpty
        collectionView.reloadData()
    }
    
    // MARK: - Data Persistence Methods
    private func loadGames() -> [GameModel] {
        return GameDataManager.shared.loadGames()
    }

    private func saveGames(_ models: [GameModel]) {
        GameDataManager.shared.saveGames(models)
    }
}

// MARK: - AddPhotoViewDelegate
extension GameViewController: AddGameViewDelegate {
    @objc func didTapAddButton() {
        let newGameVC = NewGameViewController(isEditing: false)
        newGameVC.delegate = self
        newGameVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(newGameVC, animated: true)
    }
}

// MARK: - NewGameDelegate
extension GameViewController: NewGameDelegate {
    func didAddGame(_ model: GameModel) {
        games.append(model)
        updateViewVisibility()
    }
}

// MARK: - GameProfileDelegate
extension GameViewController: GameProfileDelegate {
    func didDeleteModel(withId id: UUID) {
        if let index = games.firstIndex(where: { $0.id == id }) {
            games.remove(at: index)
            updateViewVisibility()
        }
    }
    
    func didUpdateGame(_ model: GameModel) {
        if let index = games.firstIndex(where: { $0.id == model.id }) {
            games[index] = model
        }
        updateViewVisibility()
    }
}

// MARK: - GameCellDelegate
extension GameViewController: GameCellDelegate {
    func didTapOpen(with model: GameModel) {
        let newGameVC = GameProfileViewController(isEditing: true)
        newGameVC.delegate = self
        newGameVC.game = model
        newGameVC.gameId = model.id
        newGameVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(newGameVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return games.isEmpty ? 0 : games.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section < games.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameCell.reuseIdentifier, for: indexPath) as? GameCell else {
                fatalError("Unable to dequeue RoutersPermanentCell")
            }
            let games = games[indexPath.section]
            cell.delegate = self
            cell.configure(with: games)
            return cell
        }

        return collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 80
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
}
