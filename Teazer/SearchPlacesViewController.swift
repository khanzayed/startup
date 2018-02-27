//
//  SearchPlacesViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 10/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

class SearchPlacesViewController: UIViewController {
    
    typealias LocationSelectedBlock = (GooglePlace?) -> Void
    var locationSelectedBlock:LocationSelectedBlock?

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var turnOnLocationView: UIView!
    @IBOutlet weak var turnOnLocationBtn: UIButton!
    
    
    var autoCompletedataSource = [GooglePlace]()
    var nearByPlacesDataSource = [GooglePlace]()
    var location:Location!
    var bounds:GMSCoordinateBounds?
    var loaderView:LoaderView!
    var isAutoCompleteSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        let isLocationEnabled = Location().isAuthorised()
        searchTextField.isEnabled = isLocationEnabled
        searchBtn.isEnabled = isLocationEnabled
        turnOnLocationView.isHidden = isLocationEnabled
        turnOnLocationBtn.isEnabled = !isLocationEnabled
        
        searchView.layer.borderWidth = 0.5
        searchView.layer.borderColor = UIColor(rgba: "#B2B2B2").cgColor
        
        if isLocationEnabled {
            fetchCurrentLocation()
        }
    }
    
    func setupLocationManager() {
        location = Location()
        location.locationEnabledBlock = { [weak self] (status) in
            DispatchQueue.main.async {
                if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
                    self?.loaderView.removeLoaderView()
                    ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Location Services", actionTitle: "Settings", message: "Enable location services fomr the settings.", forVC: self, completionBlock: { (action) in
                        DispatchQueue.main.async {
                            let url = URL(string: UIApplicationOpenSettingsURLString)!
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                    return
                }
                let isEnabled = (status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways) ? true : false
                self?.searchTextField.isEnabled = isEnabled
                self?.searchBtn.isEnabled = isEnabled
                self?.turnOnLocationView.isHidden = isEnabled
                self?.turnOnLocationBtn.isEnabled = !isEnabled
            }
        }
        location.locationReceivedBlock = { [weak self] (location, error) in
            DispatchQueue.main.async {
                if error != nil {
                    DispatchQueue.main.async {
                        self?.loaderView.removeLoaderView()
                        self?.searchTextField.isEnabled = true
                        self?.searchBtn.isEnabled = true
                    }
                    ErrorView().showBasicAlertForError(title: "Location Services", message: error!.localizedDescription, forVC: self)
                    return
                }
                if let startCoordinate = location {
                    let lat = startCoordinate.coordinate.latitude
                    let long = startCoordinate.coordinate.longitude
                    let offset = 200.0 / 1000.0;
                    let latMax = lat + offset;
                    let latMin = lat - offset;
                    let lngOffset = offset * cos(lat * .pi / 200.0);
                    let lngMax = long + lngOffset;
                    let lngMin = long - lngOffset;
                    let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
                    let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
                    self?.bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
                    self?.fetchNearByPlaces(location: startCoordinate)
                }
            }
        }
    }
    
    func fetchCurrentLocation() {
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView.addLoaderView(forView: self?.view)
            self?.searchTextField.isEnabled = false
            self?.searchBtn.isEnabled = false
        }
        location.initialiseLocationManager()
    }
    
    func fetchNearByPlaces(location:CLLocation) {
        let params:[String:Any] = [
            "key":"AIzaSyDfORXkPzB_xrUh5iqb-h5idzFhkqw483c",
            "location":"\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "type":"restaurant",
            "radius":1000
        ]
        GooglePlacesAPIHandler().fetchNearByPlaces(params: params, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView.removeLoaderView()
                self?.searchTextField.isEnabled = true
                self?.searchBtn.isEnabled = true
            }
            
            if let error = responseData.errorObject {
                print(error.message)
                return
            }
            
            if let list = responseData.placesList {
                if list.count > 0 {
                    self?.nearByPlacesDataSource = Array(list)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.view.makeToast("No live result for place your looking for")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.view.makeToast("No live result for place your looking for")
                }
            }
        })
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func turnOnLocationButtonTapped(_ sender: UIButton) {
        fetchCurrentLocation()
    }
    
    @IBAction func clearLocationButtonTapped(_ sender:UIButton){
        dismiss(animated: true, completion: { [weak self] in
            self?.locationSelectedBlock!(nil)
        })
       
        
    }
    
}

extension SearchPlacesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isAutoCompleteSearch) ? autoCompletedataSource.count : nearByPlacesDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaceTableViewCell") as! SearchPlaceTableViewCell
        if isAutoCompleteSearch {
            cell.setupCellForAutocompleteResult(autocompleteResult: autoCompletedataSource[indexPath.row])
        } else {
            cell.setupCellForNearByPlaces(nearByPlace: nearByPlacesDataSource[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if isAutoCompleteSearch {
            var selectedPlace = autoCompletedataSource[indexPath.row]
            if let placeId = selectedPlace.placeId {
                GMSPlacesClient().lookUpPlaceID(placeId, callback: { [weak self] (place, error) in
                    if place != nil {
                        selectedPlace.latitude = "\(place!.coordinate.latitude)"
                        selectedPlace.longitude = "\(place!.coordinate.longitude)"
                    }
                    self?.dismiss(animated: true, completion: { [weak self] in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.locationSelectedBlock?(selectedPlace)
                    })
                })
            }
        } else {
            dismiss(animated: true, completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.locationSelectedBlock?(strongSelf.nearByPlacesDataSource[indexPath.row])
            })
        }
    }
    
}

extension SearchPlacesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 1 && string == "" {
            isAutoCompleteSearch = false
            tableView.reloadData()
            return true
        }
        
        if textField.text?.count == 0 && string != "" {
            isAutoCompleteSearch = true
            tableView.reloadData()
            return true
        }
        
        isAutoCompleteSearch = true
        let searchText = textField.text! + string
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: bounds, filter: nil) { [weak self] (results, error) in
            self?.autoCompletedataSource.removeAll()
            if results == nil {
                return
            }
            for result in results! {
                var autoCompleteResult = GooglePlace()
                autoCompleteResult.placeId = result.placeID
                autoCompleteResult.title = result.attributedPrimaryText.string
                autoCompleteResult.vicinity = result.attributedSecondaryText?.string
                self?.autoCompletedataSource.append(autoCompleteResult)
            }
            self?.tableView.reloadData()
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
