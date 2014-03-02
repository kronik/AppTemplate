//
//  DKHomeViewController.m
//  AppTemplate
//
//  Created by Dmitry Klimkin on 26/2/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import "DKHomeViewController.h"

@interface DKHomeViewController ()

@end

@implementation DKHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Home";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showMenu)];
}

- (void)showMenu {
    [self.sideMenuViewController presentMenuViewController];
}

@end
