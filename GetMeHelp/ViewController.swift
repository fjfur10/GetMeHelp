//
//  ViewController.swift
//  GetMeHelp
//
//  Created by Francis Furnelli on 12/18/20.
//

import UIKit
import RadarSDK
import CoreLocation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var optionPicker: UIPickerView!
    
    @IBOutlet weak var tableView: UITableView!

    var locationManager = CLLocationManager()
    
    var pickerData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        pickerData = ["Chipotle", "Moe's", "Qdoba", "El Pollo Guapo"]
        titleLabel.text = "GetMeHelp!"
        titleLabel.isHidden = false
        optionPicker.dataSource = self
        optionPicker.delegate = self
        let loc = CLLocation(latitude: 42.0566201045534, longitude: -72.55247246362245)
        Radar.searchPlaces(
          near: loc,
          radius: 1000, // meters
            chains: nil,
          categories: ["medical-health"],
          groups: nil,
          limit: 10
        ) { (status, location, places) in
          // do something with places
            let placeArr = places!
            for place in placeArr {
                print(place.name)
            }
        }

        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

