//
//  SlideshowViewController.m
//  Slideshow
//
//  Created by Adem Gaygusuz on 04/10/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import <Quartz/Quartz.h>

#import "SlideshowViewController.h"
#import "SlideshowItem.h"

#import "CNGridView.h"
#import "CNGridViewItem.h"
#import "CNGridViewItemLayout.h"

#import "NSImage+NSImageResizeAdditions.h"

@interface SlideshowViewController ()
    @property (strong, nonatomic) NSScrollView *scrollView;
    @property (strong, nonatomic) CNGridView *gridView;
    @property (strong, nonatomic) NSButton *chooseSourceButton;
    @property (strong, nonatomic) NSButton *startSlideshowButton;
    @property (strong, nonatomic) NSMutableArray *items;
    @property (strong, nonatomic) NSArray *selectedItems;

    @property (strong) CNGridViewItemLayout *defaultLayout;
    @property (strong) CNGridViewItemLayout *hoverLayout;
    @property (strong) CNGridViewItemLayout *selectionLayout;

    @property (strong) QLPreviewPanel *previewPanel;
@end

@interface SlideshowItem (QLPreviewItem) <QLPreviewItem>

@end

#pragma mark -

@implementation SlideshowItem (QLPreviewItem)

- (NSURL *)previewItemURL
{
    return self.imageURL;
}

- (NSString *)previewItemTitle
{
    return self.title;
}

@end

#pragma mark -

@implementation SlideshowViewController

- (id)init {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        
        _defaultLayout = [CNGridViewItemLayout defaultLayout];
        _hoverLayout = [CNGridViewItemLayout defaultLayout];
        _selectionLayout = [CNGridViewItemLayout defaultLayout];
    }
    return self;
}

- (void)loadView {
    int resizeMask = (NSViewWidthSizable | NSViewHeightSizable);
    
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 500, 500)];
    [self.view setAutoresizingMask:resizeMask];
    
    CGSize viewSize = self.view.frame.size;
    
    self.chooseSourceButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 150, 35)];
    [self.chooseSourceButton setTitle:@"Choose Source"];
    [self.chooseSourceButton setBezelStyle:NSRoundedBezelStyle];
    [self.chooseSourceButton setTarget:self];
    [self.chooseSourceButton setAction:@selector(chooseSourceAction:)];
    
    self.startSlideshowButton = [[NSButton alloc] initWithFrame:NSMakeRect(viewSize.width - 150, 0, 150, 35)];
    [self.startSlideshowButton setTitle:@"Start Slideshow"];
    [self.startSlideshowButton setBezelStyle:NSRoundedBezelStyle];
    [self.startSlideshowButton setTarget:self];
    [self.startSlideshowButton setAction:@selector(startSlideshowAction:)];
    [self.startSlideshowButton setAutoresizingMask:NSViewMinXMargin];
    
    int toolbarHeight = self.chooseSourceButton.bounds.size.height + self.chooseSourceButton.frame.origin.y;
    // Move grid down, its position seems to be incorrectly offset
    int gridOffset = 35;
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, toolbarHeight, viewSize.width, viewSize.height - toolbarHeight - gridOffset)];
    [self.scrollView setAutoresizingMask:resizeMask];
    
    self.gridView = [[CNGridView alloc] initWithFrame:self.scrollView.frame];
    
    [self.gridView setDataSource:self];
    [self.gridView setDelegate:self];
    
    [self.gridView setAllowsSelection:YES];
    [self.gridView setAllowsMultipleSelection:YES];
    [self.gridView setAllowsMultipleSelectionWithDrag:YES];
    
    [self.gridView setAutoresizingMask:resizeMask];
    [self.gridView setItemSize:NSMakeSize(100, 100)];
    
    [self.scrollView setDocumentView:self.gridView];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.chooseSourceButton];
    [self.view addSubview:self.startSlideshowButton];
    
    self.hoverLayout.backgroundColor = [[NSColor grayColor] colorWithAlphaComponent:0.42];
    self.selectionLayout.backgroundColor = [NSColor colorWithCalibratedRed:0.542 green:0.699 blue:0.807 alpha:0.420];
    
    [self.gridView reloadData];
}

- (void)chooseSourceAction:(id)sender {
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
    [self.items removeAllObjects];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
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
            NSString *type = [SlideshowViewController fileTypeOfURL:url];
            if (type) {
                NSImage *thumb = [SlideshowViewController thumbnailForURL:url ofType:type];
                SlideshowItem *item = [[SlideshowItem alloc] initWithTitle:[[url path] lastPathComponent] image:thumb url:url];
                
                [self.items addObject:item];
            }
        }
    }
    
    [self.gridView reloadData];
}

+ (id)fileTypeOfURL:(NSURL*)url {
    NSString *file = [url absoluteString];
    CFStringRef fileExtension = (__bridge CFStringRef) [file pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
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
        thumb = [SlideshowViewController thumbnailImageForVideo:url atTime:0];
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

- (void)startSlideshowAction:(id)sender {
    [self togglePreviewPanel];
}

- (void)togglePreviewPanel
{
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
    {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    }
    else
    {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
        [[QLPreviewPanel sharedPreviewPanel] enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
    }
}

#pragma mark - CNGridView DataSource

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section {
    static NSString *reuseIdentifier = @"CNGridViewItem";
    
    CNGridViewItem *item = [gridView dequeueReusableItemWithIdentifier:reuseIdentifier];
    if (item == nil) {
        item = [[CNGridViewItem alloc] initWithLayout:self.defaultLayout reuseIdentifier:reuseIdentifier];
    }
    item.hoverLayout = self.hoverLayout;
    item.selectionLayout = self.selectionLayout;
    
    SlideshowItem *slideshowItem = [self.items objectAtIndex:index];
    item.itemTitle = [slideshowItem title];
    item.itemImage = [slideshowItem image];
    
    return item;
}

#pragma mark - CNGridView Delegate

- (void)gridView:(CNGridView *)gridView didSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {    
    [self setSelectedItems:[self.items objectsAtIndexes:[self.gridView selectedIndexes]]];
    
    [self.previewPanel reloadData];
}

- (void)gridView:(CNGridView *)gridView didDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
    [self setSelectedItems:[self.items objectsAtIndexes:[self.gridView selectedIndexes]]];
    
    [self.previewPanel reloadData];
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
    [self setPreviewPanel:panel];
    [panel setDelegate:self];
    [panel setDataSource:self];
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    // This document loses its responsisibility on the preview panel
    // Until the next call to -beginPreviewPanelControl: it must not
    // change the panel's delegate, data source or refresh it.
    //
    [self setPreviewPanel:nil];
}


#pragma mark - QLPreviewPanelDataSource

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{

    return self.selectedItems.count;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    return (self.selectedItems)[index];
}


#pragma mark - QLPreviewPanelDelegate

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
    // redirect all key down events to the table view
    if ([event type] == NSKeyDown)
    {
        [self.gridView keyDown:event];
        return YES;
    }
    return NO;
}

// this delegate method provides a transition image between the table view and the preview panel

- (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect
{
    SlideshowItem *slideshowItem = (SlideshowItem *)item;
    
    return slideshowItem.image;
}

@end
