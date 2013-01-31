//
//  LHDropDownControlView.h
//  DropDownControl
//
//  Created by Lukas Heiniger on 06.12.12.
//  Copyright (c) 2012 cyclus.ch, L. Heiniger. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kOptionHeight       (UIInterfaceIdiomIsPad()?40:30)

@class LHDropDownControlView;



@protocol LHDropDownControlViewDelegate <NSObject>

// Selection contains the user selected option or nil if nothing was selected
- (void)dropDownControlView:(LHDropDownControlView *)view didFinishWithSelection:(id)selection;

@optional

// You can use this to disable scrolling on a tableView
- (void)dropDownControlViewWillBecomeActive:(LHDropDownControlView *)view;

@end



@interface LHDropDownControlView : UIView

@property (nonatomic, assign) CGRect mBaseFrame;
@property (nonatomic) NSString *title;
@property (nonatomic, weak) IBOutlet id<LHDropDownControlViewDelegate> delegate;
@property (nonatomic, assign) BOOL isContracted;

- (void)setSelectionOptions:(NSArray *)selectionOptions withTitles:(NSArray *)selectionOptionTitles;
- (CATransform3D)contractedTransorm;
- (void)setContracted;
- (void)setUncontracted;
@end
