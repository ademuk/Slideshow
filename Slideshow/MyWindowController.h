//
//  MyWindowController.h
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <Quartz/Quartz.h>

#import "MyViewController.h"

@interface MyWindowController : NSWindowController <QLPreviewPanelDataSource, QLPreviewPanelDelegate>;

- (IBAction)chooseSource:(id)sender;

- (IBAction)togglePreviewPanel:(id)previewPanel;

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

@property MyViewController *viewController;
@property IBOutlet NSCollectionView *myTargetView;
@property (strong) QLPreviewPanel *previewPanel;

@end
