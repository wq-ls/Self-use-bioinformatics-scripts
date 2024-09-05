## sort the tree node
## 0 for decreasing     1 for increasing

tree_deal.py -l 0 raw.tree.nwk > step3.raw.tree.sort.decreasing.nwk
tree_deal.py -l 1 raw.tree.nwk > step3.raw.tree.sort.increasing.nwk
tree_deal.py -s step3.raw.tree.sort.increasing.nwk > step3.increasing.txt
tree_deal.py -s step3.raw.tree.sort.decreasing.nwk > step3.decreasing.txt
