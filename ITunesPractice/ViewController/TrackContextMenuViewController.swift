//
//  TrackContextMenuViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/3.
//

import SnapKit
import UIKit

// MARK: - TrackContextMenuViewController

class TrackContextMenuViewController: UIViewController {
    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    var track: Track?

    // MARK: - Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        coverImageView.layoutIfNeeded()
    }

    // MARK: Private

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .lightText
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return imageView
    }()

    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 2
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var artistNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.textColor = .lightGray
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var albumInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackNameLabel, artistNameLabel, albumInfoLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.distribution = .equalCentering
        return stackView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [coverImageView, infoStackView, arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private func setupLayout() {
        coverImageView.snp.makeConstraints { make in
            make.width.equalTo(coverImageView.snp.height)
        }

        albumInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(10)
        }

        view.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }

    private func setupUI() {
        view.backgroundColor = .appColor(.gray2)
        setupLayout()

        guard let track = track else { return }
        coverImageView.kf.setImage(with: URL(string: track.artworkUrl100))
        trackNameLabel.text = track.trackName
        artistNameLabel.text = track.artistName
        albumInfoLabel.text = "\(track.collectionName) · \(track.releaseDateValue?.toString(dateFormat: "yyyy年") ?? "") "
    }
}
