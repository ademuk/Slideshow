//
//  MyWindowController.m
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "MyWindowController.h"
#import "NSImage+NSImageResizeAdditions.h"

@implementation MyWindowController

#define KEY_IMAGE	@"icon"
#define KEY_NAME	@"name"

- (void)awakeFromNib
{
    [[self window] setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
    [[self window] setContentBorderThickness:30 forEdge:NSMinYEdge];
    
    // load our nib that contains the collection view
    [self willChangeValueForKey:@"viewController"];
    self.viewController = [[MyViewController alloc] initWithNibName:@"Collection" bundle:nil];
    [self didChangeValueForKey:@"viewController"];
    NSCollectionView * view = [self.viewController view];
    [self.myTargetView addSubview:view];
    
    // make sure we resize the viewController's view to match its super view
    [[self.viewController view] setFrame:[self.myTargetView bounds]];
    
    [self.viewController setSortingMode:0];		// ascending sort order
}

- (IBAction)chooseSource:(id)sender {
    
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    
    if ([openPanel runModal] == NSOKButton)
    {
        NSArray* URLs = [openPanel URLs];
        NSURL* URL = [URLs objectAtIndex:0];
        [self scanSource:URL];
    }
}

- (void)scanSource:(NSURL*)url {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:url
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            NSString *type = [MyWindowController fileTypeOfURL:url];
            if (type) {
                NSImage *thumb = [MyWindowController thumbnailForURL:url ofType:type];
                
                [tempArray addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [[url path] lastPathComponent], KEY_NAME,
                                       thumb, KEY_IMAGE,
                                       nil]];
            }
        }
    }
    
    [self.viewController setImages:tempArray];
}

+ (id)fileTypeOfURL:(NSURL*)url {
    NSString *file = [url absoluteString]; // path to some file
    CFStringRef fileExtension = (__bridge CFStringRef) [file pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    //    CFRelease(fileUTI);
    //    CFRelease(fileExtension);
    
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        return @"Image";
    }
    
    if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
        return @"Video";
    }
    
    return NO;
}

+ (NSImage *)thumbnailForURL:(NSURL *)url
                          ofType:(NSString *)type {
    NSImage *thumb;
    
    if ([type isEqualTo:@"Video"]) {
        thumb = [MyWindowController thumbnailImageForVideo:url atTime:0];
    } else {
        thumb = [[[NSImage alloc] initWithContentsOfURL:url] imageByScalingProportionallyToSize:NSMakeSize(67, 67)];
    }
    return thumb;
}

+ (NSImage *)thumbnailImageForVideo:(NSURL *)videoURL
                             atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    generator.maximumSize = CGSizeMake(67, 67);
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    
    NSError *igError = nil;
    
    thumbnailImageRef = [generator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                                          actualTime:NULL
                                               error:&igError];
    
    NSImage *thumbnailImage = [[NSImage alloc] initWithCGImage:thumbnailImageRef size:NSMakeSize(CGImageGetWidth(thumbnailImageRef), CGImageGetHeight(thumbnailImageRef))];
    
    return thumbnailImage;
}

- (IBAction)togglePreviewPanel:(id)previewPanel
{
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
    {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    }
    else
    {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL action = [menuItem action];
    if (action == @selector(togglePreviewPanel:))
    {
        if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
        {
            [menuItem setTitle:@"Close Quick Look panel"];
        }
        else
        {
            [menuItem setTitle:@"Open Quick Look panel"];
        }
        return YES;
    }
    return NO;
}

#pragma mark - Quick Look panel support

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    // This document is now responsible of the preview panel
    // It is allowed to set the delegate, data source and refresh panel.
    //
    _previewPanel = panel;
    panel.delegate = self;
    panel.dataSource = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    // This document loses its responsisibility on the preview panel
    // Until the next call to -beginPreviewPanelControl: it must not
    // change the panel's delegate, data source or refresh it.
    //
    _previewPanel = nil;
}


#pragma mark - QLPreviewPanelDataSource

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return self.viewController.selectedImages.count;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    return (self.viewController.selectedImages)[index];
}


#pragma mark - QLPreviewPanelDelegate

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
    // redirect all key down events to the table view
    if ([event type] == NSKeyDown)
    {
        [self.myTargetView keyDown:event];
        return YES;
    }
    return NO;
}

// This delegate method provides the rect on screen from which the panel will zoom.
- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
{
    NSInteger index = [self.viewController.images indexOfObject:item];
    if (index == NSNotFound)
    {
        return NSZeroRect;
    }
    
    NSRect iconRect = [self.myTargetView frameForItemAtIndex:index];
    
    // check that the icon rect is visible on screen
    NSRect visibleRect = [self.myTargetView visibleRect];
    
    if (!NSIntersectsRect(visibleRect, iconRect))
    {
        return NSZeroRect;
    }
    
    // convert icon rect to screen coordinates
    iconRect = [self.myTargetView convertRectToBacking:iconRect];
    iconRect.origin = [[self.myTargetView window] convertBaseToScreen:iconRect.origin];
    
    return iconRect;
}

// this delegate method provides a transition image between the table view and the preview panel
//
- (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect
{
    NSDictionary *dictionary = (NSDictionary *)item;
    
    return [dictionary valueForKey:KEY_IMAGE];
}

@end
