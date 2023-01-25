//
//  ViewController.swift
//  favoritePlaces_rishivarma_c0880853
//
//  Created by RISHI VARMA on 2023-01-24.
//

import UIKit
import CoreData
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private var models = [String]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }

    @IBOutlet weak var favouritePlaces: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favourite Places"
        favouritePlaces.delegate = self
        favouritePlaces.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd(){
        performSegue(withIdentifier: "second", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "second" {
            guard let vc = segue.destination as? vcMapView else { return }
            vc.delegate = self
        }
    }
    ////        extension ViewController: vcMapViewDelegate {
    ////        func didAddPlace(name: String, country: String) {
    ////        createItem(name: name, country: country)
    ////        }
    ////        }    
    
}



    
