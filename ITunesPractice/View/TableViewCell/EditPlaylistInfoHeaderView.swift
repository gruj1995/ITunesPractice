//
//  EditPlaylistInfoHeaderView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/21.
//

import SnapKit
import UIKit

// MARK: - EditPlaylistInfoHeaderView

class EditPlaylistInfoHeaderView: UITableViewHeaderFooterView {
    // MARK: Lifecycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    var textChanged: ((String) -> Void)?

    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraButton.layoutIfNeeded()
        cameraButton.layer.cornerRadius = cameraButton.frame.height * 0.5
    }

    func configure(name: String, imageUrl: URL?, menu: UIMenu?) {
        textView.text = name
        cameraButton.menu = menu
        coverImageView.loadImage(
            with: imageUrl,
            placeholder: AppImages.catMushroom
        )
    }

    // MARK: Private

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
        textView.placeholderAlignment = .top
        return textView
    }()

    private func setupUI() {
        backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(coverImageView.snp.width)
        }

        addSubview(cameraButton)
        cameraButton.snp.makeConstraints { make in
            make.center.equalTo(coverImageView)
            make.width.height.equalTo(30)
        }

        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(10)
        }
    }
}

// MARK: UITextViewDelegate

extension EditPlaylistInfoHeaderView: UITextViewDelegate {
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
