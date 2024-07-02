import UIKit

class GradientSquareCell: UICollectionViewCell {
    static let identifier = "GradientSquareCell"
    
    private let gradientLayer = CAGradientLayer()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let blurEffect: UIBlurEffect = {
        return UIBlurEffect(style: .systemMaterial)
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.addSublayer(gradientLayer)
        contentView.addSubview(blurEffectView)
        contentView.addSubview(titleLabel)
        setupConstraints()
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(
            origin: CGPoint(x: 16, y: 16),
            size: CGSize(width: contentView.bounds.size.width - 32, height: contentView.bounds.size.height - 32)
        )
    }
    
    func configure(with gradient: (String, [CGColor])) {
        titleLabel.text = gradient.0
        gradientLayer.colors = gradient.1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer.colors = nil
        titleLabel.text = nil
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 24),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -24),
            
            blurEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            blurEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            blurEffectView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -16)
        ])
    }
    
    private func setupLayer() {
        gradientLayer.cornerRadius = 20
        gradientLayer.masksToBounds = false
        gradientLayer.shadowColor = UIColor.black.cgColor
        gradientLayer.shadowOpacity = 0.1
        gradientLayer.shadowOffset = CGSize(width: 0, height: 3)
        gradientLayer.shadowRadius = 10
        
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.layer.masksToBounds = true
        blurEffectView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var collectionView: UICollectionView!
    
    private let gradients: [(String, [CGColor])] = (1...100).map { index in
        let colors = [
            UIColor(hue: CGFloat(index) / 100.0, saturation: 0.7, brightness: 0.9, alpha: 1.0).cgColor,
            UIColor(hue: CGFloat(index) / 200.0, saturation: 0.4, brightness: 0.9, alpha: 1.0).cgColor,
            UIColor(hue: CGFloat(index) / 250.0, saturation: 0.75, brightness: 0.9, alpha: 1.0).cgColor,
            UIColor(hue: CGFloat(index) / 195.0, saturation: 0.647, brightness: 0.9, alpha: 1.0).cgColor,
            UIColor(hue: CGFloat(index) / 85.0, saturation: 0.7527, brightness: 0.9, alpha: 1.0).cgColor,
            UIColor(hue: CGFloat(index) / 464.0, saturation: 0.237, brightness: 0.9, alpha: 1.0).cgColor,
            UIColor(hue: CGFloat(index) / 45.0, saturation: 0.3457, brightness: 0.9, alpha: 1.0).cgColor,
            UIColor(hue: CGFloat(index) / 75.0, saturation: 0.657, brightness: 0.9, alpha: 1.0).cgColor,
        ]
        return ("Gradient \(index)", colors)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        scrollTo(item: 10)
    }
    
    private func scrollTo(item: Int) {
        if item < 100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.collectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: .bottom, animated: true)
                self.scrollTo(item: item + 10)
            }
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(GradientSquareCell.self, forCellWithReuseIdentifier: GradientSquareCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gradients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GradientSquareCell.identifier, for: indexPath) as! GradientSquareCell
        let gradient = gradients[indexPath.item]
        cell.configure(with: gradient)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = (view.frame.width - 24)
        return CGSize(width: side, height: side)
    }
}
