//
//  TrackCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/20.
//

import Lottie
import UIKit

class TrackCell: UITableViewCell {
    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    // MARK: Internal

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        coverImageView.layoutIfNeeded()
    }

    func configure(artworkUrl: String, collectionName: String, artistName: String, trackName: String, showsHighlight: Bool = false) {
        let url = URL(string: artworkUrl)
        coverImageView.loadCoverImage(with: url)
        trackNameLabel.text = trackName
        albumInfoLabel.text = "\(artistName) · \(collectionName)"
        albumInfoLabel.isHidden = artistName.isEmpty && collectionName.isEmpty
        highlightIfNeeded(showsHighlight)
    }

    // 右邊選單按鈕
    func addRightMenuButton(_ track: Track) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setImage(AppImages.ellipsis?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.menu = ContextMenuManager.shared.createTrackMenu(track, menuTypes: [.addOrRemoveFromLibrary, .editPlaylist, .share])
        button.showsMenuAsPrimaryAction = true // 預設選單是長按出現，將這個值設為 true 可以讓選單在點擊時也出現
        accessoryView = button
    }

    func updateAnimationState(showAnimation: Bool, isPlaying: Bool) {
        animationContainerView.isHidden = !showAnimation
        isPlaying ? animationView.play() : animationView.pause()
    }

    // MARK: Private

    private lazy var coverImageView: UIImageView = .coverImageView()

    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()

    private lazy var albumInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13)
        label.textColor = .lightText
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackNameLabel, albumInfoLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var animationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "musiclist")
        animationView.loopMode = .loop // 設定動畫循環模式 (.playOnce 播放一次, .loop 重複)
        animationView.backgroundBehavior = .pauseAndRestore // app跳到背景狀態時，暫停並保留動畫，回來繼續播
        animationView.contentMode = .scaleAspectFit
        return animationView
    }()

    private lazy var animationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.isHidden = true
        return view
    }()

    private func highlightIfNeeded(_ showsHighlight: Bool) {
        selectionStyle = showsHighlight ? .default : .none
        if showsHighlight {
            // 更改預設的 highlight 顏色
            let backgroundView = UIView()
            backgroundView.backgroundColor = .appColor(.gray5)
            selectedBackgroundView = backgroundView
        }
    }

    private func setupUI() {
        backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.top.bottom.equalToSuperview().inset(5)
            make.width.equalTo(coverImageView.snp.height)
        }

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView.snp.trailing).offset(15)
            make.trailing.equalTo(contentView.snp.trailingMargin)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(animationContainerView)
        animationContainerView.snp.makeConstraints { make in
            make.edges.equalTo(coverImageView)
        }

        animationContainerView.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
