//
//  LocationSearchViewController.h
//  LocationSearch
//
//  Created by Anh on 9/14/11.
//  Copyright 2011 Looksys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/Mapkit.h>
#import "Result.h"


@interface LocationSearchViewController : UIViewController 
    <CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate> {
        
    MKMapView *mapView;
    UISearchBar *searchBar;
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSMutableData *responseData;
    
    Result *aResult;
    NSMutableArray *results;
    NSMutableString *capturedCharacters;
}


@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic,retain) CLLocation *currentLocation;
@property (nonatomic,retain) NSMutableData *responseData;
@property (nonatomic,retain) NSMutableArray *results;


- (void)parseXML;
- (void)plotResults;

@end
