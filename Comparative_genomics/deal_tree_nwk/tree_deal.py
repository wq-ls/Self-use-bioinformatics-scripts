#!/micromamba/envs/pixy/bin/python
"""TM - newick tree operation tool, including reroot, ladderize, cladogram, rename, prune, show

usage: {f} [-r [-o og1,og2]] [-l <0/1>] [-c] [-s] [-t] [--rename <file> [--rc 1,2]] [--prune <file> [--pc 1]] tree

note: by default, this tool will output the operated tree in newick format to stdout

OPTIONS:
    tree    <FILE>      newick format tree FILE or string, '-' will be regards as the standard input (stdin)

    --inf   <INT>       format for input newick standard, can be int between 0-9
    -r, --reroot        reroot tree
    -o, --outgroup
            <STR>       outgroup labels split by comma; will reroot by midpoint if not specific
    -l, --ladderize
            <0/1>       sort the tree node like figtree, default not sort
                            0 for decreasing
                            1 for increasing
    -c, --cladogram     transform braches like figtree by cladogram method
    -s, --show          print the tree shape on terminal
    -t, --tip           get all tips of terminal leaves
    --rename
            <FILE>      FILE list the name map to change, TAB delimitor
                            tip\tlatin name
    --rc    <STR>       columns used in '--rename' file, default 1,2
    --prune
            <FILE>      FILE list the name of leaves to prune
    --pc    <INT>       column used in '--prune' file, default 1
    --ouf   <INT>       format for output newick standard, can be int between 0-9
    
    http://etetoolkit.org/docs/latest/tutorial/tutorial_trees.html#basic-tree-attributes
"""

import sys
import getopt
sys.path.append('/micromamba/envs/pixy/lib/python3.8/site-packages/')
from ete3 import Tree

class Options(object):
    s = 'ho:l:crst'
    l = ['help', 'outgroup=', 'ladderize=', 'cladogram', 'reroot', 'show', 'tip', 'rename=', 
            'rc=', 'prune=', 'inf=', 'ouf=']
    def __init__(self, argv):
        self.__file__ = argv[0]
        self.cmdline = argv[1:]
        self.tree = None
        self.in_format = 0
        self.outgroup = None
        self.ladderize = False
        self.cladogram = False
        self.reroot = False
        self.show = False
        self.getTip = False
        self.rename = None
        self.rename_columns = [0, 1]
        self.prune = False
        self.prune_column = 0
        self.out_format = 0
        try:
            self.options, self.not_options = getopt.gnu_getopt(self.cmdline, 
                    Options.s, Options.l)
        except getopt.GetoptError as err:
            sys.stderr.write('*** Error: {}\n'.format(err))
            sys.exit()
        if self.not_options and len(self.not_options) == 1:
            self.tree = self.not_options[0]
            if self.tree == '-':
                self.tree = sys.stdin.read()
        if self.options:
            for opt, arg in self.options:
                if opt in ['-h', '--help']:
                    sys.stdout.write(self.usage)
                    sys.exit()
                elif opt in ['--inf']:
                    self.in_format = int(arg)
                elif opt in ['-r', '--reroot']:
                    self.reroot = True
                elif opt in ['-o', '--outgroup']:
                    self.outgroup = arg.split(',')
                elif opt in ['-l', '--ladderize']:
                    self.ladderize = True
                    if arg in ['0', '1']:
                        self.ordering = int(arg)
                elif opt in ['-c', '--cladogram']:
                    self.cladogram = True
                elif opt in ['-s', '--show']:
                    self.show = True
                elif opt in ['-t', '--tip']:
                    self.getTip = True
                elif opt in ['--rename']:
                    self.rename = arg
                elif opt in ['--rc']:
                    self.rename_columns = [int(x) - 1 for x in arg.split(',')]
                elif opt in ['--prune']:
                    self.prune = arg
                elif opt in ['--pc']:
                    self.prune_column = int(arg) - 1
                elif opt in ['--ouf']:
                    self.out_format = int(arg)
        if not self.tree:
            sys.stdout.write(self.usage)
            sys.exit()
    @property
    def usage(self):
        return __doc__.format(f=self.__file__)

class RENAME(dict):
    def __init__(self, anno_file, pre=0, pro=1):
        r = open(anno_file)
        for line in r:
            lst = line.strip('\n').split('\t')
            self[lst[pre]] = lst[pro]
        r.close()

class NAMELIST(list):
    def __init__(self, namefile, ncol=0):
        r = open(namefile)
        for line in r:
            self.append(line.strip('\n').split('\t')[ncol])
        r.close()

if __name__ == '__main__':
    opts = Options(sys.argv)
    
    tree = Tree(opts.tree, format=opts.in_format)

    if opts.reroot:
        if opts.outgroup:
            if len(opts.outgroup) == 1:
                R = tree&opts.outgroup[0]
            else:
                R = tree.get_common_ancestor(opts.outgroup)
        else:
            R = tree.get_midpoint_outgroup()
    
        if R != tree:
            tree.set_outgroup(R)

    if opts.cladogram:
        tree.convert_to_ultrametric(strategy='cladogram')
    if opts.ladderize:
        tree.ladderize(opts.ordering)

    if opts.rename:
        pre, pro = opts.rename_columns
        name_maps = RENAME(opts.rename, pre=pre, pro=pro)
        for node in tree.get_leaves():
            node.name = name_maps[node.name]

    if opts.prune:
        names = NAMELIST(opts.prune, ncol=opts.prune_column)
        tree.prune(names)

    if opts.getTip:
        labels = tree.get_leaf_names()
        sys.stdout.write('\n'.join(labels) + '\n')
        sys.exit()

    if opts.show:
        sys.stdout.write(tree.__str__() + '\n')
    else:
        newick = tree.write(format=opts.out_format)
        sys.stdout.write(newick)

