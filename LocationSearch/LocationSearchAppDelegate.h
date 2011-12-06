//
//  LocationSearchAppDelegate.h
//  LocationSearch
//
//  Created by Anh on 9/14/11.
//  Copyright 2011 Looksys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationSearchViewController;

@interface LocationSearchAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet LocationSearchViewController *viewController;

@end
