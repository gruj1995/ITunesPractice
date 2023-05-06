//
//  CurrentTrackView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/27.
//

import MarqueeLabel
import SnapKit
import UIKit

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

    func configure(trackName: String, artistName: String?, menu: UIMenu?) {
        // 讓左邊多出一塊空間滿足UI效果所以加上 \t
        trackLabel.text = "\t\(trackName)"
        if let artistName = artistName {
            artistLabel.text = "\t\(artistName)"
            artistLabel.isHidden = false
        } else {
            artistLabel.isHidden = true
        }

        menuButton.menu = menu
    }

    // MARK: Private

    private lazy var menuButton: CircleButton = {
        let button = CircleButton()
        button.tintColor = .white
        button.setImage(AppImages.ellipsis, for: .normal)
        button.showsMenuAsPrimaryAction = true // 預設選單是長按出現，將這個值設為 true 可以讓選單在點擊時也出現
        return button
    }()

    private lazy var trackLabel: MarqueeLabel = createMarqueeLabel(textColor: .white)

    private lazy var artistLabel: MarqueeLabel = createMarqueeLabel(textColor: .lightText)

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

    // TODO: 讓比較早滾動完的label等待未滾完的，到齊後再一起等待指定秒數後開始下一輪
    private func createMarqueeLabel(textColor: UIColor) -> MarqueeLabel {
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
