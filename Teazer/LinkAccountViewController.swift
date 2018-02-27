//
//  linkAccountViewController.swift
//  Teazer
//
//  Created by Mraj singh on 30/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class LinkAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func goBackToSettings(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
