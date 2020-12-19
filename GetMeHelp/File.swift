//
//  File.swift
//  GetMeHelp
//
//  Created by Emily Cooper on 12/19/20.
//

import Foundation
import MapKit
extension MKMapView
{
    func setZoomByDelta(delta: Double, animated: Bool) {
            var _region = region;
            var _span = region.span;
            _span.latitudeDelta *= delta;
            _span.longitudeDelta *= delta;
            _region.span = _span;

            setRegion(_region, animated: animated)
        }
}
