//
//  DKBaseViewController.h
//  AppTemplate
//
//  Created by Dmitry Klimkin on 27/2/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKBaseViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UISearchBar *searchBar;

- (void)customInit;
- (void)updateUI;

- (void)fetchAllItems;
- (void)fetchItemsWithPattern: (NSString *)pattern;

- (void)saveChangesAsync;
- (void)saveChangesSync;

- (void)showCompleteIndicator;
- (void)showCompleteIndicatorWithTitle: (NSString *)title;
- (void)showErrorIndicator;
- (void)showErrorIndicatorWithTitle: (NSString *)title;
- (void)showBigBusyIndicator;
- (void)showBigBusyIndicatorWithTitle: (NSString *)title;
- (void)showSmallBusyIndicator;
- (void)showSmallBusyIndicatorWithTitle: (NSString *)title;
- (void)hideIndicator;

@end
