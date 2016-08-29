//
//  ProbabilityProfile.h
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/20/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProbabilityProfile : NSObject
@property (nonatomic,readonly) unsigned long k;

- (instancetype)initWithLines:(NSArray *)lines;
- (instancetype)initWithMotifs:(NSArray *)motifs;
- (instancetype)initWithMotifs:(NSArray *)motifs pseudocounts:(BOOL)pseudocounts;
- (CGFloat)valueFor:(NSString *)base index:(unsigned long)index;
- (CGFloat)probabilityOfKmer:(NSString *)kmer;
- (NSString *)consensusString;
- (unsigned int)scoreMotifs:(NSArray *)arr;
- (NSString *)randomWeightedKmer:(NSString *)dna;
@end
