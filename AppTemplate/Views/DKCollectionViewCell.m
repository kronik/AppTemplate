//
//  DKCollectionView.m
//  AppTemplate
//
//  Created by Dmitry Klimkin on 28/2/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import "DKCollectionViewCell.h"

@interface DKCollectionViewCell ()

@end

@implementation DKCollectionViewCell

@synthesize item = _item;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setItem:(NSObject *)item {
    _item = item;
}

@end
