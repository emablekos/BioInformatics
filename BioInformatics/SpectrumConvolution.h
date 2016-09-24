//
//  SpectrumConvolution.h
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/23/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpectrumConvolution : NSObject
@property (nonatomic) NSUInteger min;
@property (nonatomic) NSUInteger max;

- (void)calculate:(NSArray *)spectrum;
- (NSString *)stringValue;
- (NSArray *)mostFrequentElements:(int)count;
- (NSArray *)elements;
@end
