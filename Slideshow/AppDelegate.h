//
//  AppDelegate.h
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (IBAction)chooseSource:(id)sender;

- (void)scanSource:(NSURL*)url;

- (BOOL)isMedia:(NSURL*)url;

@end

