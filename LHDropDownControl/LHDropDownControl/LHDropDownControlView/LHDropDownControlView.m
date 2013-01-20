//
//  LHDropDownControlView.m
//  DropDownControl
//
//  Created by Lukas Heiniger on 06.12.12.
//  Copyright (c) 2012 cyclus.ch, L. Heiniger. All rights reserved.
//

#import "LHDropDownControlView.h"
#import <QuartzCore/QuartzCore.h>

#define kOptionHeight 20
#define kOptionSpacing 2
#define kAnimationDuration 0.2

@implementation LHDropDownControlView {
    
    // Configuration
    NSArray *mSelectionOptions, *mSelectionTitles;

    // Subviews
    UILabel *mTitleLabel;
    UIImage *mBgImage;
    NSMutableArray *mSelectionCells;
    
    // Control state
    BOOL mControlIsActive;
    NSInteger mSelectionIndex;
    NSInteger mPreviousSelectionIndex;
}


#pragma mark - Object Life Cycle

- (void)initialize
{
    // Background
    mBgImage = [[UIImage imageNamed:@"dropdown_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImageView *backGroundView = [[UIImageView alloc] initWithImage:mBgImage];
    [backGroundView setAlpha:.75];
    backGroundView.frame = self.bounds;
    [backGroundView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self addSubview:backGroundView];
    
    // Title
    mTitleLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5, 0)];
    mTitleLabel.textAlignment = NSTextAlignmentCenter;
    mTitleLabel.textColor = [UIColor whiteColor];
    mTitleLabel.backgroundColor = [UIColor clearColor];
    
    [mTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    mTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:mTitleLabel];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mBaseFrame = frame;
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}


#pragma mark - Accessors

- (void)setTitle:(NSString *)title {
    _title = title;
    mTitleLabel.text = title;
}


#pragma mark - Configuration

- (void)setSelectionOptions:(NSArray *)selectionOptions withTitles:(NSArray *)selectionOptionTitles {
    if ([selectionOptions count] != [selectionOptionTitles count]) {
        [NSException raise:NSInternalInconsistencyException format:@"selectionOptions and selectionOptionTitles must contain the same number of objects"];
    }
    mSelectionOptions = selectionOptions;
    mSelectionTitles = selectionOptionTitles;
    mSelectionCells = nil;
}


#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] != 1)
        return;
    
    UITouch *touch = [touches anyObject];
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        [self activateControl];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] != 1)
        return;
    
    UITouch *touch = [touches anyObject];
    
    // Calculate the selection index
    CGPoint location = [touch locationInView:self];
    if ((CGRectContainsPoint(self.bounds, location))) {
        mSelectionIndex = location.y / (kOptionHeight + kOptionSpacing);
    } else {
        mSelectionIndex = NSNotFound;
    }
    
    if (mSelectionIndex == mPreviousSelectionIndex || mSelectionIndex >= mSelectionCells.count)
        return;
    
    // Selection animation
    if (mSelectionIndex != NSNotFound) {
        UIView *cell = [mSelectionCells objectAtIndex:mSelectionIndex];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            cell.frame = CGRectInset(cell.frame, -6, 0);
        }];
    }
    if (mPreviousSelectionIndex != NSNotFound) {
        UIView *cell = [mSelectionCells objectAtIndex:mPreviousSelectionIndex];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            cell.frame = CGRectInset(cell.frame, 6, 0);
        }];
    }
    mPreviousSelectionIndex = mSelectionIndex;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (mControlIsActive) {
        if (mSelectionIndex < [mSelectionOptions count]) {
            [self.delegate dropDownControlView:self didFinishWithSelection:[mSelectionOptions objectAtIndex:(mSelectionCells.count-1)-mSelectionIndex]];
        } else {
            [self.delegate dropDownControlView:self didFinishWithSelection:nil];
        }
        [self inactivateControl];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (mControlIsActive) {
        [self inactivateControl];
    }
}

#pragma mark - View Transformation

- (CATransform3D)contractedTransorm {
    CATransform3D t = CATransform3DIdentity;
    t = CATransform3DRotate(t, M_PI / 2 , 1, 0, 0);
    t.m34 = 1.0/50;
    return t;
}

#pragma mark - Control Activation / Deactivation

- (void)activateControl {
    mControlIsActive = YES;
    
    mSelectionIndex = NSNotFound;
    mPreviousSelectionIndex = NSNotFound;
    
    if ([self.delegate respondsToSelector:@selector(dropDownControlViewWillBecomeActive:)]) {
        [self.delegate dropDownControlViewWillBecomeActive:self];
    }
    
    // Prepare the selection cells
    if (mSelectionCells == nil) {
        mSelectionCells = [NSMutableArray arrayWithCapacity:0];
        for (int i=[mSelectionTitles count]-1; i >= 0; i--) {
            UIImageView *newCell = [[UIImageView alloc] initWithImage:mBgImage];
            newCell.frame = CGRectMake(0, self.mBaseFrame.size.height + (i * kOptionHeight + kOptionSpacing) - kOptionSpacing, self.mBaseFrame.size.width, self.mBaseFrame.size.height);
            newCell.layer.anchorPoint = CGPointMake(0.5, 0.0);
            newCell.layer.transform = [self contractedTransorm];
            newCell.alpha = .8;
            
            UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectInset(newCell.bounds, 10, 0)];
            newLabel.font = [UIFont systemFontOfSize:14];
            newLabel.backgroundColor = [UIColor clearColor];
            newLabel.textColor = [UIColor whiteColor];
            newLabel.text = [mSelectionTitles objectAtIndex:i];
            [newCell addSubview:newLabel];
            
            [newCell.layer setAnchorPoint:CGPointMake(.5, 1)];
            
            [self addSubview:newCell];
            [mSelectionCells addObject:newCell];
        }
    }
    
    // Expand our frame
    CGRect newFrame = self.mBaseFrame;
    newFrame.origin.y -= [mSelectionOptions count] * (kOptionHeight + kOptionSpacing);
    newFrame.size.height += [mSelectionOptions count] * (kOptionHeight + kOptionSpacing);
    self.frame = newFrame;

    // Show selection cells animated
    int count = [mSelectionCells count];
    for (int i = count-1; i >= 0; i--) {
        UIView *cell = [mSelectionCells objectAtIndex:i];
        cell.alpha = .8;
        [UIView animateWithDuration:kAnimationDuration delay:(((count-1)-i) * kAnimationDuration / count) options:0 animations:^{
            CGRect destinationFrame = CGRectMake(0, 0 + i * (kOptionHeight + kOptionSpacing), self.mBaseFrame.size.width, kOptionHeight);
            cell.frame = destinationFrame;
            cell.layer.transform = CATransform3DIdentity;
        } completion:nil];
    }
}

- (void)inactivateControl {
    mControlIsActive = NO;
    
    [self.delegate dropDownControlView:self didFinishWithSelection:nil];
    
    int count = [mSelectionCells count];
    for (int i = 0; i < count; i++) {
        UIView *cell = [mSelectionCells objectAtIndex:i];
        [UIView animateWithDuration:kAnimationDuration delay:((count - 1 - i) * kAnimationDuration / count) options:0 animations:^{
            cell.frame = CGRectMake(0, self.mBaseFrame.size.height + (i * kOptionHeight + kOptionSpacing) - kOptionSpacing, self.mBaseFrame.size.width, self.mBaseFrame.size.height);
            cell.layer.transform = [self contractedTransorm];
        } completion:^(BOOL completed){
            cell.alpha = 0;
            if (i == 0) {
                self.frame = self.mBaseFrame;
            }
    }];
    }
}

@end
