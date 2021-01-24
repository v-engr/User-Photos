//
//  ViewController.swift
//  User Photos
//
//  Created by Ben on 21.01.2021.
//

import UIKit

class UsersViewController: UITableViewController, ModelDelegate {
    
    
    private var model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.delegate = self
        model.load()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.users[indexPath.row].name
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show me photos" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            guard let photoVC = segue.destination as? PhotosViewController else {return}
            
            photoVC.selectedUserIndex = indexPath.row
            photoVC.model = model
        }
    }
    
    // MARK: - ModelDelegate
    
    func modelDidLoadUsers() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

