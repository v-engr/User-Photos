//
//  ViewController.swift
//  User Photos
//
//  Created by Ben on 21.01.2021.
//

import UIKit

class UsersViewController: UITableViewController {
    
    
    private let cache = NSCache<NSString, NSData>()
    
    private var users = [User]()
    private var albums = [Album]()
    private var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
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
        let task = session.dataTask(with: request) {
                (data, response, error) -> Void in

            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode

            if (statusCode == 200) {

                if let data = data  {
                    let decoder = JSONDecoder()
                    if let albums = try? decoder.decode(Albums.self, from: data) {
                        self.albums = albums
                        print("Albums LOADING FINISHED")
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
                        print("Photos LOADING FINISHED")
                        
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show me photos" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            guard let photoVC = segue.destination as? PhotosViewController else {return}
            
            photoVC.user = users[indexPath.row]
            photoVC.cache = cache
            photoVC.albums = albums
            photoVC.photos = photos
        }
    }
}

