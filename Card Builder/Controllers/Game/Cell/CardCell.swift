import UIKit

// MARK: - GenreCell
protocol CardCellDelegate: AnyObject {
    func didTapCardCell(at index: Int, isSelected: Bool)
}

final class CardCell: UICollectionViewCell {
    static let reuseIdentifier = "CardCell"
    
    private let imageView = UIImageView()
    weak var delegate: CardCellDelegate?
    private var index: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubviews(imageView)
        setupImageView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(with card: CardModel) {
        imageView.image = card.image
        index = card.index
        contentView.alpha = card.isSelected ? 1.0 : 0.6
    }
    
    @objc private func didTapCell() {
        guard let index = index else { return }
        let isSelected = contentView.alpha == 1.0
        delegate?.didTapCardCell(at: index, isSelected: !isSelected)
        contentView.alpha = isSelected ? 0.6 : 1.0
    }
}
