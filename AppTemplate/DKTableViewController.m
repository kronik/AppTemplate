//
//  DKTableViewController.m
//  AppTemplate
//
//  Created by Dmitry Klimkin on 1/3/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import "DKTableViewController.h"

#define DKTableViewCellId @"regularTableViewCellIdentifier"

@interface DKTableViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation DKTableViewController

@synthesize tableView = _tableView;

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
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview: self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DKTableViewCellId forIndexPath:indexPath];
    
	[self configureCell:cell atIndex:indexPath];
    
    return cell;
}

- (void)registerCellClassesForTableView: (UITableView *)tableView {
    [tableView registerClass:[DKTableViewCell class] forCellReuseIdentifier:DKTableViewCellId];
}

- (void)configureCell:(DKTableViewCell *)cell atIndex:(NSIndexPath*)indexPath {
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) didSelectItem: (NSObject *)item {
    
}

- (void)deleteItem: (NSObject *)item {
    
}

- (void)tableView:(UITableView *)tableView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.items.count - 1) {
        [self didSelectItem: self.items [indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSObject *item = self.items [indexPath.row];

        [self deleteItem: item];
		[self saveChangesAsync];
        [self.items removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
