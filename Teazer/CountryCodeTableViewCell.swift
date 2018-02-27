//
//  CountryCodeTableViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 09/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class CountryCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var countryLbl: UILabel!
    
    func setupCell(country:Country) {
        if let imageName = country.code {
            mapImageView.image = UIImage(named: imageName.lowercased())
        }
        countryLbl.text = country.name ?? ""
    }

}
