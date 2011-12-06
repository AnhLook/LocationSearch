//
//  Result.h
//  LocationSearch
//
//  Created by Anh on 9/26/11.
//  Copyright 2011 Looksys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/Mapkit.h>


@interface Result : NSObject <MKAnnotation> {
    
    NSString *title;
    NSString *address;
    NSString *city;
    NSString *state;
    NSString *phone;
    
    double latitude;
    double longitude;
    float rating;
}    

@property (nonatomic, retain) NSString *title, *address, *city, *state, *phone;
@property (nonatomic) double latitude, longitude;
@property (nonatomic) float rating;
    
@end
