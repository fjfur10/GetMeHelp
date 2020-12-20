//
//  ViewController.swift
//  GetMeHelp
//
//  Created by Francis Furnelli on 12/18/20.
//

import UIKit
import RadarSDK
import CoreLocation
import MapKit
import CoreData

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, DataEnteredDelegate{
    
    
    //Declaring outlets
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var optionPicker: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private var mapView: MKMapView!

    
    //declarations
    var locationManager = CLLocationManager()
    let request = MKDirections.Request()
    let annotation = MKPointAnnotation()
   
    
    var placescoords=[String: CLLocationCoordinate2D]() //dictionary of places matched to their coordinates
    let pickerData = ["Banks" : "bank", "Places to Eat" : "restaurant", "Grocery Store" : "food-grocery", "Places to Stay" : "hotel-lodging", "Doctor": "doctor", "Pharmacy": "pharmacy", "Library": "library", "Religous Centers": "religion", "Malls": "shopping-mall", "Gyms": "gym", "Favorites" : "nil"] //dictionary of id's for SDK
    
    //array initializations
    var placeArr = [Place]()
    var addressesarray = [RadarAddress]()
    var favorites = [RadarPlace]()
    
    //inital values
    var lat = 1.0
    var long = 1.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Location Manager Stuff
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //delegate stuff
        optionPicker.delegate = self
        tableView.delegate = self
        optionPicker.dataSource = self
        tableView.dataSource = self
       
        tableView.register(PlacesCell.self, forCellReuseIdentifier: "cellReuseIdentifier")
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Button to fetch places
    @IBAction func didTouchDoneButton(_ sender: UIButton) {

        let loc = CLLocation(latitude: lat, longitude: long)
        if(!CLLocationManager.locationServicesEnabled() || loc.coordinate.latitude == 1.0) //can a location be found?
        {
            locationAlert()
        }
        
        //using Radar to find nearby places
        let vals = Array(pickerData.values)
        var rad = 5000
        while(findplaces(radius: rad, val: vals, myloc: loc) == false) //keeps checking with a larger radius when no places are returned
        {
            rad = rad + 1000
            continue
        }
            
        //updates map view
        let regionradius:CLLocationDistance = 5000.0
        let region = MKCoordinateRegion(center: CLLocation(latitude: lat, longitude: long).coordinate, latitudinalMeters: regionradius, longitudinalMeters: regionradius)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        placeAnnotationHere()
    }
    
    
    //Main function that uses Radar API/SDK to fetch nearby places based on used coordinates
    func findplaces(radius: Int, val: [Dictionary<String, String>.Values.Element], myloc: CLLocation) -> Bool
    {
        var placesreturned = true
        Radar.searchPlaces(
          near: myloc,
          radius: Int32(radius), // meters
          chains: nil,
          categories: [val[optionPicker.selectedRow(inComponent: 0)]],
          groups: nil,
          limit: 10
        ) { (status, location, places) in
            self.placeArr = [Place]()
            if(self.placeArr.count == 0 && radius<7000){
                placesreturned = false
            }
            for place in places! {
                print(place.name)
                self.placescoords.updateValue(place.location.coordinate, forKey: place.name)
                var myPlace = Place(place: place, isFavorite: false)
                for fav in self.favorites {
                    if fav._id == myPlace.place._id {
                        myPlace.isFavorite = true
                    }
                }
                
                self.placeArr.append(myPlace)
                
            }
            self.tableView.reloadData()
        }
        return placesreturned;
    }
    
    
    //Alert pop up
    func locationAlert()
    {
        let alert = UIAlertController(title: "Location Services Denied", message: "In order to use this app you must enable location services or enter location manually.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
  
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func zoomInButtonPressed(_ sender: Any) {
        mapView.setZoomByDelta(delta: 0.5, animated: true)
    }
    
    @IBAction func zoomOutButtonPressed(_ sender: Any) {
        
        mapView.setZoomByDelta(delta: 2, animated: true)
    }
    
    //Toggles map to current user location
    @IBAction func homeButtonPressed(_ sender: Any) {
        
        if(lat == 1.0) //checks to see if the user has inputted a location or allowed app to use their location
        {
            locationAlert()
            return
        }
        let uloc = CLLocation(latitude: lat, longitude: long) //users current location
        let regionradius:CLLocationDistance = 500.0
        let region = MKCoordinateRegion(center: uloc.coordinate, latitudinalMeters: regionradius, longitudinalMeters: regionradius)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.blue
            return renderer
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        lat = Double(locValue.latitude)
        long = Double(locValue.longitude)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier") as! PlacesCell
        let text = placeArr[indexPath.row].place.name
        cell.linktoVC = self
        //cell.accessoryView?.tintColor = placeArr[indexPath.row].isFavorite ? UIColor.red : UIColor.blue
        cell.drawHeart(toDraw: placeArr[indexPath.row].isFavorite ? "heart.fill" : "heart")
        let placeLoc = placeArr[indexPath.row].place.location
        var detail = ""
        Radar.getDistance(origin: CLLocation(latitude: lat, longitude: long), destination: CLLocation(latitude: placeLoc.coordinate.latitude, longitude: placeLoc.coordinate.longitude), modes: RadarRouteMode.car, units: RadarRouteUnits.imperial) {(status, route) in
            let myRoute = route!
            detail = (myRoute.car?.distance.text)!
        }
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detail
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let currentCell = tableView.cellForRow(at: indexPath)! as! PlacesCell
        let thiscoor =  placescoords[currentCell.textLabel!.text!]!
        
        let regionradius:CLLocationDistance = 1000.0
        let region = MKCoordinateRegion(center: thiscoor, latitudinalMeters: regionradius, longitudinalMeters: regionradius)
         mapView.setRegion(region, animated: true)
         mapView.delegate = self
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: thiscoor.latitude, longitude: thiscoor.longitude)
        annotation.title = currentCell.textLabel?.text!
        mapView.addAnnotation(annotation)
        
        //draw navigation lines
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: thiscoor.latitude, longitude: thiscoor.longitude), addressDictionary: nil))
               request.requestsAlternateRoutes = true
               request.transportType = .automobile
        
        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, error in
        guard let unwrappedResponse = response else { return }

                    for route in unwrappedResponse.routes {
                        self.mapView.removeOverlays(mapView.overlays)
                        self.mapView.addOverlay(route.polyline)
                    }
        
      
                }
    }
    

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let data =  Array(pickerData.keys)
        return data[row]
    }
    
    //places annotation on map of current location
    func placeAnnotationHere(){
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = "You Are Here"
        mapView.addAnnotation(annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?)
    {
        if(segue.identifier == "toManualInput"){
            let secondViewController = segue.destination as! ManLocationViewController
            secondViewController.delegate = self
        }
    }
    
    //change user location from automatic to manual
    func userDidEnterInformation(info:[String:String]){
        Radar.geocode(address: "\(info["street1"]!) \(info["city"]!) \(info["state"]!)"){(status, addresses) in
            self.addressesarray = addresses!
            for address in self.addressesarray {
                print(address.coordinate)
                self.lat = address.coordinate.latitude
                self.long = address.coordinate.longitude
                self.doneButton.sendActions(for: .touchUpInside)
            }
        }
    }
        
    
    //toggle heart
    func flipFavorite(cell: UITableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        let place = placeArr[indexPath!.row]
        print(place)
        let hasFav = place.isFavorite
        placeArr[indexPath!.row].isFavorite = !hasFav
        print(placeArr[indexPath!.row])
        if placeArr[indexPath!.row].isFavorite{
            favorites.append(placeArr[indexPath!.row].place)
        }
        else {
            favorites.remove(at: favorites.firstIndex(of: placeArr[indexPath!.row].place)!)
        }
        print(favorites)
        tableView.reloadData()
    }
}

