//
//  DetailViewController.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//

import UIKit
import Combine

final class DetailViewController: UIViewController {

    private let viewModel: DetailViewModel
    private var cancellables = Set<AnyCancellable>()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var favouriteButton: UIBarButtonItem = {
        UIBarButtonItem(image: heartImage(filled: false), style: .plain, target: self, action: #selector(didTapFavourite))
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = favouriteButton

        let infoStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, descriptionLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(activityIndicator)
        view.addSubview(infoStack)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55),

            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            infoStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            infoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    private func bindViewModel() {
        viewModel.$currentIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateUI() }
            .store(in: &cancellables)

        viewModel.$photos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateFavouriteButton() }
            .store(in: &cancellables)
    }

    private func updateUI() {
        let photo = viewModel.currentPhoto
        titleLabel.text = photo.title
        authorLabel.text = "by \(photo.authorName)"
        descriptionLabel.text = photo.description
        updateFavouriteButton()
        loadImage(from: photo.regularURL)
    }

    private func loadImage(from url: URL) {
        imageView.image = nil
        activityIndicator.startAnimating()

        viewModel.loadImage(from: url)
            .sink { [weak self] image in
                self?.activityIndicator.stopAnimating()
                UIView.transition(with: self?.imageView ?? UIImageView(), duration: 0.2, options: .transitionCrossDissolve) {
                    self?.imageView.image = image
                }
            }
            .store(in: &cancellables)
    }

    private func updateFavouriteButton() {
        favouriteButton.image = heartImage(filled: viewModel.currentPhoto.isFavourite)
        favouriteButton.tintColor = viewModel.currentPhoto.isFavourite ? .systemPink : .label
    }

    private func heartImage(filled: Bool) -> UIImage? {
        UIImage(systemName: filled ? "heart.fill" : "heart")
    }

    @objc private func didTapFavourite() {
        viewModel.toggleFavourite()
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            viewModel.goNext()
        case .right:
            viewModel.goPrevious()
        default:
            break
        }
    }
}

