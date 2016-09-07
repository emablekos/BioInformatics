//
//  Graph.h
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/30/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphNode : NSObject <NSCopying>
@property (nonatomic,readonly) NSString *label;
@end

@interface GraphEdge : NSObject
@property (nonatomic) GraphNode *from;
@property (nonatomic) GraphNode *to;
@property (nonatomic) NSString *label;
@end

@interface GraphPath : NSObject
- (instancetype)initWithString:(NSString *)string;
- (BOOL)isCycle;
- (void)follow:(GraphEdge *)edge to:(GraphNode *)node;
- (NSEnumerator *)edgeEnumerator;
- (NSEnumerator *)nodeEnumerator;
@end

@interface Graph : NSObject

- (instancetype)initWithAdjacencyList:(NSString *)list;
- (GraphNode *)addNodeForLabel:(NSString *)label;
- (GraphNode *)addNode:(GraphNode *)node;
- (GraphEdge *)addEdge:(GraphNode *)from to:(GraphNode *)to;
- (NSArray *)nodesForLabel:(NSString *)label;
- (NSArray *)edgesFrom:(GraphNode *)from;
- (NSArray *)edgesTo:(GraphNode *)to;
- (NSEnumerator *)nodeEnumerator;
- (NSString *)adjacencyDescription;
- (BOOL)node:(GraphNode *)from isAdjacent:(GraphNode *)to;

- (NSArray *)hamiltonianPaths:(GraphNode *)from;

@end


@interface EulerPathfinder : NSObject
- (instancetype)initWithGraph:(Graph *)graph node:(GraphNode *)node;
- (GraphPath *)find;
@end


