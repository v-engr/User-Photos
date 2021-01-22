//
//  PhotosViewController.swift
//  User Photos
//
//  Created by Ben on 21.01.2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class PhotosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let labelFont = UIFont.systemFont(ofSize: 17)
    
    var cache: NSCache<NSString, NSData>?
    
    var user: User?
    
    private var albums = [Album]()
    private var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let components = user?.name.components(separatedBy: " "), let name = components.first {
            if name != "Mrs." && name != "Mr." {
                title = "\(name)'s photos"
            } else {
                title = "\(name) \(components[1])'s photos"
            }
            
        }
        loadAlbums()

    }
    
    // MARK: - Loading Data
    
    private func loadAlbums() {
        guard let user = self.user else {return}
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/albums")!
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
                (data, response, error) -> Void in

            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode

            if (statusCode == 200) {

                if let data = data  {
                    let decoder = JSONDecoder()
                    if let albums = try? decoder.decode(Albums.self, from: data) {
                        var userAlbumIDs = Set<Int>()
                        for album in albums {
                            if album.userID == user.id {
                                userAlbumIDs.insert(album.id)
                            }
                        }
                        self.loadPhotos(for: userAlbumIDs)
                    } else {
                        print("Albums JSON decoding failed")
                    }
                }
            } else  {
                print("Loading from Albums url Failed")
            }
        }
        task.resume()
    }
    
    private func loadPhotos(for albumIDs: Set<Int>) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/photos")!
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self]
                (data, response, error) -> Void in

            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode

            if (statusCode == 200) {

                if let data = data  {
                    let decoder = JSONDecoder()
                    if let allPhotos = try? decoder.decode(Photos.self, from: data) {
                        for photo in allPhotos {
                            if albumIDs.contains(photo.albumID)  {
                                self?.photos.append(photo)
                            }
                        }
                        DispatchQueue.main.async {
                            self?.collectionView.reloadData()
                            DispatchQueue.global(qos: .default).async { [weak self] in
                                // fill the cashe in bg
                                if let photos = self?.photos {
                                    for photo in photos {
                                        guard self != nil else {return}
                                        if let url = URL(string: photo.url), let data = try? Data(contentsOf: url) {
                                            self?.cache?.setObject(data as NSData, forKey: photo.url as NSString)
                                        }
                                    }
                                }
                            }
                        }
                        
                    } else {
                        print("Photos JSON decoding failed")
                    }
                }
            } else  {
                print("Loading from Photos url Failed")
            }
        }
        task.resume()
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.configureView(with: labelFont)
            imageCell.imageWidthConstraint.constant = width
            imageCell.cache = cache
            let photo = photos[indexPath.row]
            imageCell.photo = photo
        }
    
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout helpers
    
    let pad: CGFloat = 16
    let labelPad: CGFloat = 8
    var width: CGFloat {
        if traitCollection.horizontalSizeClass == .compact {
            return view.frame.size.width - pad * 2
        } else {
            return (view.frame.size.width - pad * 3) / 2
        }
        
    }
    
    private func labelHeightFor(indexPath: IndexPath) -> CGFloat {
        let maxSize = CGSize(width: width - labelPad * 2, height: CGFloat(MAXFLOAT))
        let text = (photos[indexPath.row].title) as NSString
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
