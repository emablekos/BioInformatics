//
//  NSArray+CHCollectionUtils.h
//  ChappySDK
//
//  Created by E.J. Mablekos on 1/13/14.
//  Copyright (c) 2014 Chappy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (CHCollectionUtils)
- (NSArray *)CH_map:(id (^)(id obj))block;
- (NSArray *)CH_filter:(BOOL (^)(id obj))block;
- (NSDictionary *)CH_indexToKeys:(id<NSCopying> (^)(id obj))block;
- (NSArray *)CH_flatten;
- (id)CH_reduce:(id (^)(id result, id obj))block;
- (NSArray *)CH_shuffle;
@end
