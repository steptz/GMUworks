def readlist(infile,Nskip,separator=None):
    import networkx as nx
    G=nx.Graph()
    input=open(infile,'r')
    for n in range(Nskip):
        input.readline()
    if separator==None:
        for line in input:
            line=line.strip()
            line=line.split()
            G.add_edge(line[0],line[1])
    else:
        for line in input:
            line=line.strip()
            line=line.split(separator)
            G.add_edge(line[0],line[1])
    input.close()
    return G
