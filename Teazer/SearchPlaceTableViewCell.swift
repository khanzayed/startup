//
//  SearchPlaceTableViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 10/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class SearchPlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var vicinityLbl: UILabel!
    
    func setupCellForNearByPlaces(nearByPlace:GooglePlace) {
        locationLbl.text = nearByPlace.title
        vicinityLbl.text = nearByPlace.vicinity
    }
    
    func setupCellForAutocompleteResult(autocompleteResult:GooglePlace) {
        locationLbl.text = autocompleteResult.title
        vicinityLbl.text = autocompleteResult.vicinity
    }
    
}
