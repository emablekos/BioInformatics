//
//  Bio2Week4Tests.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/17/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestConfig.h"
#import "Spectrometer.h"
#import "BioUtil.h"
#import "NSArray+CHCollectionUtils.h"
#import "SpectrumConvolution.h"

@interface Bio2Week4Tests : XCTestCase

@end

@implementation Bio2Week4Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCyclopeptideScoring {

    Spectrometer *s = [Spectrometer new];
    NSString *peptide = @"NQEL";
    NSArray *spectrum = [Spectrometer spectrumFromString:@"0 99 113 114 128 227 257 299 355 356 370 371 484"];
    NSInteger t = [s scorePeptide:peptide againstSpectrum:spectrum cyclic:YES];
    XCTAssertEqual(t, 11);
    t = [s scorePeptide2:peptide againstSpectrum:spectrum cyclic:YES];
    XCTAssertEqual(t, 11);

    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w4_score.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    peptide = [lines firstObject];
    spectrum = [Spectrometer spectrumFromString:[lines objectAtIndex:1]];

    t = [s scorePeptide:peptide againstSpectrum:spectrum cyclic:YES];
    XCTAssertEqual(t, 474);
    t = [s scorePeptide2:peptide againstSpectrum:spectrum cyclic:YES];
    XCTAssertEqual(t, 474);
}

- (void)testTimeCyclopeptideScoring1 {

    Spectrometer *s = [Spectrometer new];
    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w4_score.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];

    [self measureBlock:^{
        NSString *peptide;
        NSArray *spectrum;

        peptide = [lines firstObject];
        spectrum = [Spectrometer spectrumFromString:[lines objectAtIndex:1]];

        NSInteger t = [s scorePeptide:peptide againstSpectrum:spectrum cyclic:YES];
        XCTAssertEqual(t, 474);
    }];
}

- (void)testTimeCyclopeptideScoring2 {

    Spectrometer *s = [Spectrometer new];
    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w4_score.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];

    [self measureBlock:^{
        NSString *peptide;
        NSArray *spectrum;

        peptide = [lines firstObject];
        spectrum = [Spectrometer spectrumFromString:[lines objectAtIndex:1]];

        NSInteger t = [s scorePeptide2:peptide againstSpectrum:spectrum cyclic:YES];
        XCTAssertEqual(t, 474);
    }];
}

- (void)testBestMatches {

    Spectrometer *s = [Spectrometer new];
    NSArray *peptides = [@"LAST ALST TLLT TQAS" componentsSeparatedByString:@" "];
    NSArray *spectrum = [Spectrometer spectrumFromString:@"0 71 87 101 113 158 184 188 259 271 372"];
    NSUInteger cut = 2;
    NSArray *test = [@"LAST ALST" componentsSeparatedByString:@" "];

    NSArray *best = [s bestMatches:peptides spectrum:spectrum cut:cut cyclic:NO];
    XCTAssertEqualObjects([NSSet setWithArray:best], [NSSet setWithArray:test]);

    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w4_trim.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    peptides = [[lines firstObject] componentsSeparatedByString:@" "];
    spectrum = [Spectrometer spectrumFromString:[lines objectAtIndex:1]];
    cut = [[lines objectAtIndex:2] integerValue];
    best = [s bestMatches:peptides spectrum:spectrum cut:cut cyclic:NO];


}

- (void)testCyclopeptideSequencing {

    NSString *spectrum = @"0 71 113 129 147 200 218 260 313 331 347 389 460";
    NSUInteger cut = 10;

    Spectrometer *s = [Spectrometer new];
    NSString *seq = [[s leaderboardCyclopeptideSequencing:spectrum cut:cut] componentsJoinedByString:@"-"];
    XCTAssertEqualObjects(seq, @"113-147-71-129");

    /*
    s.nonproteinogenic = YES;
    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w4_leaderboardseq.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    cut = [lines[0] integerValue];
    spectrum = lines[1];
    seq = [[s leaderboardCyclopeptideSequencing:spectrum cut:cut] componentsJoinedByString:@"-"];
     */
}

- (void)testSpectrumConvolution {

    SpectrumConvolution *c = [SpectrumConvolution new];
    [c calculate:[Spectrometer spectrumFromString:@"0 137 186 323"]];
    NSArray *test = [Spectrometer spectrumFromString:@"49 137 137 186 186 323"];
    NSArray *els = [[c elements] sortedArrayUsingSelector:@selector(compare:)];
    XCTAssertEqualObjects(els, test);

    NSArray *freq = [c mostFrequentElements:3];
    XCTAssertEqual(freq.count, 4);

}

- (void)testConvolutionSequencing {

    int m = 20;
    int n = 60;
    NSString *spectrum = @"57 57 71 99 129 137 170 186 194 208 228 265 285 299 307 323 356 364 394 422 493";

    SpectrumConvolution *c = [SpectrumConvolution new];
    c.min = 57;
    c.max = 200;
    [c calculate:[Spectrometer spectrumFromString:spectrum]];
    NSArray *freq = [c mostFrequentElements:m];

    Spectrometer *s = [Spectrometer new];
    s.expansionCandidates = freq;

    NSArray *seq = [s leaderboardCyclopeptideSequencing:spectrum cut:n];
    XCTAssertEqual(seq.count, 6);



    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w4_convolutionseq.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    m = [lines[0] intValue];
    n = [lines[1] intValue];
    spectrum = lines[2];

    c = [SpectrumConvolution new];
    c.min = 57;
    c.max = 200;
    [c calculate:[Spectrometer spectrumFromString:spectrum]];
    freq = [c mostFrequentElements:m];

    s = [Spectrometer new];
    s.expansionCandidates = freq;

    seq = [s leaderboardCyclopeptideSequencing:spectrum cut:n];


}


@end
