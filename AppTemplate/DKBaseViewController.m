//
//  DKBaseViewController.m
//  AppTemplate
//
//  Created by Dmitry Klimkin on 27/2/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import "DKBaseViewController.h"
#import "MRProgress.h"

@interface DKBaseViewController () <UISearchBarDelegate>

@property (nonatomic, strong) MRProgressOverlayView *progressView;

@end

@implementation DKBaseViewController

@synthesize items = _items;
@synthesize searchBar = _searchBar;
@synthesize progressView = _progressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self customInit];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        [self customInit];
    }
    return self;
}

- (void)customInit {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = [UIColor whiteColor];

    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController interactivePopGestureRecognizer];
}

- (void)updateUI {
    [self hideIndicator];
}

- (void)fetchAllItems {
    [self updateUI];
}

- (void)fetchItemsWithPattern: (NSString *)pattern {
    
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchAllItems];
}

- (void)saveChangesAsync {
    
    [self showBigBusyIndicatorWithTitle: NSLocalizedString(@"Saving...", nil)];
    
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
		if (success) {
			NSLog(@"You successfully saved your context.");
            
            [self showCompleteIndicatorWithTitle:NSLocalizedString(@"Done!", nil)];
            
		} else if (error) {
			NSLog(@"Error saving context: %@", error.description);
            
            [self showCompleteIndicatorWithTitle:NSLocalizedString(@"Failed to save!", nil)];
		}
	}];
}

- (void)saveChangesSync {
	// Save ManagedObjectContext using MagicalRecord
	[[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

#pragma mark - Search Bar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if (self.searchBar.text.length > 0) {
		[self doSearch];
	} else {
		[self fetchAllItems];
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self.searchBar resignFirstResponder];
	// Clear search bar text
	self.searchBar.text = @"";
	// Hide the cancel button
	self.searchBar.showsCancelButton = NO;
	// Do a default fetch of the beers
	[self fetchAllItems];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	self.searchBar.showsCancelButton = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[self.searchBar resignFirstResponder];
	[self doSearch];
}

- (void)doSearch {
	// 1. Get the text from the search bar.
	NSString *searchText = self.searchBar.text;
    
    [self showSmallBusyIndicatorWithTitle: NSLocalizedString(@"Updating...", nil)];
    [self fetchItemsWithPattern: searchText];
}

- (void)showCompleteIndicator {
    [self showCompleteIndicatorWithTitle:@""];
}

- (void)showCompleteIndicatorWithTitle: (NSString *)title {
    if (self.progressView) {
        [self.progressView dismiss:NO];
    }
    
    self.progressView = [MRProgressOverlayView new];
    self.progressView.mode = MRProgressOverlayViewModeCheckmark;
    self.progressView.titleLabelText = title;
    
    [self showIndicator];
}

- (void)showErrorIndicator {
    [self showErrorIndicatorWithTitle:@""];
}

- (void)showErrorIndicatorWithTitle: (NSString *)title {
    
    if (self.progressView) {
        [self.progressView dismiss:NO];
    }
    
    self.progressView = [MRProgressOverlayView new];
    self.progressView.mode = MRProgressOverlayViewModeCross;
    self.progressView.titleLabelText = title;
    
    [self showIndicator];
}

- (void)showBigBusyIndicator {
    [self showBigBusyIndicatorWithTitle:@""];
}

- (void)showBigBusyIndicatorWithTitle: (NSString *)title {
    
    if (self.progressView) {
        [self.progressView dismiss:NO];
    }
    
    self.progressView = [MRProgressOverlayView new];
    self.progressView.titleLabelText = title;
    
    [self showIndicator];
}

- (void)showSmallBusyIndicator {
    [self showSmallBusyIndicatorWithTitle:@""];
}

- (void)showSmallBusyIndicatorWithTitle: (NSString *)title {
    
    if (self.progressView) {
        [self.progressView dismiss:NO];
    }
    
    self.progressView = [MRProgressOverlayView new];
    self.progressView.mode = MRProgressOverlayViewModeIndeterminateSmall;
    self.progressView.titleLabelText = title;
    
    [self showIndicator];
}

- (void)showIndicator {
    
    self.progressView.tintColor = ApplicationMainColor;
    
    [self.view addSubview:self.progressView];
    [self.progressView show:YES];
}

- (void)hideIndicator {
    [self.progressView dismiss:YES completion:^{
        self.progressView = nil;
    }];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
