//
//  Model.swift
//  User Photos
//
//  Created by Ben on 21.01.2021.
//

import Foundation

class Model {
    
    var delegate: ModelDelegate?
    
    let cache = NSCache<NSString, NSData>()
    
    var areUsersLoaded = false {
        didSet {
            if isFullyLoaded {
                delegate?.modelDidFullLoad()
            }
        }
    }
    
    var areAlbumsLoaded = false {
        didSet {
            if isFullyLoaded {
                delegate?.modelDidFullLoad()
            }
        }
    }
    
    var arePhotosLoaded = false {
        didSet {
            if isFullyLoaded {
                delegate?.modelDidFullLoad()
            }
        }
    }
    
    var isFullyLoaded: Bool {
        return areUsersLoaded && areAlbumsLoaded && arePhotosLoaded
    }
    
    var users = Users()
    var albums = Albums()
    var photos = Photos()
    
    func load() {
        loadUsers()
        loadAlbums()
        loadPhotos()
    }
    
    private func loadUsers() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self]
                (data, response, error) -> Void in

            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode

            if (statusCode == 200) {

                if let data = data  {
                    let decoder = JSONDecoder()
                    if let jsonUsers = try? decoder.decode(Users.self, from: data) {
                        self?.users = jsonUsers
                        self?.areUsersLoaded = true
                        self?.delegate?.modelDidLoadUsers()
                    } else {
                        print("JSON decoding failed")
                    }
                }
            } else  {
                print("Loading from url Failed")
            }
        }
        task.resume()
    }
    
    private func loadAlbums() {
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/albums")!
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self]
                (data, response, error) -> Void in

            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode

            if (statusCode == 200) {

                if let data = data  {
                    let decoder = JSONDecoder()
                    if let albums = try? decoder.decode(Albums.self, from: data) {
                        self?.albums = albums
                        self?.areAlbumsLoaded = true
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

    private func loadPhotos() {
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
                        self?.photos = allPhotos
                        self?.arePhotosLoaded = true
                        // fill the cashe in bg
                        DispatchQueue.global(qos: .default).async { [weak self] in
                            if let photos = self?.photos {
                                for photo in photos {
                                    guard self != nil else {return}
                                    if let url = URL(string: photo.thumbnailURL), let data = try? Data(contentsOf: url) {
                                        self?.cache.setObject(data as NSData, forKey: photo.thumbnailURL as NSString)
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
}

protocol ModelDelegate {
    func modelDidLoadUsers()
    func modelDidFullLoad()
}

extension ModelDelegate {
    func modelDidLoadUsers() { }
    func modelDidFullLoad() { }
}

// MARK: - Photo
struct Photo: Codable {
    let albumID, id: Int
    let title: String
    let url, thumbnailURL: String

    enum CodingKeys: String, CodingKey {
        case albumID = "albumId"
        case id, title, url
        case thumbnailURL = "thumbnailUrl"
    }
}

typealias Photos = [Photo]

// MARK: - Album
struct Album: Codable {
    let userID, id: Int
    let title: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title
    }
}

typealias Albums = [Album]

// MARK: - User
struct User: Codable {
    let id: Int
    let name, username, email: String
    let address: Address
    let phone, website: String
    let company: Company
}

// MARK: - Address
struct Address: Codable {
    let street, suite, city, zipcode: String
    let geo: Geo
}

// MARK: - Geo
struct Geo: Codable {
    let lat, lng: String
}

// MARK: - Company
struct Company: Codable {
    let name, catchPhrase, bs: String
}

typealias Users = [User]
