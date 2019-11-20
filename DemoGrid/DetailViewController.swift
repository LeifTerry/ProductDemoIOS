//
//  DetailViewController.swift
//  DemoGrid
//
//  Created by Leif Terry on 11/18/19.
//  Copyright © 2019 Stella Zero. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.title
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: Product? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

