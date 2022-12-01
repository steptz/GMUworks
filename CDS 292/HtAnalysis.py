'''
HtAnalysis Module
CDS 292
Fall, 2020

This module was created to make all the functions in
lesson 8 Part I more accessible. 
'''

import networkx as nx

def ImportH(Infile,sep):
    H={}
    f=open(Infile,'r')
    for line in f:
        SplitLine=line.split(sep)
        t=int(SplitLine[0])
        Ht=int(SplitLine[1].strip())
        H[t]=Ht
    return H

def CreateHt(G):
    H = {}
    t = nx.triangles(G)
    for nt in t.values():
        H[nt] = H.get(nt, 0) + 1
    return H

def CountTriangles(G,i):
    t=0
    k=G.degree(i)
    Gammai = list(G.neighbors(i))
    for c1 in range(k - 1):
        for c2 in range(k):
            h=Gammai[c1]
            q=Gammai[c2]
            if G.has_edge(h,q):
                t=t+1
    return t

def local_triangle_count(G, source):
    triangles = {}
    if source == 'nodes':
        for node in G.nodes():
            triangles[node] = 0
            neigh = list(G.neighbors(node))
            nn = len(neigh)
            for h in range(nn - 1):
                for q in range(h + 1, nn):
                    if G.has_edge(neigh[h], neigh[q]):
                        triangles[node] += + 1

    elif source == 'matrix':
        A = nx.adjacency_matrix(G)
        A3 = A**3
        A3 = A3.toarray()
        nodeset = list(G.nodes())
        for i in range(len(nodeset)):
            triangles[nodeset[i]] = A3[i][i] // 2
    
    return triangles

def tavg(H):
    numerator=0
    denominator=0
    for t in H.keys():
        numerator += (t*H[t])
        denominator += H[t]
    return numerator/denominator

def get_n(H):
    return sum(H.values())

def tmax(H):
    return max(H.keys())

def tmin(H):
    return min(H.keys())

def tstar(H):
    result = []
    MaxHt = 0
    for t in H.keys():
        if H[t] > MaxHt:
            result = [t]
            MaxHt = H[t]
        elif H[t] == MaxHt:
            result.append(t)
    if len(result) > 1:
        return result
    elif len(result) == 1:
        return result[0]
