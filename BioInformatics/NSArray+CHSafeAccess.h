//
//  NSArray+CHSafeAccess.h
//  Emojiboard
//
//  Created by E.J. Mablekos on 9/6/14.
//  Copyright (c) 2014 Chappy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (CHSafeAccess)

- (id)CH_existingObjectAtIndex:(NSInteger)index;
- (id)CH_existingObjectAtIndex:(NSInteger)index1 index:(NSInteger)index2;
- (NSArray *)CH_trim:(NSInteger)length;
- (id)CH_existingObjectAtIndexPath:(NSIndexPath *)path;
@end
