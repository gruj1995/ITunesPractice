//
//  CurrentTrackView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/27.
//

import SnapKit
import UIKit
import MarqueeLabel

// MARK: - CurrentTrackView

class CurrentTrackView: UIView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func layoutSubviews() {
        super.layoutSubviews()
        menuButtonBackgroundLayer.frame = menuButton.bounds
        menuButtonBackgroundLayer.cornerRadius = menuButton.bounds.height * 0.5
    }

    func configure(trackName: String, artistName: String?) {
        // 讓左邊多出一塊空間滿足UI效果所以加上 \t
        trackLabel.text = "\t\(trackName)"
        if let artistName = artistName {
            artistLabel.text = "\t\(artistName)"
            artistLabel.isHidden = false
        } else {
            artistLabel.isHidden = true
        }
    }

    // MARK: Private

    private lazy var menuButtonBackgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(white: 1, alpha: 0.1).cgColor
        return layer
    }()

    private lazy var menuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(AppImages.ellipsis, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.layer.insertSublayer(menuButtonBackgroundLayer, at: 0)
        return button
    }()

    private lazy var trackLabel: MarqueeLabel = getMarqueeLabel(textColor: .white)

    private lazy var artistLabel: MarqueeLabel = getMarqueeLabel(textColor: .lightText)

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackLabel, artistLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.backgroundColor = .clear
        return stackView
    }()

    private func setupUI() {
        backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(50)
            make.centerY.equalToSuperview()
        }

        addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.leading.equalTo(stackView.snp.trailing).offset(20)
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(27)
        }
    }

    private func getMarqueeLabel(textColor: UIColor) -> MarqueeLabel {
        let label = MarqueeLabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = textColor

        // 跑馬燈相關參數設置
        label.type = .continuous // 向左滾動
        label.animationDelay = 3 // 跑馬燈跑完一輪後暫停時間
        label.speed = .rate(30) // 每秒移動多少pt
        label.fadeLength = 20 // 左右淡出效果長度
        return label
    }
}