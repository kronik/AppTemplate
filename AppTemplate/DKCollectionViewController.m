//
//  DKCollectionViewController.m
//  AppTemplate
//
//  Created by Dmitry Klimkin on 27/2/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import "DKCollectionViewController.h"
#import "THSpringyFlowLayout.h"

#define DKCollectionViewCellId @"regularCollectionViewCellIdentifier"

@interface DKCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation DKCollectionViewController

@synthesize collectionView = _collectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    THSpringyFlowLayout *flowLayout = [[THSpringyFlowLayout alloc] init];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout: flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.view addSubview: self.collectionView];
}

#pragma mark - UICollectionViewDataSource & Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DKCollectionViewCellId
                                                                           forIndexPath:indexPath];
	[self configureCell:cell atIndex:indexPath];

    return cell;
}

- (void)registerCellClassesForCollectionView: (UICollectionView *)collectionView {
    [collectionView registerClass:[DKCollectionViewCell class]
       forCellWithReuseIdentifier:DKCollectionViewCellId];
}

- (void)configureCell:(DKCollectionViewCell *)cell atIndex:(NSIndexPath*)indexPath {
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) didSelectItem: (NSObject *)item {
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.items.count - 1) {
        [self didSelectItem: self.items [indexPath.row]];
    }
}

@end
