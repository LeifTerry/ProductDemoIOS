//
//  MasterViewController.swift
//  DemoGrid
//
//  Created by Leif Terry on 11/18/19.
//  Copyright © 2019 Stella Zero. All rights reserved.
//

import Foundation
import UIKit

struct Product {
    var title: String?
    var author: String?
    var imageUrl: String?
    var imageData: Data?
    var badImage: Bool?
}

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

    // xx!! image data
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Product]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        // xx!! let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        // navigationItem.rightBarButtonItem = addButton

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)

        parseProducts()
    }

/* xx!!
     @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
*/

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! Product
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductTableViewCell

        var product = objects[indexPath.row]
        cell.title!.text = product.title
        if (product.author != nil) {
            cell.author!.text = product.author
        } else{
            cell.author.text = ""
        }

        if (product.imageData != nil || product.badImage!) {
            cell.thumbnail.image = UIImage(data: product.imageData!)
            cell.loadingSpinner.stopAnimating()
        } else {
            // bigger spinner
            cell.thumbnail.image = nil;
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
                                // xx!! reload cell?
                            }
                        }
                        else {
                            product.badImage = true
                        }
                    }
                }
            } else {
                // image load failed or can't be started
                cell.thumbnail.image = nil; // xx!! show no image here
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
            objects.remove(at: indexPath.row)
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

            print(dataArray) // xx!!

            for dict in dataArray {
                var newProd = Product()
                newProd.title = dict["title"];
                newProd.author = dict["author"];
                newProd.imageUrl = dict["imageURL"];
                newProd.badImage = false;

                objects.append(newProd);
            }

        } catch {
            print("Error: \(error)")
        }

        self.tableView.reloadData()
    }
}

