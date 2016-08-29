//
//  ProbabilityProfileTests.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/24/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ProbabilityProfile.h"

@interface ProbabilityProfileTests : XCTestCase

@end

@implementation ProbabilityProfileTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProbabilityProfile {

    NSArray *lines =
    @[@"0.2 0.2 0.3 0.2 0.3",
      @"0.4 0.3 0.1 0.5 0.1",
      @"0.3 0.3 0.5 0.2 0.4",
      @"0.1 0.2 0.1 0.1 0.2",
      ];

    ProbabilityProfile *pp = [[ProbabilityProfile alloc] initWithLines:lines];

    XCTAssertEqualWithAccuracy([pp valueFor:@"A" index:1], .2, .01);
    XCTAssertEqualWithAccuracy([pp valueFor:@"C" index:3], .5, .01);
    XCTAssertEqualWithAccuracy([pp valueFor:@"T" index:4], .2, .01);

    CGFloat v = [pp probabilityOfKmer:@"ACGTT"];
    XCTAssertEqualWithAccuracy(v, .2f*.3f*.5f*.1f*.2f , .01);


    NSArray *motifs =
    @[
      @"ACAAA",
      @"ACAAC",
      @"ACATG",
      @"ACATT",
      ];
    ProbabilityProfile *pp2 = [[ProbabilityProfile alloc] initWithMotifs:motifs];

    lines =
    @[@"1.0 0.0 1.0 0.5 0.25",
      @"0.0 1.0 0.0 0.0 0.25",
      @"0.0 0.0 0.0 0.0 0.25",
      @"0.0 0.0 0.0 0.5 0.25",
      ];
    ProbabilityProfile *pp3 = [[ProbabilityProfile alloc] initWithLines:lines];
    XCTAssertEqualObjects(pp2, pp3);

    motifs =
    @[
      @"TCGGGGGTTTTT",
      @"CCGGTGACTTAC",
      @"ACGGGGATTTTC",
      @"TTGGGGACTTTT",
      @"AAGGGGACTTCC",
      @"TTGGGGACTTCC",
      @"TCGGGGATTCAT",
      @"TCGGGGATTCCT",
      @"TAGGGGAACTAC",
      @"TCGGGTATAACC"
      ];
    ProbabilityProfile *pp4 = [[ProbabilityProfile alloc] initWithMotifs:motifs];
    XCTAssertEqualObjects([pp4 consensusString], @"TCGGGGATTTCC");
    XCTAssertEqual([pp4 scoreMotifs:motifs], 30);
    
}


- (void)testRandomGeneration {

    NSArray *lines =
    @[@"1.0 1.0 1.0 0.0 0.0 0.0",
      @"0.0 0.0 0.0 0.0 0.0 0.0",
      @"0.0 0.0 0.0 0.0 0.0 0.0",
      @"0.0 0.0 0.0 1.0 1.0 1.0",
      ];

    ProbabilityProfile *pp = [[ProbabilityProfile alloc] initWithLines:lines];

    NSString *test = [pp randomWeightedKmer:@"CCCCCCCCAAATTTCCCCCCCCCC"];
    XCTAssertEqualObjects(test, @"AAATTT");

    test = [pp randomWeightedKmer:@"AAATTTCCCCCCCCCCCCCCCCCC"];
    XCTAssertEqualObjects(test, @"AAATTT");

    test = [pp randomWeightedKmer:@"CCCCCCCCCCCCCCCCCCAAATTT"];
    XCTAssertEqualObjects(test, @"AAATTT");

    lines =
    @[@"0.5 0.5 0.5 0.5 0.5 0.5",
      @"0.0 0.0 0.0 0.0 0.0 0.0",
      @"0.0 0.0 0.0 0.0 0.0 0.0",
      @"0.5 0.5 0.5 0.5 0.5 0.5",
      ];

    //pp = [[ProbabilityProfile alloc] initWithLines:lines];

    test = [pp randomWeightedKmer:@"AAAAAACCCCCCCCCCCCCCCCCCTTTTTT"];
    XCTAssert([test isEqualToString:@"AAAAAA"] || [test isEqualToString:@"TTTTTT"]);

}

@end
