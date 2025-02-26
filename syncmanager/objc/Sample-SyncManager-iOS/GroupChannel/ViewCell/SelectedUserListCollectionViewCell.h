//
//  SelectedUserListCollectionViewCell.h
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface SelectedUserListCollectionViewCell : UICollectionViewCell

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDUser *)aUser;

@end
