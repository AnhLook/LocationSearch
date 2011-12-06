//
//  Result.m
//  LocationSearch
//
//  Created by Anh on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Result.h"


@implementation Result

@synthesize title, address, city, state, phone;
@synthesize latitude, longitude;
@synthesize rating;



- (void)dealloc {
    
    [title release];
    [address release];
    [city release];
    [state release];
    [phone release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Handle MKAnnotation protocol

/* NOTE:  there is no property called "coordinate" or "subtitle" declared nor
 synthesized.  In Objective C, using property and the dot method simply calls the
 appropriate getter/setter methods.  Therefore, instead of defining a property, we
 simply implement the getter method that the MKAnnotation protocol requires.
 */

/* Implement the getter for the coordinate property that is required to implement
   the MKAnnotation protocol.
 */
- (CLLocationCoordinate2D)coordinate {
    
    CLLocationCoordinate2D returnedCoordinate;
    
    returnedCoordinate.latitude = self.latitude;
    returnedCoordinate.longitude = self.longitude;
    
    return returnedCoordinate;    
}


/* The subtitle is the phone number of a business.
 */
-(NSString *)subtitle {
    
    NSString *returnedStr = [[NSString alloc] initWithFormat:@"%@", phone];
    
    [returnedStr autorelease];
    
    return returnedStr;
}



@end
