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


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet var myMap: MKMapView!
    
   
    @IBOutlet var address: UITextField!
    
    
    @IBOutlet var route: UITextView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var myLocMgr = CLLocationManager()
    var myGeoCoder =  CLGeocoder()
    var showPlaceMark : CLPlacemark?
    var toAddr : String?
    var currentTransportType = MKDirectionsTransportType.automobile
    
    // select transport type by default
   // var currentTransportType = MKDirectionsTransportType.automobile
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
      myLocMgr.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.authorizedWhenInUse
        {
            self.myMap.showsUserLocation = true
        
        }
        myMap.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet var getLocation: UIButton!
   
    @IBOutlet var getDirection: UIButton!
    
    @IBAction func locate(_ sender: Any) {
        self.toAddr = self.address!.text
        myGeoCoder.geocodeAddressString(toAddr!, completionHandler:
            {
                placemarks, error in
                if error != nil{
                    print(error!)
                    return
                }
                // no error, got an array of placemarks - show the first
                if placemarks != nil && placemarks!.count > 0
                {
                    let placemark = placemarks![0] as CLPlacemark
                    self.showPlaceMark = placemark
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
        if segmentedControl.selectedSegmentIndex == 0 {
            currentTransportType = MKDirectionsTransportType.automobile
        } else {
            currentTransportType = MKDirectionsTransportType.walking
        }
        segmentedControl.isHidden = false
        
        let dirRq = MKDirectionsRequest()
        let myTransportType = currentTransportType
        segmentedControl.addTarget(self, action: "direction:", for: .valueChanged)
        var myRoute : MKRoute?
        var showRoute = ""
        
        //set the source and destination of the route
        dirRq.source = MKMapItem.forCurrentLocation()
        dirRq.destination = MKMapItem(placemark: MKPlacemark(placemark: showPlaceMark!))
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
             if let steps = myRoute?.steps as [MKRouteStep]!
             {
                for step in steps
                {
                    showRoute = showRoute + step.instructions
                } //for ends
                self.route.text = showRoute
                } //if ends
            }
        
        })
    
    
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = (currentTransportType == .automobile) ?
            UIColor.blue : UIColor.orange
        renderer.lineWidth = 3.0
        return renderer
    }
    
}
