//
//  PhotosViewController.swift
//  User Photos
//
//  Created by Ben on 21.01.2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class PhotosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let labelFont = UIFont.systemFont(ofSize: 17)
    
    var cache: NSCache<NSString, NSData>?
    var user: User?
    var albums = [Album]()
    var photos = [Photo]()
    
    private var userPhotos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let components = user?.name.components(separatedBy: " "), let name = components.first {
            if name != "Mrs." && name != "Mr." {
                title = "\(name)'s photos"
            } else {
                title = "\(name) \(components[1])'s photos"
            }
            
        }
        loadUserAlbums()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if previousCollectionViewWidth != collectionView.frame.width {
            collectionView.reloadData()
            previousCollectionViewWidth = collectionView.frame.width
        }
    }
    
    // MARK: - Loading Data
    
    private func loadUserAlbums() {
        guard let user = self.user else {return}
        
        var userAlbumIDs = Set<Int>()
        for album in albums {
            if album.userID == user.id {
                userAlbumIDs.insert(album.id)
            }
        }
        loadPhotos(for: userAlbumIDs)
    }
    
    private func loadPhotos(for albumIDs: Set<Int>) {
        
        for photo in photos {
            if albumIDs.contains(photo.albumID)  {
                userPhotos.append(photo)
            }
        }
        collectionView.reloadData()
        DispatchQueue.global(qos: .default).async { [weak self] in
            // fill the cashe in bg
            if let photos = self?.userPhotos {
                for photo in photos {
                    guard self != nil else {return}
                    if let url = URL(string: photo.url), let data = try? Data(contentsOf: url) {
                        self?.cache?.setObject(data as NSData, forKey: photo.url as NSString)
                    }
                }
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPhotos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.configureView(with: labelFont)
            imageCell.imageWidthConstraint.constant = width
            imageCell.cache = cache
            let photo = userPhotos[indexPath.row]
            imageCell.photo = photo
        }
    
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout helpers
    
    private var previousCollectionViewWidth: CGFloat = 0
    private let pad: CGFloat = 16
    private let labelPad: CGFloat = 8
    private var width: CGFloat {
        if collectionView.frame.width > 900 {
            return (view.frame.size.width - pad * 4) / 3
        } else if collectionView.frame.width > 600 {
            return (view.frame.size.width - pad * 3) / 2
        }
        return view.frame.size.width - pad * 2
        
    }
    
    private func labelHeightFor(indexPath: IndexPath) -> CGFloat {
        let maxSize = CGSize(width: width - labelPad * 2, height: CGFloat(MAXFLOAT))
        let text = (userPhotos[indexPath.row].title) as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: labelFont], context: nil).height
        
        return textHeight
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: width, height: width + labelHeightFor(indexPath: indexPath) + labelPad * 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return pad
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: pad, left: pad, bottom: pad, right: pad)
    }

}
