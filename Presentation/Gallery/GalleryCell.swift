//
//  GalleryCell.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//

import UIKit
import Combine

final class GalleryCell: UICollectionViewCell {
    static let reuseIdentifier = "GalleryCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let heartIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        imageView.tintColor = .systemPink
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    private var cancellable: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        heartIcon.isHidden = true
        cancellable?.cancel()
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(heartIcon)
        layer.cornerRadius = 8
        clipsToBounds = true

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            heartIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            heartIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            heartIcon.widthAnchor.constraint(equalToConstant: 20),
            heartIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(with photo: Photo, imagePublisher: AnyPublisher<UIImage?, Never>) {
        heartIcon.isHidden = !photo.isFavourite

        cancellable = imagePublisher
            .sink { [weak self] image in
                self?.imageView.image = image
            }
    }
}


