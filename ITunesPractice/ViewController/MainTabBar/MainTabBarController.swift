//
//  MainTabBarController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Combine
import SnapKit
import UIKit

// MARK: - MainTabBarController

class MainTabBarController: UITabBarController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        addChildView()
        setupUI()
    }

    // MARK: Private

    // 迷你音樂播放器
    lazy var miniPlayerVC = MiniPlayerViewController()

    private var cancellables = Set<AnyCancellable>()

    private func setupUI() {
        setTabBarAppearance()
        setTabBarItems()
        setupLayout()
    }

    private func setTabBarItems() {
        let searchVC = SearchViewController()
        let searchNavVC = createNavigationController(rootViewController: searchVC, image: AppImages.magnifyingGlass, title: "搜尋".localizedString())

        let libraryVC = LibraryViewController()
        let libraryNavVC = createNavigationController(rootViewController: libraryVC, image: AppImages.musicHouse, title: "資料庫".localizedString())

        let audioSearchVC = AudioSearchViewController()
        let audioSearchNavVC = createNavigationController(rootViewController: audioSearchVC, image: AppImages.waveformAndMic, title: "聲音搜尋".localizedString())

        let cloudVC = CloudViewController()
        let cloudNavVC = createNavigationController(rootViewController: cloudVC, image: AppImages.personICloudFill, title: "資源".localizedString())

        viewControllers = [searchNavVC, audioSearchNavVC, libraryNavVC, cloudNavVC]
    }

    private func createNavigationController(rootViewController: UIViewController, image: UIImage?, title: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        navController.tabBarItem.title = title
        return navController
    }

    private func addChildView() {
        view.addSubview(miniPlayerVC.view)
        addChild(miniPlayerVC)
        miniPlayerVC.didMove(toParent: self)
    }

    private func setupLayout() {
        miniPlayerVC.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(tabBar.snp.top)
            make.height.equalTo(64)
        }
    }

    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        // 模糊效果樣式(可調亮/暗程度)
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        // Set all possible tab bar item styles as necessary (based on rotation and size capabilities).  Here
        // we're setting all three available appearances
        setTabBarItemColors(appearance.stackedLayoutAppearance)
        setTabBarItemColors(appearance.inlineLayoutAppearance)
        setTabBarItemColors(appearance.compactInlineLayoutAppearance)
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance) {
        // tabbar 標籤未被選取時的顏色
        itemAppearance.normal.iconColor = .lightGray
        itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]

        // tabBar 標籤被選取時的顏色
        itemAppearance.selected.iconColor = .appColor(.red1)
        itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appColor(.red1)!]
    }
}

// MARK: UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {
    // 切換tabbar觸發
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        if let viewControllers, viewControllers.count == 3 {
//            miniPlayerVC.view.isHidden = viewController == viewControllers[1]
//        }
    }
}
