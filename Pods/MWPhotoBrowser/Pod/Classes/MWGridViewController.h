//
//  MWGridViewController.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface MWGridViewController : UICollectionViewController <UIGestureRecognizerDelegate> {
    UIToolbar *_toolbar;
    UIBarButtonItem *_actionButton;
}

@property (nonatomic, assign) MWPhotoBrowser *browser;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) CGPoint initialContentOffset;
@property (nonatomic) UIColor* gridColor;

- (void)adjustOffsetsAsRequired;
- (void)setGridControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;

@end
