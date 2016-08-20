//
//  Motif.h
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/20/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProbabilityProfile.h"

@interface Motif : NSObject
+ (NSArray *)motifEnumeration:(NSArray *)dna k:(int)k d:(int)d;
+ (unsigned long)distanceBetweenPattern:(NSString *)pattern strings:(NSArray *)strings;
+ (NSString *)medianString:(NSArray *)dna k:(unsigned int)k;
+ (NSString *)mostProbableKmer:(NSString *)dna profile:(ProbabilityProfile *)profile k:(unsigned int)k;
+ (NSArray *)greedyMotifSearch:(NSArray *)dna k:(unsigned int)k t:(unsigned int)t pseudocounts:(BOOL)pseudocounts;

@end
