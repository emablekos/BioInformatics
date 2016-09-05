//
//  Graph.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/30/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import "Graph.h"
#import "NSArray+CHCollectionUtils.h"

@interface GraphNode()
@property (nonatomic,readwrite) NSString *label;
@end

@implementation GraphNode

- (id)copyWithZone:(NSZone *)zone {
    GraphNode *node = [[[self class] allocWithZone:zone] init];
    node->_label = self->_label;
    return node;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@", self.label];
}


@end


@interface GraphEdge()

@end

@implementation GraphEdge

@end


@interface Graph()
@property (nonatomic) NSMutableArray *nodes;
@property (nonatomic) NSMutableDictionary *edges;
@property (nonatomic) NSMapTable *labelNodeMap;
@end

@implementation Graph

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nodes = [NSMutableArray array];
        self.edges = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithAdjacencyList:(NSString *)list {
    self = [self init];
    if (self) {
        NSArray *lines = [list componentsSeparatedByString:@"\n"];
        NSArray *nodes = [lines CH_map:^id(NSString *obj) {
            return [[obj componentsSeparatedByString:@" -> "] firstObject];
        }];
        NSArray *edges = [lines CH_map:^id(NSString *obj) {
            return [[[obj componentsSeparatedByString:@" -> "] lastObject] componentsSeparatedByString:@","];
        }];

        for (NSString *node in nodes) {
            [self addNodeForLabel:node];
        }

        for (NSInteger i = 0; i<nodes.count; ++i) {
            GraphNode *n1 = [[self nodesForLabel:[nodes objectAtIndex:i]] firstObject];

            for (NSString *e in [edges objectAtIndex:i]) {
                GraphNode *n2 = [[self nodesForLabel:e] firstObject];
                [self addEdge:n1 to:n2];
            }
        }
    }
    return self;
}

- (GraphNode *)addNodeForLabel:(NSString *)label {
    GraphNode *node = [GraphNode new];
    node.label = label;
    [self addNode:node];
    return node;
}

- (GraphNode *)addNode:(GraphNode *)node {
    [self.nodes addObject:node];
    return node;
}

- (GraphEdge *)addEdge:(GraphNode *)from to:(GraphNode *)to {
    GraphEdge *edge = [GraphEdge new];
    edge.from = from;
    edge.to = to;

    NSMutableArray *edgeList = [self.edges objectForKey:@(from.hash)];
    if (!edgeList) {
        edgeList = [NSMutableArray arrayWithCapacity:4];
        [self.edges setObject:edgeList forKey:@(from.hash)];
    }

    [edgeList addObject:edge];

    return edge;
}

- (NSArray *)nodesForLabel:(NSString *)label {
   return [self.nodes CH_filter:^BOOL(GraphNode * obj) {
        return [obj.label isEqualToString:label];
   }];
}

- (NSArray *)edgesFrom:(GraphNode *)from {
    NSMutableArray *edgeList = [self.edges objectForKey:@(from.hash)];
    return [edgeList copy];
}

- (NSArray *)edgesTo:(GraphNode *)to {
    NSMutableArray *res = [NSMutableArray array];
    NSArray *edges = [[self.edges allValues] CH_flatten];
    for (GraphEdge *edge in edges) {
        if (edge.to == to) {
            [res addObject:edge];
        }
    }
    return [res copy];
}

- (NSEnumerator *)nodeEnumerator {
    return [self.nodes objectEnumerator];
}

- (BOOL)node:(GraphNode *)from isAdjacent:(GraphNode *)to {
    NSArray *es = [self edgesFrom:from];
    NSArray *ns = [es CH_map:^id(GraphEdge * obj) {
        return obj.to;
    }];
    return [ns containsObject:to];
}

- (NSString *)description {

    NSMutableString *s = [[super description] mutableCopy];

    NSUInteger ni = 0;
    for (GraphNode *n in self.nodes) {
        [s appendString:@"\n"];

        [s appendString:n.label];

        NSArray *edgeList = [self.edges objectForKey:@(n.hash)];
        if (edgeList.count) {

            [s appendString:@" -> "];
            NSUInteger ei = 0;
            for (GraphEdge *e in edgeList) {
                if (ei != 0) {
                    [s appendString:@","];
                }
                [s appendString:e.to.label];

                ei++;
            }
        }

        ni++;
    }

    return [s copy];
}

- (NSString *)adjacencyDescription {

    NSMutableString *s = [[super description] mutableCopy];

    NSUInteger ni = 0;
    for (GraphNode *n in self.nodes) {


        NSArray *edgeList = [self.edges objectForKey:@(n.hash)];
        if (edgeList.count) {

            [s appendString:@"\n"];

            [s appendString:n.label];

            [s appendString:@" -> "];
            NSUInteger ei = 0;
            for (GraphEdge *e in edgeList) {
                if (ei != 0) {
                    [s appendString:@","];
                }
                [s appendString:e.to.label];

                ei++;
            }
        }
        
        ni++;
    }
    
    return [s copy];

}

- (NSArray *)hamiltonianPaths:(GraphNode *)from {

    NSMutableArray *paths = [NSMutableArray array];
    NSArray *path = [NSArray arrayWithObject:from];
    [self hamiltonianDepth:path paths:paths];

    NSMutableArray *hams = [NSMutableArray array];
    for (NSArray *path in paths) {
        if (path.count == self.nodes.count) {
            for (GraphEdge *e in [self edgesFrom:[path lastObject]]) {
                if (e.to == path.firstObject) {
                    [hams addObject:path];
                }
            }
        }
    }

    return [hams copy];
}

- (NSArray *)hamiltonianDepth:(NSArray *)path paths:(NSMutableArray *)paths {
    GraphNode *start = [path lastObject];
    NSArray *edgeList = [self.edges objectForKey:@(start.hash)];
    BOOL remove = NO;
    for (GraphEdge *e in edgeList) {
        if (![path containsObject:e.to]) {
            NSArray *nupath = [path arrayByAddingObject:e.to];
            [self hamiltonianDepth:nupath paths:paths];
            remove = YES;
            [paths addObject:nupath];
        }
    }
    if (remove) {
        [paths removeObject:path];
    }

    return nil;
}


@end
