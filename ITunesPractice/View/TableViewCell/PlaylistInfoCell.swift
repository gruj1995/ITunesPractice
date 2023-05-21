//
//  PlaylistInfoCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import SnapKit
import UIKit

// MARK: - PlaylistInfoCell

class PlaylistInfoCell: UITableViewCell {
    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraButton.layoutIfNeeded()
        cameraButton.layer.cornerRadius = cameraButton.frame.height * 0.5
    }

    // MARK: Internal

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    func configure(name: String, imageUrl: URL?, menu: UIMenu?) {
        coverImageView.loadImage(
            with: imageUrl,
            placeholder: AppImages.catCircle
        )
        textView.text = name
        cameraButton.menu = menu
    }

    // MARK: Private

    var textChanged: ((String) -> Void)?

    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .appColor(.gray1)
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        let cameraConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold, scale: .medium)
        button.setImage(AppImages.cameraFill?.withConfiguration(cameraConfiguration), for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.tintColor = .darkGray
        button.backgroundColor = .lightGray
        button.clipsToBounds = true
        return button
    }()

    private lazy var textView: PlaceholderTextView = {
        let textView = PlaceholderTextView()
        textView.delegate = self
        textView.font = .systemFont(ofSize: 20, weight: .semibold)
        textView.textColor = .white
        textView.tintColor = .appColor(.red1)
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.placeholder = "播放列表名稱".localizedString()
        return textView
    }()

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }

    private func setupLayout() {
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(coverImageView.snp.width)
        }

        contentView.addSubview(cameraButton)
        cameraButton.snp.makeConstraints { make in
            make.center.equalTo(coverImageView)
            make.width.height.equalTo(30)
        }

        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
    }
}

// MARK: UITextViewDelegate

extension PlaylistInfoCell: UITextViewDelegate {
    /// 開始編輯
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // 移動游標到文字末端
        DispatchQueue.main.async {
            let newPosition = textView.endOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        textChanged?(newString)
        return true
    }
}