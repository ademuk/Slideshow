//
//  MyWindowController.m
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import "MyWindowController.h"
#import "NSImage+NSImageResizeAdditions.h"

@implementation MyWindowController

#define KEY_IMAGE	@"icon"
#define KEY_NAME	@"name"

// -------------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [[self window] setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
    [[self window] setContentBorderThickness:30 forEdge:NSMinYEdge];
    
    // load our nib that contains the collection view
    [self willChangeValueForKey:@"viewController"];
    viewController = [[MyViewController alloc] initWithNibName:@"Collection" bundle:nil];
    [self didChangeValueForKey:@"viewController"];
    
    [myTargetView addSubview:[viewController view]];
    
    // make sure we resize the viewController's view to match its super view
    [[viewController view] setFrame:[myTargetView bounds]];
    
    [viewController setSortingMode:0];		// ascending sort order
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
    
    [viewController setImages:tempArray];
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

+  (NSImage *)thumbnailForURL:(NSURL *)url
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

@end
