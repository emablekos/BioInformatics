//
//  Bio2Week3Tests.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/16/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RNAMapper.h"
#import "BioUtil.h"
#import "TestConfig.h"
#import "Spectrometer.h"
#import "NSArray+CHCollectionUtils.h"

@interface Bio2Week3Tests : XCTestCase

@end

@implementation Bio2Week3Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRNA {
    RNAMapper *r = [RNAMapper new];

    NSString *rna = @"UGAUGAAUGGCCAUGGCGCCCAGAACUGAGAUCAAUAGUACCCGUAUUAACGGGUGA";
    NSString *test = @"MAMAPRTEINSTRING";

    NSRange pRange;
    NSString *pro = [r translateRNA:rna readingFrame:0 resultRange:&pRange];
    XCTAssertEqualObjects(test, pro);
    XCTAssertEqual(pRange.location, 6);
    XCTAssertEqual(pRange.length, 48);

    rna = [NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w3_translate_rna.txt"] encoding:NSUTF8StringEncoding error:nil];

    pro = [r translateRNA:rna readingFrame:0 resultRange:&pRange];


}

- (void)testFindSubstrings {

    NSString *dna = @"ATGGCCATGGCCCCCAGAACTGAGATCAATAGTACCCGTATTAACGGGTGA";
    NSString *pro = @"MA";

    NSArray *test = [@"ATGGCC,GGCCAT,ATGGCC" componentsSeparatedByString:@","];

    RNAMapper *r = [RNAMapper new];
    NSArray *arr = [r findSubstringsInDNA:dna encoding:pro];
    XCTAssertEqualObjects([NSSet setWithArray:test], [NSSet setWithArray:arr]);

    arr = [r findSubstringsInDNA2:dna encoding:pro];
    XCTAssertEqualObjects([NSSet setWithArray:test], [NSSet setWithArray:arr]);
}

- (void)testTimeFindSubstrings1 {

    NSString *dna;
    NSString *pro;
    RNAMapper *r = [RNAMapper new];

    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w3_peptide_substring.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    dna = [lines objectAtIndex:0];
    pro = [lines objectAtIndex:1];

    [self measureBlock:^{
        NSArray *arr = [r findSubstringsInDNA:dna encoding:pro];
        NSLog(@"%@", [arr componentsJoinedByString:@"\n"]);
    }];
}

- (void)testTimeFindSubstrings2 {

    NSString *dna;
    NSString *pro;
    RNAMapper *r = [RNAMapper new];

    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w3_peptide_substring.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    dna = [lines objectAtIndex:0];
    pro = [lines objectAtIndex:1];

    [self measureBlock:^{
        NSArray *arr = [r findSubstringsInDNA2:dna encoding:pro];
        NSLog(@"%@", [arr componentsJoinedByString:@"\n"]);
    }];
}


- (void)testExpandProtein {

    RNAMapper *r = [RNAMapper new];

    NSString *pro = @"VKLFPWFNQY";
    NSArray *arr = [r expandProteinToRNA:pro];

    XCTAssertEqual(arr.count,4*2*6*2*4*1*2*2*2*2);
}

- (void)testLinearSpectrum {

    Spectrometer *s = [Spectrometer new];
    NSArray *ls = [s linearSpectrum:@"NQEL"];
    XCTAssertEqualObjects([ls componentsJoinedByString:@" "], @"0 113 114 128 129 242 242 257 370 371 484");

    NSArray *cls = [s cyclicSpectrum:@"LEQN"];
    XCTAssertEqualObjects([cls componentsJoinedByString:@" "], @"0 113 114 128 129 227 242 242 257 355 356 370 371 484");
}

- (void)testCyclopeptideSequencing {

    NSString *spectrum = @"0 113 128 186 241 299 314 427";
    NSArray *test = [@"186-128-113 186-113-128 128-186-113 128-113-186 113-186-128 113-128-186" componentsSeparatedByString:@" "];

    Spectrometer *s = [Spectrometer new];
    NSArray *seqs = [[s cyclopeptideSequencing:spectrum] CH_map:^id(NSArray *obj) {
        return [obj componentsJoinedByString:@"-"];
    }];
    XCTAssertEqualObjects([NSSet setWithArray:seqs], [NSSet setWithArray:test]);


    spectrum = @"0 71 97 99 103 113 113 114 115 131 137 196 200 202 208 214 226 227 228 240 245 299 311 311 316 327 337 339 340 341 358 408 414 424 429 436 440 442 453 455 471 507 527 537 539 542 551 554 556 566 586 622 638 640 651 653 657 664 669 679 685 735 752 753 754 756 766 777 782 782 794 848 853 865 866 867 879 885 891 893 897 956 962 978 979 980 980 990 994 996 1022 1093";
    test = [@"103-137-71-131-114-113-113-115-99-97 103-97-99-115-113-113-114-131-71-137 113-113-114-131-71-137-103-97-99-115 113-113-115-99-97-103-137-71-131-114 113-114-131-71-137-103-97-99-115-113 113-115-99-97-103-137-71-131-114-113 114-113-113-115-99-97-103-137-71-131 114-131-71-137-103-97-99-115-113-113 115-113-113-114-131-71-137-103-97-99 115-99-97-103-137-71-131-114-113-113 131-114-113-113-115-99-97-103-137-71 131-71-137-103-97-99-115-113-113-114 137-103-97-99-115-113-113-114-131-71 137-71-131-114-113-113-115-99-97-103 71-131-114-113-113-115-99-97-103-137 71-137-103-97-99-115-113-113-114-131 97-103-137-71-131-114-113-113-115-99 97-99-115-113-113-114-131-71-137-103 99-115-113-113-114-131-71-137-103-97 99-97-103-137-71-131-114-113-113-115" componentsSeparatedByString:@" "];

    seqs = [[s cyclopeptideSequencing:spectrum] CH_map:^id(NSArray *obj) {
        return [obj componentsJoinedByString:@"-"];
    }];
    XCTAssertEqualObjects([NSSet setWithArray:seqs], [NSSet setWithArray:test]);


    spectrum = @"0 97 99 103 103 115 115 128 131 137 163 218 218 227 230 231 234 246 252 260 266 330 345 346 349 349 355 358 363 381 397 445 448 452 461 473 478 483 500 512 512 576 576 576 580 582 609 611 615 615 615 679 679 691 708 713 718 730 739 743 746 794 810 828 833 836 842 842 845 846 861 925 931 939 945 957 960 961 964 973 973 1028 1054 1060 1063 1076 1076 1088 1088 1092 1094 1191";

    seqs = [[s cyclopeptideSequencing:spectrum] CH_map:^id(NSArray *obj) {
        return [obj componentsJoinedByString:@"-"];
    }];
    NSLog(@"%@", [seqs componentsJoinedByString:@" "]);
}


@end
