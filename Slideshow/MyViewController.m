//
//  MyViewController.m
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import "MyViewController.h"

@implementation IconViewBox

// -------------------------------------------------------------------------------
//	hitTest:aPoint
// -------------------------------------------------------------------------------
- (NSView *)hitTest:(NSPoint)aPoint
{
    // don't allow any mouse clicks for subviews in this NSBox
    return nil;
}

@end


@implementation MyScrollView

// -------------------------------------------------------------------------------
//	awakeFromNib
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
    // set up the background gradient for this custom scrollView
    backgroundGradient = [[NSGradient alloc] initWithStartingColor:
                          [NSColor colorWithDeviceRed:0.349f green:0.6f blue:0.898f alpha:0.0f]
                                endingColor:[NSColor colorWithDeviceRed:0.349f green:0.6f blue:.898f alpha:0.6f]];
}

// -------------------------------------------------------------------------------
//	drawRect:rect
// -------------------------------------------------------------------------------
- (void)drawRect:(NSRect)rect
{
    // draw our special background as a gradient
    [backgroundGradient drawInRect:[self documentVisibleRect] angle:90.0f];
}

@end


@implementation MyViewController

@synthesize images, sortingMode;

#define KEY_IMAGE	@"icon"
#define KEY_NAME	@"name"

// -------------------------------------------------------------------------------
//	awakeFromNib
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [self setSortingMode:0];		// icon collection in ascending sort order
    
    [collectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

// -------------------------------------------------------------------------------
//	setSortingMode:newMode
// -------------------------------------------------------------------------------
- (void)setSortingMode:(NSUInteger)newMode
{
    sortingMode = newMode;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:KEY_NAME
                              ascending:(sortingMode == 0)
                              selector:@selector(caseInsensitiveCompare:)];
    [arrayController setSortDescriptors:[NSArray arrayWithObject:sort]];
}

// -------------------------------------------------------------------------------
//	collectionView:writeItemsAtIndexes:indexes:pasteboard
//
//	Collection view drag and drop
//  User must click and hold the item(s) to perform a drag.
// -------------------------------------------------------------------------------
- (BOOL)collectionView:(NSCollectionView *)cv writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
{
    NSMutableArray *urls = [NSMutableArray array];
    NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
        {
            NSDictionary *dictionary = [[cv content] objectAtIndex:idx];
            NSImage *image = [dictionary objectForKey:KEY_IMAGE];
            NSString *name = [dictionary objectForKey:KEY_NAME];
            if (image && name)
            {
                NSURL *url = [temporaryDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.tiff", name]];
                [urls addObject:url];
                [[image TIFFRepresentation] writeToURL:url atomically:YES];
            }
        }];
    if ([urls count] > 0)
    {
        [pasteboard clearContents];
        return [pasteboard writeObjects:urls];
    }
    return NO;
}

@end
