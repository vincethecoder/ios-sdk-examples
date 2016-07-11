//
//  DraggableAnnotationViewExample.swift
//  Examples
//
//  Created by Jason Wray on 7/11/16.
//  Copyright © 2016 Mapbox. All rights reserved.
//

import Mapbox

@objc(DraggableAnnotationViewExample_Swift)

class DraggableAnnotationViewExample_Swift: UIViewController, MGLMapViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mapView.styleURL = MGLStyle.lightStyleURLWithVersion(9)
        mapView.tintColor = .darkGrayColor()
        mapView.zoomLevel = 1
        mapView.delegate = self
        view.addSubview(mapView)

        // Specify coordinates for our annotations.
        let coordinates = [
            CLLocationCoordinate2DMake(0, -70),
            CLLocationCoordinate2DMake(0, -35),
            CLLocationCoordinate2DMake(0,  0),
            CLLocationCoordinate2DMake(0, 35),
            CLLocationCoordinate2DMake(0, 70),
            ]

        // Fill an array with point annotations and add it to the map.
        var pointAnnotations = [MGLPointAnnotation]()
        for coordinate in coordinates {
            let point = MGLPointAnnotation()
            point.coordinate = coordinate
            point.title = "To drag this annotation, first tap and hold."
            pointAnnotations.append(point)
        }

        mapView.addAnnotations(pointAnnotations)
    }

    // MARK: - MGLMapViewDelegate methods

    // This delegate method is where you tell the map to load a view for a specific annotation. To load a GL-based MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }

        // For better performance, always try to reuse existing annotations. To use multiple different annotation views, change the reuse identifier for each.
        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("draggablePoint") {
            return annotationView
        } else {
            return CustomDraggableAnnotationView(reuseIdentifier: "draggablePoint", size: 50)
        }
    }

    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

// MGLAnnotationView subclass
class CustomDraggableAnnotationView : MGLAnnotationView {
    init(reuseIdentifier: String, size: CGFloat) {
        super.init(reuseIdentifier: reuseIdentifier)

        // `draggable` is a property of MGLAnnotationView, disabled by default.
        draggable = true

        // This property prevents the annotation from changing size when the map is tilted.
        scalesWithViewingDistance = false

        // Begin setting up the view.
        frame = CGRectMake(0, 0, size, size)

        backgroundColor = .darkGrayColor()

        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = size / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.1
    }

    // These two initializers are forced upon us by Swift.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Custom handler for changes in the annotation’s drag state.
    override func setDragState(dragState: MGLAnnotationViewDragState, animated: Bool) {
        super.setDragState(dragState, animated: animated)

        switch dragState {
        case .Starting:
            print("Starting", terminator: "")
            startDragging()
            break
        case .Dragging:
            print(".", terminator: "")
        case .Ending, .Canceling:
            print("Ending")
            endDragging()
            break
        case .None:
            return
        }
    }

    // When the user interacts with an annotation, animate opacity and scale changes.
    func startDragging() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 0.8
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5)
            }, completion: nil)
    }

    func endDragging() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 1
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
            }, completion: nil)
    }
}
