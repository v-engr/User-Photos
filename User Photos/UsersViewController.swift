//
//  ViewController.swift
//  User Photos
//
//  Created by Ben on 21.01.2021.
//

import UIKit

class UsersViewController: UITableViewController {
    
    
    private let cache = NSCache<NSString, NSData>()
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUsers()
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
//            photoVC.userIndex = indexPath.row
//            photoVC.users = users
        }
    }
}

