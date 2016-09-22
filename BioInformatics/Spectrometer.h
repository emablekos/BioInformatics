//
//  Spectrometer.h
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/17/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Spectrometer : NSObject
- (NSArray *)linearSpectrum:(NSString *)peptide;
- (NSArray *)cyclicSpectrum:(NSString *)peptide;
- (NSArray *)cyclopeptideSequencing:(NSString *)testSpectrum;
- (NSArray *)weightsForProtein:(NSString *)protein;
@end
