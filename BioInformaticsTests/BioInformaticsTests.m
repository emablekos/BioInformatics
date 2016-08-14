//
//  BioInformaticsTests.m
//  BioInformaticsTests
//
//  Created by E.J. Mablekos on 8/14/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BioUtil.h"
#import "TestConfig.h"

@interface BioInformaticsTests : XCTestCase

@end

@implementation BioInformaticsTests


- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testReverseCompliment {
    NSString *s1 = @"ATGATCAAG";
    NSString *s2 = @"CTTGATCAT";

    XCTAssertEqualObjects([BioUtil reverseCompliment:s1], s2);
}

- (void)testMinSkew {
    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w2_minimum_skew_1.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\r\n"];

    NSString *g = [lines objectAtIndex:1];
    NSString *test = [lines objectAtIndex:3];

    NSArray *a = [BioUtil minimumSkewPositions:g];

    XCTAssertEqualObjects([a componentsJoinedByString:@" "], test);

    lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w2_minimum_skew_final.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\r\n"];
    g = [lines objectAtIndex:0];

    a = [BioUtil minimumSkewPositions:g];
    NSLog(@"%@",[a componentsJoinedByString:@" "]);

}


- (void)testHammingDistance {

    int ham = [BioUtil hammingDistance:@"GGGCCGTTGGT" other:@"GGACCGTTGAC"];
    XCTAssertEqual(ham, 3);

    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w2_ham_1.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"|"];

    ham = [BioUtil hammingDistance:[lines firstObject] other:[lines lastObject]];
    NSLog(@"%i",ham);

}

- (void)testApproximatePatternMatch {

    NSString *pattern = @"ATTCTGGA";
    NSString *genome = @"CGCCCGAATCCAGAACGCATTCCCATATTTCGGGACCACTGGCCTCCACGGTACGGACGTCAATCAAAT";
    int distance = 3;
    NSString *test = @"6 7 26 27";

    NSArray *locs = [BioUtil approximatePatternMatch:genome pattern:pattern distance:distance];

    XCTAssertEqualObjects(test, [locs componentsJoinedByString:@" "]);

    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w2_approximate.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    pattern = [lines firstObject];
    genome = [lines objectAtIndex:1];
    distance = [[lines objectAtIndex:2] intValue];
    test = @"6 7 26 27";

    locs = [BioUtil approximatePatternMatch:genome pattern:pattern distance:distance];
    NSLog(@"%@", [locs componentsJoinedByString:@" "]);

}

- (void)testApproximatePatternCount {

    NSString *pattern = @"GAGG";
    NSString *genome = @"TTTAGAGCCTTCAGAGG";
    int distance = 2;
    int test = 4;

    unsigned int count = [BioUtil approximatePatternCount:genome pattern:pattern distance:distance];

    XCTAssertEqual(test, count);

    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w2_approx_count.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    pattern = [lines firstObject];
    genome = [lines objectAtIndex:1];
    distance = [[lines objectAtIndex:2] intValue];

    count = [BioUtil approximatePatternCount:genome pattern:pattern distance:distance];
    NSLog(@"Approx count: %@", @(count));

}

- (void)testNeighbors {

    NSString *kmer = @"ACG";
    int distance = 1;
    NSSet *test = [NSSet setWithArray:[@"CCG,TCG,GCG,AAG,ATG,AGG,ACA,ACC,ACT,ACG" componentsSeparatedByString:@","]];

    NSArray *nbrs = [BioUtil neighbors:kmer distance:distance];
    XCTAssertEqualObjects(test, [NSSet setWithArray:nbrs]);

    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w2_neighbors.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\r\n"];

    kmer = [lines objectAtIndex:1];
    distance = [[lines objectAtIndex:2] intValue];
    test = [NSSet setWithArray:[lines subarrayWithRange:NSMakeRange(4, lines.count-5)]];
    nbrs = [BioUtil neighbors:kmer distance:distance];

    XCTAssertEqualObjects(test, [NSSet setWithArray:nbrs]);

    kmer = @"CTTTCTGTA";
    distance = 2;
    nbrs = [BioUtil neighbors:kmer distance:distance];

    NSLog(@"Neighbors: %@", [nbrs componentsJoinedByString:@"\r\n"]);

}

- (void)testFrequentWordsWithMismatches {

    NSString *text = @"ACGTTGCATGTCGCATGATGCATGAGAGCT";
    int k = 4;
    int d = 1;
    NSSet *test = [NSSet setWithArray:[@"GATG,ATGC,ATGT" componentsSeparatedByString:@","]];
    NSArray *words = [BioUtil frequentWordsWithMismatches:text k:k d:d];
    XCTAssertEqualObjects(test, [NSSet setWithArray:words]);

    // Comps

    text = @"ACGTTGCATGTCGCATGATGCATGAGAGCT";
    k = 4;
    d = 1;
    test = [NSSet setWithArray:[@"ATGT,ACAT" componentsSeparatedByString:@","]];
    words = [BioUtil frequentWordsWithMismatches:text k:k d:d reverse:YES];
    XCTAssertEqualObjects(test, [NSSet setWithArray:words]);



}


@end
