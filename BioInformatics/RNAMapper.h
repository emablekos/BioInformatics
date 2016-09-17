//
//  RNAMapper.h
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/16/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNAMapper : NSObject
- (NSString *)translateRNA:(NSString *)rna;
- (NSString *)translateRNA:(NSString *)rna readingFrame:(int)readingFrame resultRange:(NSRange *)range;
- (NSArray *)findSubstringsInDNA:(NSString *)rna encoding:(NSString *)protein;
- (NSArray *)findSubstringsInDNA2:(NSString *)dna encoding:(NSString *)protein;
- (NSArray *)expandProteinToRNA:(NSString *)protein;

@end
