import UIKit

final class TabBarController: UITabBarController {
    static let shared = TabBarController()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        let gameVC = UINavigationController(
            rootViewController: GameViewController()
        )
        let generatorVC = UINavigationController(
            rootViewController: GeneratorViewController()
        )
        let statisticsVC = UINavigationController(
            rootViewController: StatisticsViewController()
        )
        let settingsVC = UINavigationController(
            rootViewController: SettingsViewController()
        )

        gameVC.tabBarItem = UITabBarItem(
            title: L.game(),
            image: UIImage(systemName: "square.fill.on.square.fill"),
            tag: 0
        )

        generatorVC.tabBarItem = UITabBarItem(
            title: L.generator(),
            image: UIImage(systemName: "123.rectangle.fill"),
            tag: 1
        )

        statisticsVC.tabBarItem = UITabBarItem(
            title: L.statistics(),
            image: UIImage(systemName: "arrow.down.left.arrow.up.right.square.fill"),
            tag: 2
        )
        
        settingsVC.tabBarItem = UITabBarItem(
            title: L.settings(),
            image: UIImage(systemName: "gearshape.fill"),
            tag: 3
        )

        let viewControllers = [gameVC, generatorVC, statisticsVC, settingsVC]
        self.viewControllers = viewControllers

        setTabBarBackground()
        updateTabBar()
    }
    
    func updateTabBar() {
        tabBar.backgroundColor = .white.withAlphaComponent(0.5)
        tabBar.tintColor = UIColor(hex: "#01D451")
        tabBar.unselectedItemTintColor = UIColor(hex: "#999999")
        tabBar.itemPositioning = .automatic
    }
    
    func setTabBarBackground() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tabBar.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tabBar.insertSubview(blurEffectView, at: 0)
    }
}
