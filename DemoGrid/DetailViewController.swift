//
//  DetailViewController.swift
//  DemoGrid
//
//  Created by Leif Terry on 11/18/19.
//  Copyright © 2019 Stella Zero. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailAuthorLabel: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var favoriteImage: UIImageView!


    func configureView() {
        // update the user interface for the detail item.
        if var product = detailItem {

            // mark as favorite
            if let favImage = favoriteImage {
                if (product.favorite!) {
                    favImage.isHighlighted = true
                } else {
                    favImage.isHighlighted = false
                }
            }

            // update descriptive text
            if let label = detailTitleLabel {
                label.text = product.title
            }
            if let label = detailAuthorLabel {
                if let author = product.author {
                    label.text = author
                } else {
                    label.text = ""
                }
            }

            // set image. load it if needed.
            if let image = detailImage {
                if let data = product.imageData {
                    image.image = UIImage(data: data)
                }
                else if product.imageUrl != nil {
                    let url = URL(string:(product.imageUrl)!)
                    if (url != nil) {
                        product.imageData = try? Data(contentsOf: url!)
                        if let data = product.imageData {
                            image.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // favorite image can be tapped to toggle favorite state
        favoriteImage.isUserInteractionEnabled = true
        favoriteImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))

        // do any additional setup after loading the view.
        configureView()
    }

    @objc private func imageTapped(_ recognizer: UITapGestureRecognizer) {
        detailItem!.favorite = !(detailItem!.favorite!)
        UserDefaults.standard.set(detailItem!.favorite!, forKey: detailItem!.title!)

        if let favImage = favoriteImage {
            if (detailItem!.favorite!) {
                favImage.isHighlighted = true
            } else {
                favImage.isHighlighted = false
            }
        }
    }

    var detailItem: Product? {
        didSet {
            // update the view.
            configureView()
        }
    }


}

