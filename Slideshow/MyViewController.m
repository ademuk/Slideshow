//
//  MyViewController.m
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import "MyViewController.h"

@implementation IconViewBox

- (NSView *)hitTest:(NSPoint)aPoint
{
    // don't allow any mouse clicks for subviews in this NSBox
    return nil;
}

@end


@implementation MyScrollView

- (void)awakeFromNib
{
    
}

- (void)drawRect:(NSRect)rect
{
    
}

@end


@implementation MyViewController

@synthesize images, sortingMode;

#define KEY_IMAGE	@"icon"
#define KEY_NAME	@"name"

- (void)awakeFromNib
{
    [self setSortingMode:0];		// icon collection in ascending sort order
    
    [collectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

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
