## sort the tree node
## 0 for decreasing     1 for increasing

/dellfsqd2/ST_OCEAN/USER/lishuo1/00_tools/tree_deal.py -l 0 raw.tree.nwk > step3.raw.tree.sort.decreasing.nwk
/dellfsqd2/ST_OCEAN/USER/lishuo1/00_tools/tree_deal.py -l 1 raw.tree.nwk > step3.raw.tree.sort.increasing.nwk
/dellfsqd2/ST_OCEAN/USER/lishuo1/00_tools/tree_deal.py -s step3.raw.tree.sort.increasing.nwk > step3.increasing.txt
/dellfsqd2/ST_OCEAN/USER/lishuo1/00_tools/tree_deal.py -s step3.raw.tree.sort.decreasing.nwk > step3.decreasing.txt
