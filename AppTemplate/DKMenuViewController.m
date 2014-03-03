//
//  DKMenuViewController.m
//  AppTemplate
//
//  Created by Dmitry Klimkin on 26/2/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import "DKMenuViewController.h"
#import "DKHomeViewController.h"
#import "DKSettingsViewController.h"
#import "DKCollectionViewCell.h"

#define DKMenuViewControllerCellId @"DKMenuViewControllerCellId"

@interface DKMenuViewController ()

@property (nonatomic, strong) NSArray *titles;

@end

@implementation DKMenuViewController

@synthesize titles = _titles;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = @[@"Home", @"Settings"];
    self.items = [self.titles mutableCopy];
    
    self.collectionView.frame = CGRectMake(0, (self.view.frame.size.height - 54 * 5) / 2.0f, self.view.frame.size.width, 54 * 5);
    self.collectionView.center = CGPointMake(20 + ScreenWidth / 2, self.view.frame.size.height / 2);
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)configureCell:(DKCollectionViewCell *)cell atIndex:(NSIndexPath*)indexPath {
    
    cell.backgroundColor = [UIColor clearColor];
    cell.label.font = [UIFont fontWithName:ApplicationLightFont size:cell.frame.size.height * 0.7];
    cell.label.textColor = [UIColor whiteColor];
    cell.label.highlightedTextColor = [UIColor lightGrayColor];
    cell.label.textAlignment = NSTextAlignmentLeft;
    
    cell.title = self.titles[indexPath.row];
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    
    self.items = [titles mutableCopy];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [self performSelector:@selector(addFirstItem) withObject:nil afterDelay:1];
//}
//
//- (void)addFirstItem {
//    self.titles = @[@"Home"];
//    [self.collectionView insertItemsAtIndexPaths: @[[NSIndexPath indexPathForRow:self.titles.count - 1 inSection:0]]];
//    
//    [self performSelector:@selector(addSecondItem) withObject:nil afterDelay:1];
//}
//
//- (void)addSecondItem {
//    self.titles = @[@"Home", @"Settings"];
//    [self.collectionView insertItemsAtIndexPaths: @[[NSIndexPath indexPathForRow:self.titles.count - 1 inSection:0]]];
//}

- (void)didSelectItem:(NSObject *)item atIndex:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            self.sideMenuViewController.contentViewController = [[UINavigationController alloc] initWithRootViewController:[[DKHomeViewController alloc] init]];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[DKSettingsViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        default:
            break;
    }
}

@end
