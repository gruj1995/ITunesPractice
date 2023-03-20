//
//  MainTabBarController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import SnapKit
import Combine
import UIKit

class MainTabBarController: UITabBarController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        setupUI()
    }

    // MARK: Private

    // mini 音樂播放器
    private lazy var miniPlayerVC = MiniPlayerViewController()

    private var cancellables = Set<AnyCancellable>()

    private func setupUI() {
        setTabBarAppearance()
        setTabBarItems()
        setupLayout()
    }

    private func setTabBarItems() {
        let searchVC = SearchViewController()
        let searchNavVC = UINavigationController(rootViewController: searchVC)
        searchNavVC.tabBarItem.image = AppImages.magnifyingGlass
        searchNavVC.tabBarItem.title = "搜尋".localizedString()

        let libraryVC = LibraryViewController()
        let libraryNavVC = UINavigationController(rootViewController: libraryVC)
        libraryNavVC.tabBarItem.image = AppImages.musicHouse
        libraryNavVC.tabBarItem.title = "資料庫".localizedString()

        viewControllers = [searchNavVC, libraryNavVC]
    }

    private func addChildView() {
        view.addSubview(miniPlayerVC.view)
        addChild(miniPlayerVC)
        miniPlayerVC.didMove(toParent: self)

        // TODO: 放在這邊是否破壞MVVM架構？
        miniPlayerVC.view
            .gesture(.tap())
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.presentPlaylistVC()
            }.store(in: &cancellables)
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

    private func presentPlaylistVC() {
        let vc = PlayListViewController()
        // fullScreen 背景遮罩會是黑色的，所以設 overFullScreen
        vc.modalPresentationStyle = .overFullScreen
        FloatingPanelManager.shared.set(contentVC: vc, layoutType: .modalFullScreen, track: vc.tableView)
        FloatingPanelManager.shared.show(on: self)
    }
}
