//
//  MasterViewController.swift
//  DemoGrid
//
//  Created by Leif Terry on 11/18/19.
//  Copyright © 2019 Stella Zero. All rights reserved.
//

import Foundation
import UIKit

class Product {
    // init from JSON
    var title: String?
    var author: String?
    var imageUrl: String?

    // current state
    var imageData: Data?
    var badImage: Bool?
    var favorite: Bool?
}

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var favoriteImage: UIImageView!
}

class ProductListViewController: UITableViewController {

    var products = [Product]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        parseProducts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let product = products[indexPath.row]
                let controller = segue.destination as! DetailViewController
                controller.detailItem = product
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductTableViewCell

        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true;

        let product = products[indexPath.row]
        cell.title!.text = product.title
        if (product.author != nil) {
            cell.author!.text = product.author
        } else{
            cell.author.text = ""
        }

        if let favImage = cell.favoriteImage {
            favImage.isUserInteractionEnabled = false
            if (product.favorite!) {
                favImage.isHighlighted = true
            } else {
                favImage.isHighlighted = false
            }
        }

        if (product.imageData != nil || product.badImage!) {
            cell.thumbnail.image = UIImage(data: product.imageData!)
            cell.loadingSpinner.stopAnimating()
        } else {
            cell.thumbnail.image = nil;
            // bigger spinner
            cell.loadingSpinner.transform = CGAffineTransform(scaleX: 2.2, y: 2.2)
            cell.loadingSpinner.startAnimating()

            if (product.imageUrl != nil) {
                DispatchQueue.global(qos: .background).async {
                    let url = URL(string:(product.imageUrl)!)
                    if (url != nil) {
                        product.imageData = try? Data(contentsOf: url!)
                        if (product.imageData != nil) {
                            let image: UIImage = UIImage(data: product.imageData!)!
                            DispatchQueue.main.async {
                                cell.thumbnail.image = image
                                cell.loadingSpinner.stopAnimating()
                            }
                        }
                        else {
                            // mark image as missing so we don't kee trying to load it
                            // could also have a counter and mark it bad only after N tries
                            product.badImage = true
                        }
                    }
                }
            } else {
                // image load failed or can't be started
                cell.thumbnail.image = nil;
                cell.loadingSpinner.stopAnimating()
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            products.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    // MARK: - Logic (that maybe should be elsewhere)

    func parseProducts() {

        guard let fileUrl = Bundle.main.url(forResource: "products", withExtension: "json") else {
            print("product file not found: proucts.json")
            return
        }

        do {
            // get data from file
            let data = try Data(contentsOf: fileUrl)

            // decode data to an object Array object
            guard let dataArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] else {
                print("Could not cast JSON content as a Object array")
                return
            }

            for dict in dataArray {
                let newProd = Product()
                newProd.title = dict["title"];
                newProd.author = dict["author"];
                newProd.imageUrl = dict["imageURL"];
                newProd.badImage = false;

                let fav = UserDefaults.standard.bool(forKey:newProd.title!)
                if (fav) {
                    newProd.favorite = true;
                } else {
                    newProd.favorite = false;
                }

                products.append(newProd);
            }

        } catch {
            print("Error: \(error)")
        }

        self.tableView.reloadData()
    }
}

