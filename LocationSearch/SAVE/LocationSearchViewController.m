//
//  LocationSearchViewController.m
//  LocationSearch
//
//  Created by Anh on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationSearchViewController.h"

@implementation LocationSearchViewController

@synthesize mapView;
@synthesize searchBar;
@synthesize currentLocation;
@synthesize responseData;
@synthesize results;

- (void)dealloc
{
    [mapView release];
    [searchBar release];
    [currentLocation release];
    [responseData release];
    [results release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the result array.
    self.results = [[NSMutableArray alloc] init];
    
    // Create an instance of the Core Location CLLocationManager.
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    // Set the CLLocationManagerDelegate to self
    [locationManager setDelegate:self];
    
    // Tell the locationManager to start updating the location.
    // Note that this is a heavy power-consuming task.
    [locationManager startUpdatingLocation];


    // Set the UISearchBarDelegateDelegate to self
    [self.searchBar setDelegate:self];
    
    // Set the delegate for the mapView to self.
    [self.mapView   setDelegate:self];
    
    // Use CoreLocation to find the user's location and display on map.
    // Note that mapView will access coreLocation continuously to update
    // user's position.  Battery-draining.
    self.mapView.showsUserLocation = YES;    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.mapView = nil;
    self.searchBar = nil;
    self.currentLocation = nil;
    self.responseData = nil;
    self.results = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Handle CLLocationManager Delegate Methods

/* Called when CLLocationManager determines that the device has moved.
 */
- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    
    //NSLog(@"locationManager:didUpdateToLocation");
 
    self.currentLocation = newLocation;
    
    // Create a MapKit region based on the location.
    // span is a struct that defines the area covered by the map in degrees.
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;   
    
    // region is a struct defines a map to show based on the center coordinate 
    // and the span.
    MKCoordinateRegion region;
    region.center = newLocation.coordinate;
    region.span = span;
    
    // Update the map to display the current location.
    [mapView setRegion:region animated:YES];
    
    // Stop core location services when done to conserve battery.
    // We don't need to constant update info because we don't need extremely 
    // accurate position resolution.
    [manager startUpdatingLocation];
}


/* Called when an error occurs.
 */
- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error {
    
    NSLog(@"locationManager:didFailWithError");
    
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Status:"
						  message:@"Can't determine current location"
						  delegate:nil 
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	
	[alert show];
	[alert release];
    
}


#pragma mark -
#pragma mark Handle UISearchBar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)localsearchBar {
    
    NSLog(@"searchBarSearchButtonClicked");
    
    // Get the search string from the searchBar passed in.
    // Note that the search text string may have % and & characters which have special meanings
    // in HTTP.  Therefore, we need to URL encode the searchString.
    
    NSString *searchString = [localsearchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    
    NSLog(@"searchString = %@", searchString);
    
    // Get the latitude and longitude.
    CLLocationDegrees latitude = self.currentLocation.coordinate.latitude;
    CLLocationDegrees longitude = self.currentLocation.coordinate.longitude;
    
    NSLog(@"latitude = %f \nlongitude = %f", latitude, longitude);
    
    
    // Construct the URL to call.    
    // We use Yahoo Local Search API.
    // For complete doc, go to:
    // http://developer.yahoo.com/search/local/V3/localSearch.html
    
    // Observe the parameters: appid, searchString, latitude, and longitude.    
    // Note the appid in the URL string below.  The appid is a token that we receive from Yahoo when we sign up to use their web services.  

    // We can obtain the appid token by going to 
    // https://developer.apps.yahoo.com/wsregapp.
    
    // THE urlString is used to create an encoded URL which will then be used to create 
    // an URL request.
    NSString *urlString = [NSString stringWithFormat:
                           @"http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=phJGV.rV34Hxjrb3A50qdEkHVCC87MO1p0PryALzct8TxFUjzMVFw2PqYsgSczA-"
                           "&query=%@&latitude=%f&longitude=%f",
                           searchString,
                           latitude,
                           longitude];
     
    NSLog(@"urlString = %@", urlString);
    
    NSURL *serviceURL = [NSURL URLWithString:urlString];
    
    
    // Create the URL request.
    NSURLRequest *urlRequest = [NSURLRequest 
                                requestWithURL:serviceURL
                                cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                timeoutInterval:30.0];
    
    // Create the connection and send the request.
    // Specify that we will handle the NSURLConnection delegate methods ourselves.
    // Note: connection is released in connectionDidFinishLoading and 
    // connection:didFailWithError.
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // Verify the connection
    if (connection) {
        // Instantiate the response data structure to hold the response.
        // Note that this calls the data method inherited from NSData which creates
        // empty NSMutable data object.
        
        self.responseData = [NSMutableData data];  
        NSLog(@"Successfully connected to URL.");
    }
    
    else {
        // Display error msg.
        NSString *errStr = @"Can't connect to URL.";
        NSLog(@"%@", errStr);
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Status:"
                              message:errStr
                              delegate:nil 
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }  
    
    // Tell the SearchBar to dismiss the associated keyboard.
    [localsearchBar resignFirstResponder];
}


/* Called when the text in the Search Bar changes.
 */
- (void)searchBar:(UISearchBar *)searchBar 
    textDidChange:(NSString *)searchText {
    
    NSLog(@"searchBar:textDidChange");
    
    // If the text was cleared, clear the map annotations.
    if ([searchText isEqualToString:@""]) {
        
        // Clear the annotations
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        // Clear the results array.
        [self.results removeAllObjects];
    }
}


#pragma mark -
#pragma mark Plot Map Results

- (void)plotResults {
    
    // Annotate the result
    [mapView addAnnotations:self.results];
}



#pragma mark -
#pragma mark Handle MKMapView Delegate Methods

/* MKMapView will call this method when the map needs the view for annotations.
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView 
            viewForAnnotation:(id<MKAnnotation>)annotation {
    
    // If we are displaying the user's location, return nil to use the default view.
    if ([annotation isKindOfClass:[MKUserLocation class]]) 
        return nil;
    
    // Try to dequeue an existing pin.
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *) 
                        [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"location"];
  
    if (!pinAnnotationView) {
        // We could not get a pin from the queue so init a new one.
        pinAnnotationView = [[[MKPinAnnotationView alloc] 
                              initWithAnnotation:annotation 
                              reuseIdentifier:@"location"] autorelease];
        
        pinAnnotationView.animatesDrop = TRUE;
        pinAnnotationView.canShowCallout = YES;
    }
    
    // We need to get the rating from the annotation object
    //  to color the pin based on rating
    Result *resultAnnotation = (Result*) annotation;
    
    if (resultAnnotation.rating > 4.5) {
        pinAnnotationView.pinColor = MKPinAnnotationColorGreen;
    }
    else if (resultAnnotation.rating > 3.5) {
        pinAnnotationView.pinColor = MKPinAnnotationColorPurple;
    }
    else {
        pinAnnotationView.pinColor = MKPinAnnotationColorRed;
    }
    
    return pinAnnotationView;
}



#pragma mark -
#pragma mark Handle NSURLConnection Delegate Methods

/* NSURLConnection calls this method when there is enough data to initiate a response.
   The connection could call this method multiple times, in cases where there are 
   server redirects.
 */
- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSURLResponse *)response {
    
    NSLog(@"connection:didReceiveResponse");
    
    // Each time this is called, reset responseData buffer.
    [self.responseData setLength:0];
}


/* NSURLConnection calls this method each time it receives a chunk of data.
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"connection:didReceiveData");
    
    // Append data into buffer.
    [self.responseData appendData:data];
}

/* NSURLConnection when the connection has finished loading all the requested data.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading");
    
    // Convert the response data to a string so we can log it.
    NSString *responseString = [[NSString alloc] 
                                initWithData:self.responseData
                                encoding:NSUTF8StringEncoding];
    NSLog(@"responseData: \n%@\n", responseString);
    
    [responseString release];
    [connection release];
 
    // Parse the XML data.
    [self parseXML];
}

/* Handle cases when connection failed.
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"connection:didFailWithError:");
    
    NSLog(@"%@", [error localizedDescription]);
                  
    [connection release];
    
}

#pragma mark -
#pragma mark Handle XML Parsing

/* Parse the returned XML data.  We are assuming that this call is being made after
  the connection finished loading.
 */
- (void)parseXML {
    
    NSLog(@"parseXML");
    
    // Init the parser with the response data.
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:self.responseData];
    
    // Note that this is a SAX parser, which is event driven.
    // So we need to implement the delegate methods that the parser calls 
    // as it parses data.
    // Set the delegate to self.
    [xmlParser setDelegate:(id<NSXMLParserDelegate>)self];
    
    // Start the parser.
    if (![xmlParser parse])
        NSLog(@"Error parsing XML data.");
    
    // Release the parser.
    [xmlParser release];
}


#pragma mark -
#pragma mark Handle NSXMLParser Delegate Methods.

/* NSXMLParser calls this method each time a begin-element tag, such as <Title>
   is found.
 */
- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {

    NSLog(@"parser:didStartElement");
    
    // Check to see which element we have found.
    // If it's a "Result", create a new instance of Result class to hold the result.
    // aResult will be released in parser:didEndElement.
    
    if ([elementName isEqualToString:@"Result"]) {
        aResult = [[Result alloc] init];
    }
    
    // If it's any other field that we're interested in, allocate and initialize
    // the capturedCharacters instance variable to prepare for the characters to come.
    // capturedCharacters will be released in parser:didEndElement.
   
    else if ([elementName isEqualToString:@"Title"] ||
             [elementName isEqualToString:@"Address"] ||
             [elementName isEqualToString:@"City"] ||
             [elementName isEqualToString:@"State"] ||
             [elementName isEqualToString:@"Phone"] ||
             [elementName isEqualToString:@"Latitude"] ||
             [elementName isEqualToString:@"Longitude"] ||
             [elementName isEqualToString:@"AverageRating"]) {
        
        capturedCharacters = [[NSMutableString alloc] initWithCapacity:100];
    }    
}


/* NSXMLParser calls this method any time it encounters a character inside an element.
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if (capturedCharacters != nil)
        [capturedCharacters appendString:string];
}


/* NSXMLParser calls this method when an element ends.
 */
- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    
    NSLog(@"parser:didEndElement");
    
    // We just ended "Result" element:
    if ([elementName isEqualToString:@"Result"]) {
        // Add the new result to the result array.
        [results addObject:aResult];
        [aResult release];
        aResult = nil;
    }
    
    // We just ended "Title" element:
    else if ([elementName isEqualToString:@"Title"] && aResult != nil) {
        aResult.title = capturedCharacters;
    }
 
    // We just ended "Address" element:
    else if ([elementName isEqualToString:@"Address"] && aResult != nil) {
        aResult.address = capturedCharacters;
    }
    
    // We just ended "City" element:
    else if ([elementName isEqualToString:@"City"] && aResult != nil) {
        aResult.city = capturedCharacters;
    }
    
    // We just ended "State" element:
    else if ([elementName isEqualToString:@"State"] && aResult != nil) {
        aResult.state = capturedCharacters;
    }
    
    // We just ended "Phone" element:
    else if ([elementName isEqualToString:@"Phone"] && aResult != nil) {
        aResult.phone = capturedCharacters;
    }
    
    // We just ended "Latitude" element:
    else if ([elementName isEqualToString:@"Latitude"] && aResult != nil) {
        aResult.latitude = [capturedCharacters doubleValue];
    }

    // We just ended "Longitude" element:
    else if ([elementName isEqualToString:@"Longitude"] && aResult != nil) {
        aResult.longitude = [capturedCharacters doubleValue];
    }

    // We just ended "AverageRating" element:
    else if ([elementName isEqualToString:@"AverageRating"] && aResult != nil) {
        aResult.rating = [capturedCharacters floatValue];
    }
    
    
    // Release capturedCharacters
    if ([elementName isEqualToString:@"Title"] ||
        [elementName isEqualToString:@"Address"] ||
        [elementName isEqualToString:@"City"] ||
        [elementName isEqualToString:@"State"] ||
        [elementName isEqualToString:@"Phone"] ||
        [elementName isEqualToString:@"Latitude"] ||
        [elementName isEqualToString:@"Longitude"]||
        [elementName isEqualToString:@"AverageRating"]) {
        
        [capturedCharacters release];
    }
}


/* NSXMLParser calls this when the document ends.
 */

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    NSLog(@"parserDidEndDocument");
    
    // Plot the results on the map.
    [self plotResults];
}


@end
