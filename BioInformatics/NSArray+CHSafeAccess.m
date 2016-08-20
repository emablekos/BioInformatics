//
//  NSArray+CHSafeAccess.m
//  Emojiboard
//
//  Created by E.J. Mablekos on 9/6/14.
//  Copyright (c) 2014 Chappy. All rights reserved.
//

#import "NSArray+CHSafeAccess.h"


@implementation NSArray (CHSafeAccess)

- (id)CH_existingObjectAtIndex:(NSInteger)index {
    if (index < 0) {
        return nil;
    } else if (index >= self.count) {
        return nil;
    }
    return [self objectAtIndex:index];
}
- (id)CH_existingObjectAtIndexPath:(NSIndexPath *)path {
    return [self CH_existingObjectAtIndex:[path indexAtPosition:0] index:[path indexAtPosition:1]];
}

- (id)CH_existingObjectAtIndex:(NSInteger)index1 index:(NSInteger)index2 {
    NSArray *arr = (NSArray *)[self CH_existingObjectAtIndex:index1];
    if ([arr isKindOfClass:[NSArray class]]) {
        return [arr CH_existingObjectAtIndex:index2];
    }
    return nil;
}

- (NSArray *)CH_trim:(NSInteger)length {
    return [self subarrayWithRange:NSMakeRange(0, MIN(length, self.count))];
}
@end
