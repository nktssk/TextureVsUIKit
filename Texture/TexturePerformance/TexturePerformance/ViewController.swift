import AsyncDisplayKit
import FPSCounter

class GradientSquareNode: ASCellNode {
    private let gradientLayerNode = ASDisplayNode()
    private let titleNode = ASTextNode()
    private let blurNode = ASDisplayNode { UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial)) }
    
    init(gradient: (String, [CGColor])) {
        super.init()
        automaticallyManagesSubnodes = true
        
        titleNode.attributedText = NSAttributedString(string: gradient.0, attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
            .foregroundColor: UIColor.white
        ])
        
        gradientLayerNode.setLayerBlock { () -> CALayer in
            let layer = CAGradientLayer()
            layer.colors = gradient.1
            layer.cornerRadius = 20
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.1
            layer.shadowOffset = CGSize(width: 0, height: 3)
            layer.shadowRadius = 10
            return layer
        }
        
        blurNode.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        blurNode.cornerRadius = 20
        blurNode.cornerRoundingType = .precomposited
        blurNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        gradientLayerNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width - 32,
            height: constrainedSize.max.height - 32
        )
        
        blurNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width - 32,
            height: 60
        )
        
        titleNode.style.spacingBefore = 8
        
        let titleInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: .infinity, left: 6, bottom: 12, right: 6), child: titleNode)
        let blurInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: .infinity, left: .zero, bottom: .zero, right: .zero), child: blurNode)
        
        let overlaySpec = ASOverlayLayoutSpec(child: gradientLayerNode, overlay: blurInsetSpec)
        let finalOverlaySpec = ASOverlayLayoutSpec(child: overlaySpec, overlay: titleInsetSpec)
        
        return ASInsetLayoutSpec(insets: .init(top: 16, left: 16, bottom: 16, right: 16), child: finalOverlaySpec)
    }
}

class ViewController: ASDKViewController<ASCollectionNode>, ASCollectionDataSource, ASCollectionDelegateFlowLayout, FPSCounterDelegate {
    
    var list: [Int] = []
    let queue = DispatchQueue(label: "123")
    
    func fpsCounter(_ counter: FPSCounter, didUpdateFramesPerSecond fps: Int) {
        queue.async {
            self.list.append(fps)
        }
    }
    
    
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
    
    override init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        let collectionNode = ASCollectionNode(collectionViewLayout: layout)
        super.init(node: collectionNode)
        
        collectionNode.dataSource = self
        collectionNode.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let fpsCounter = FPSCounter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        node.backgroundColor = .white
        scrollTo(item: 10)
        
        fpsCounter.delegate = self
        fpsCounter.startTracking()
    }
    
    private func scrollTo(item: Int) {
        if item < 100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.node.scrollToItem(at: IndexPath(item: item, section: 0), at: .bottom, animated: true)
                self.scrollTo(item: item + 10)
            }
        } else {
            UserDefaults.standard.setValue(Double(list.reduce(.zero, +)) / Double(list.count), forKey: "123")
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return gradients.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let gradient = gradients[indexPath.item]
        return GradientSquareNode(gradient: gradient)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let side = (view.frame.width - 24)
        return ASSizeRange(min: CGSize(width: side, height: side), max: CGSize(width: side, height: side))
    }
}
