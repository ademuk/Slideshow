//
//  AppDelegate.m
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import "AppDelegate.h"
#import "SlideshowViewController.h"

@interface AppDelegate ()
    @property (strong, nonatomic) SlideshowViewController *viewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.viewController = [[SlideshowViewController alloc] init];
    
    [self.window.contentView addSubview:self.viewController.view];
    [self.viewController.view setFrameSize:self.window.frame.size];
}

@end
