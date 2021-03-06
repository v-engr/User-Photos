//
//  ImageCollectionViewCell.swift
//  User Photos
//
//  Created by Ben on 21.01.2021.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    
    var cache: NSCache<NSString, NSData>?
    var photo: Photo? {
        didSet {
            titleLabel.text = photo?.title
            loadImageData()
        }
    }
    
    @IBOutlet var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    private func loadImageData() {
        guard let photo = self.photo else {return}
        imageView.image = nil
        spinner.isHidden = false
        spinner.startAnimating()
        
        if let cachedData = cache?.object(forKey: photo.url as NSString),
           let image = UIImage(data: cachedData as Data) {
            imageView.image = image
            spinner.stopAnimating()
            spinner.isHidden = true
            
        } else {
            if let cachedData = cache?.object(forKey: photo.thumbnailURL as NSString),
               let image = UIImage(data: cachedData as Data) {
                if imageView.image == nil {
                    imageView.image = image
                }
            }
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                // downloading a highres
                if let url = URL(string: photo.url), let data = try? Data(contentsOf: url) {
                    self?.cache?.setObject(data as NSData, forKey: photo.url as NSString)
                    if let image = UIImage(data: data), photo.id == self?.photo?.id {
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                            self?.spinner.stopAnimating()
                            self?.spinner.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    private var isConfigured = false
    
    func configureView(with font: UIFont) {
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .init(width: 0, height: 0)
        layer.shadowRadius = 2
        
        contentView.layer.cornerRadius = 5
        
        titleLabel.font = font
        
        isConfigured = true
    }
    
}
