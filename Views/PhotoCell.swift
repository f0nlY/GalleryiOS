//
//  PhotoCell.swift
//  InternGallery
//
//  Created by Ilya on 10.05.2026.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    static let identifier = "PhotoCell"
    
    private var imageLoadTask: URLSessionDataTask?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let favoriteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(favoriteIcon)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            favoriteIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            favoriteIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 20),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with photo: Photo, isFavorite: Bool) {
            favoriteIcon.isHidden = !isFavorite
            imageLoadTask?.cancel()
            
            imageLoadTask = ImageLoader.loadImage(from: photo.urls.small) { [weak self] image in
                self?.imageView.image = image
            }
        }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageView.image = nil
        favoriteIcon.isHidden = true
    }
}
