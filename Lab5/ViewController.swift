//
//  ViewController.swift
//  Lab5
//
//  Created by Prashant Saund on 3/17/17.
//  Copyright © 2017 MyOrg. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet var autofillBt: UIButton!
    @IBOutlet var directionsTableView: UITableView!
    @IBOutlet var startingPt: UITextField!
    @IBOutlet var destinationPt: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var myMap: MKMapView!
    @IBOutlet var locateS: UIButton!
    @IBOutlet var locateD: UIButton!
    @IBOutlet var getDirection: UIButton!
    
    
    var myLocMgr = CLLocationManager()
    var myGeoCoder =  CLGeocoder()
    var showPlaceMSt : CLPlacemark?
    var showPlaceMDt : CLPlacemark?
    var toAddr : String?
    var fromAddr : String?
    var currentTransportType = MKDirectionsTransportType.automobile
    var steps : [MKRouteStep]!

    
    
    // select transport type by default
    // var currentTransportType = MKDirectionsTransportType.automobile
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locateS.layer.cornerRadius = 4
        locateD.layer.cornerRadius = 4
        getDirection.layer.cornerRadius = 4
        autofillBt.layer.cornerRadius = 4
        segmentedControl.isHidden = true
        
        myMap.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        myLocMgr.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.authorizedWhenInUse
        {
            self.myMap.showsUserLocation = true
        }
        
    }
    
    
    
    @IBAction func autofillCA(_ sender: Any) {
        if (startingPt.text == "")
        {
            //startingPt.text = "latitude: "+"\(myMap.userLocation.coordinate.latitude)"+", longitude: "+"\(myMap.userLocation.coordinate.longitude)"+")"
        }
        
        if(destinationPt.text == "")
        {
            //destinationPt.text = "("+"\(myMap.userLocation.coordinate.latitude)"+", "+"\(myMap.userLocation.coordinate.longitude)"+")"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func locateStart(_ sender: Any) {
        self.fromAddr = self.startingPt!.text
        
        myGeoCoder.geocodeAddressString(fromAddr!, completionHandler:
            {
                placemarks, error in
                if error != nil{
                    print(error!)
                    let alert = UIAlertController(title: "No results found!", message: "Please enter a valid starting point", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                //No error, got an array of placemarks - show the first
                if placemarks != nil && placemarks!.count > 0
                {
                    let placemark = placemarks![0] as CLPlacemark
                    self.showPlaceMSt = placemark
                    //add annotation
                    let annotation = MKPointAnnotation()
                    annotation.title = placemark.name
                    annotation.subtitle = self.fromAddr
                    annotation.coordinate = placemark.location!.coordinate
                    self.myMap.showAnnotations([annotation], animated: true)
                }
        })
    }

    @IBAction func locateDest(_ sender: Any) {
        self.toAddr = self.destinationPt!.text
        
        myGeoCoder.geocodeAddressString(toAddr!, completionHandler:
            {
                placemarks, error in
                if error != nil{
                    print(error!)
                    let alert = UIAlertController(title: "No results found!", message: "Please enter a valid destination point", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                //No error, got an array of placemarks - show the first
                if placemarks != nil && placemarks!.count > 0
                {
                    let placemark = placemarks![0] as CLPlacemark
                    self.showPlaceMDt = placemark
                    //add annotation
                    let annotation = MKPointAnnotation()
                    annotation.title = placemark.name
                    annotation.subtitle = self.toAddr
                    annotation.coordinate = placemark.location!.coordinate
                    self.myMap.showAnnotations([annotation], animated: true)
                }
        })

    }
    
    
    @IBAction func direction(_ sender: Any) {
        directionsTableView.delegate = self
        directionsTableView.dataSource = self
        
        if segmentedControl.selectedSegmentIndex == 0 {
            currentTransportType = MKDirectionsTransportType.automobile
        } else {
            currentTransportType = MKDirectionsTransportType.walking
        }
        segmentedControl.isHidden = false
        
        let dirRq = MKDirectionsRequest()
        let myTransportType = currentTransportType
        
        segmentedControl.addTarget(self, action: #selector(ViewController.direction(_:)), for: .valueChanged)
        var myRoute : MKRoute?
        
        //set the source of the route
        if(self.startingPt.text == ""){
            dirRq.source = MKMapItem.forCurrentLocation()
        }
        else {
            dirRq.source = MKMapItem(placemark: MKPlacemark(placemark: showPlaceMSt!))
        }
        
        //set the destination of the route
        if(self.destinationPt.text == ""){
            dirRq.destination = MKMapItem.forCurrentLocation()
        }
        else {
            dirRq.destination = MKMapItem(placemark: MKPlacemark(placemark: showPlaceMDt!))
        }

        dirRq.transportType = myTransportType
        let myDirs = MKDirections(request: dirRq) as MKDirections
        
        myDirs.calculate(completionHandler: {
            routeResponse, routeError in
            if routeError != nil
                {
                print(routeError!)
                return
            }
        else
            {
                //get the first route
                myRoute = routeResponse?.routes[0] as MKRoute!
            
                // remove an existing route line and add  a new one
                self.myMap.removeOverlays(self.myMap.overlays)
            
                self.myMap.add((myRoute?.polyline)!, level: MKOverlayLevel.aboveRoads)
                //scale the map to show the whole route
                let rect = myRoute?.polyline.boundingMapRect
                self.myMap.setRegion(MKCoordinateRegionForMapRect(rect!), animated: true)
            
                // get the route steps to show on screen
                self.steps = myRoute?.steps
                self.directionsTableView.reloadData()
            }
        
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // your cell coding
        let cellIdentifier = "stepCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DirectionsTableViewCell
        
        cell.number.text = "\(indexPath.row + 1)"
        cell.Steps.text = self.steps[indexPath.row].instructions
        return cell
    }
    

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = (currentTransportType == .automobile) ?
            UIColor.blue : UIColor.purple
        renderer.lineWidth = 3.0
        return renderer
    }
    
}
