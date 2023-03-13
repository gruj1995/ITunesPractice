//
//  MiniPlayerViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/13.
//

import SnapKit
import Kingfisher
import UIKit

// 參考 https://github.com/LeoNatan/LNPopupController
class MiniPlayerViewController: UIViewController {
    // MARK: Internal

    var isPlaying: Bool = false {
        didSet {
            let image = isPlaying ? AppImages.pause : AppImages.play
            playPauseButton.setImage(image, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }

    func updateUI() {
//        coverImageView.kf.setImage(with: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Features115/v4/2a/e1/fc/2ae1fc34-a98d-20bf-33ed-71e321773b0a/dj.lykipmdm.jpg/100x100bb.jpg"))
        coverImageView.image = AppImages.musicNote
        songTitleLabel.text = "鄧紫棋-倒數"
    }

    // MARK: Private

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()

    // 毛玻璃效果
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }()

    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var songTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    private lazy var playPauseButton: RippleEffectButton = {
        let button = RippleEffectButton()
        var config = UIButton.Configuration.borderless()
        config.buttonSize = .large
        config.image = AppImages.play
        config.baseForegroundColor = .white
        button.configuration = config
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var nextButton: RippleEffectButton = {
        let button = RippleEffectButton()
        var config = UIButton.Configuration.borderless()
        config.buttonSize = .large
        config.image = AppImages.forward
        config.baseForegroundColor = .white
        button.configuration = config
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    private func setupUI() {
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(coverImageView)
        view.addSubview(songTitleLabel)
        view.addSubview(playPauseButton)
        view.addSubview(nextButton)
        view.addSubview(separatorView)

        coverImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(coverImageView.snp.height)
        }

        songTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(coverImageView.snp.trailing).offset(8)
        }

        playPauseButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalTo(songTitleLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.width.height.centerY.equalTo(playPauseButton)
            make.leading.equalTo(playPauseButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(20)
        }

        view.insertSubview(blurView, at: 0)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        separatorView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(0.3)
        }
    }

    @objc
    private func playPauseButtonTapped(_ sender: UIButton) {
        isPlaying.toggle()
    }

    @objc
    private func nextButtonTapped(_ sender: UIButton) {

    }
}
