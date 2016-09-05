//
//  GraphUtil.h
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/30/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Graph.h"

@interface GraphUtil : NSObject
+ (Graph *)overlapGraph:(NSArray *)kmers;
+ (Graph *)debruijnGraph1:(NSString *)str k:(NSUInteger)k;
+ (Graph *)debruijnGraphFromKmers:(NSArray *)kmers;
@end
