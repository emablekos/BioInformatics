//
//  Spectrometer.h
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/17/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Spectrometer : NSObject
@property (nonatomic) NSArray *expansionCandidates;

- (void)useNonproteogenicExpansionCandidates;

- (NSArray *)linearSpectrum:(NSString *)peptide;
- (NSArray *)cyclicSpectrum:(NSString *)peptide;
- (NSArray *)cyclopeptideSequencing:(NSString *)testSpectrum;
- (NSArray *)leaderboardCyclopeptideSequencing:(NSString *)testSpectrum cut:(NSInteger)cut;
- (NSArray *)weightsForProtein:(NSString *)protein;
- (NSInteger)scorePeptide:(NSString *)peptide againstSpectrum:(NSArray *)spectrum cyclic:(BOOL)cyclic;
- (NSInteger)scorePeptide2:(NSString *)peptide againstSpectrum:(NSArray *)spectrum cyclic:(BOOL)cyclic;
+ (NSArray *)spectrumFromString:(NSString *)string;
- (NSArray *)bestMatches:(NSArray *)peptides spectrum:(NSArray *)spectrum cut:(NSInteger)cut cyclic:(BOOL)cyclic;
@end
