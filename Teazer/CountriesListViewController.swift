//
//  CountriesListViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 09/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class CountriesListViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    typealias CountrySelectedBlock = (Country) -> Void
    var countrySelectedBlock:CountrySelectedBlock!
    var dataSource:[Country]!
    var originalDataSource:[Country]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        var dialCodesDS = DialCodesDataSource()
        dialCodesDS.parseJSON()
        originalDataSource = dialCodesDS.countriesList
        dataSource = Array(originalDataSource)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        searchView.layer.borderWidth = 0.5
        searchView.layer.borderColor = UIColor(rgba: "#B2B2B2").cgColor
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CountriesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCodeTableViewCell") as! CountryCodeTableViewCell
        cell.setupCell(country: dataSource[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.countrySelectedBlock(strongSelf.dataSource[indexPath.row])
        }
    }
    
}

extension CountriesListViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        dataSource = originalDataSource.filter { (country) -> Bool in
            if let name = country.name {
                if name.lowercased().range(of: textField.text!.lowercased()) != nil {
                    return true
                }
            }
            return false
        }
        tableView.reloadData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
