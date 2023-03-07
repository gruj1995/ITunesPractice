//
//  MainTabBarController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import UIKit

class MainTabBarController: UITabBarController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: Private

    private func setupUI() {
        setTabBarAppearance()

        let searchVC = SearchViewController2()
        let searchNavVC = UINavigationController(rootViewController: searchVC)
        searchNavVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchNavVC.tabBarItem.title = "搜尋".localizedString()

        let libraryVC = LibraryViewController()
        let libraryNavVC = UINavigationController(rootViewController: libraryVC)
        libraryNavVC.tabBarItem.image = UIImage(systemName: "music.note.house.fill")
        libraryNavVC.tabBarItem.title = "資料庫".localizedString()

        viewControllers = [searchNavVC, libraryNavVC]
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
