//
//  AudioSearchViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import Combine
import SnapKit
import UIKit

// MARK: - AudioSearchViewController

class AudioSearchViewController: UIViewController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        startAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        navigationController?.navigationBar.isHidden = false
    }

    // MARK: Private

    private let viewModel: AudioSearchViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []
    private var timer: Timer?

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "輕觸 Shazam".localizedString()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private lazy var micImageView: UIImageView = {
        let imageView = UIImageView(image: AppImages.micFill)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var hintStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [micImageView, hintLabel])
        stackView.axis = .horizontal
        stackView.spacing = 3
        return stackView
    }()

    private lazy var shazamImageView: UIImageView = {
        let imageView = UIImageView(image: AppImages.shazamLarge)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private func setupUI() {
        view.backgroundColor = .black
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(shazamImageView)
        shazamImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(shazamImageView.snp.width)
        }

        view.addSubview(hintStackView)
        hintStackView.snp.makeConstraints { make in
            make.bottom.equalTo(shazamImageView.snp.top).offset(-40)
            make.centerX.equalToSuperview()
        }
    }

    private func bindViewModel() {
        // 使用 $ 屬性獲取 @Published 屬性的 Publisher，監聽數據模型的變化
//        viewModel.$tracks
//            .receive(on: RunLoop.main)
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//                self.tableView.reloadData()
//            }.store(in: &cancellables)
    }

    private func startAnimation() {
        let animationDuration = 1.0         // 動畫持續時間
        let animationScale: CGFloat = 1.05   // 縮放比例

        // 创建动画缩放的transform
        let transform = CABasicAnimation(keyPath: AnimationKeyPath.transformScale.rawValue)
        transform.fromValue = 1.0
        transform.toValue = animationScale
        transform.duration = animationDuration
        transform.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // 動畫過度方式
        transform.autoreverses = true // 是否自動反向播放
        transform.repeatCount = .infinity

        shazamImageView.layer.add(transform, forKey: "shazamImageScaleAnimation")
    }

    private func stopAnimation() {
        shazamImageView.layer.removeAllAnimations()
    }
}
