//
//  DetailViewController.swift
//  InternGallery
//
//  Created by Ilya on 10.05.2026.
//

import UIKit

final class DetailViewController: UIViewController {
    
    private var photos: [Photo]
    private var currentIndex: Int
    
    // Коллекция для свайпов
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(DetailPhotoCell.self, forCellWithReuseIdentifier: "DetailPhotoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return button
    }()

    init(photos: [Photo], startIndex: Int) {
        self.photos = photos
        self.currentIndex = startIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateFavoriteButton()
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: self.currentIndex, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(collectionView)
        view.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            favoriteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            favoriteButton.widthAnchor.constraint(equalToConstant: 50),
            favoriteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func favoriteTapped() {
        let photo = photos[currentIndex]
        if CoreDataManager.shared.isFavorite(id: photo.id) {
            CoreDataManager.shared.removeFavorite(id: photo.id)
        } else {
            CoreDataManager.shared.saveFavorite(photo: photo)
        }
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let isFav = CoreDataManager.shared.isFavorite(id: photos[currentIndex].id)
        let image = isFav ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favoriteButton.setImage(image, for: .normal)
        favoriteButton.tintColor = isFav ? .systemRed : .white
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailPhotoCell", for: indexPath) as! DetailPhotoCell
        cell.configure(with: photos[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentIndex = Int(scrollView.contentOffset.x / width)
        updateFavoriteButton()
    }
}
