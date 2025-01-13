import sys
import argparse
from ete3 import NCBITaxa
from fuzzywuzzy import process

# 初始化 NCBITaxa
ncbi = NCBITaxa()

def generate_tree_from_taxids(taxid_list):
    """
    根据给定的 TaxID 列表生成进化树
    :param taxid_list: list of TaxIDs
    :return: Tree object (ETE3 tree)
    """
    try:
        tree = ncbi.get_topology(taxid_list)
        return tree
    except Exception as e:
        raise ValueError(f"Error generating tree from TaxIDs {taxid_list}: {e}")

def taxid_to_scientific_name(taxid_list):
    """
    将 TaxID 转换为对应的科学名（拉丁学名）
    :param taxid_list: list of TaxIDs
    :return: dict, {TaxID: scientific name}
    """
    try:
        return ncbi.get_taxid_translator(taxid_list)
    except Exception as e:
        raise ValueError(f"Error converting TaxIDs {taxid_list} to scientific names: {e}")

def name_to_taxid(taxon_names):
    """
    将拉丁文名转换为对应的 TaxID 列表，支持拼写错误的模糊匹配
    :param taxon_names: list of scientific names (Latin names)
    :return: list of TaxIDs
    """
    try:
        taxid_dict = ncbi.get_name_translator(taxon_names)
        taxid_list = []

        # 如果没有完全匹配，进行模糊匹配
        for name in taxon_names:
            if name in taxid_dict:
                taxid_list.extend(taxid_dict[name])
            else:
                # 使用 fuzzywuzzy 进行模糊匹配
                match = process.extractOne(name, taxid_dict.keys())
                if match and match[1] > 50:  # 匹配度大于 50%，认为是有效的
                    taxid_list.extend(taxid_dict[match[0]])
                else:
                    print(f"No good match found for '{name}', skipping this name.")
                    continue  # 如果没有有效匹配，则跳过该项

        return taxid_list
    except Exception as e:
        raise ValueError(f"Error converting taxon names {taxon_names} to TaxIDs: {e}")

def replace_taxid_with_names(tree, taxid_to_name_dict):
    """
    替换树中的 TaxID 为对应的科学名
    :param tree: Tree object
    :param taxid_to_name_dict: dict, {TaxID: scientific name}
    """
    # 遍历树中的每一个叶节点，替换 TaxID 为对应的科学名
    for leaf in tree.iter_leaves():
        taxid = int(leaf.name)  # 获取叶节点的 TaxID
        if taxid in taxid_to_name_dict:
            leaf.name = taxid_to_name_dict[taxid]  # 替换为科学名

def save_tree_to_file(tree_output, fmt, file_name):
    """
    保存树的不同格式到文件
    :param tree_output: Tree in Newick format
    :param fmt: Format identifier
    :param file_name: File name to save
    """
    try:
        with open(file_name, "w") as f:
            f.write(tree_output)
        print(f"Saved to file: {file_name}")
    except Exception as e:
        print(f"Error saving tree to file {file_name}: {e}")

def write_all_formats(tree, formats, taxid_tree_file="taxid_tree.nwk", name_tree_file="name_tree.nwk"):
    """
    将树输出为多种格式
    :param tree: Tree object
    :param formats: dict of formats
    :param taxid_tree_file: 文件保存路径（TaxID树）
    :param name_tree_file: 文件保存路径（科学名树）
    """
    print("\nOutputting all Newick formats for TaxID tree:")
    for fmt, description in formats.items():
        try:
            tree_output = tree.write(format=fmt)
            print(f"\nFormat {fmt} ({description}):")
            print(tree_output)

            # 保存到文件
            file_name = f"taxid_tree_format_{fmt}.nwk"
            save_tree_to_file(tree_output, fmt, file_name)

        except Exception as e:
            print(f"Error writing format {fmt}: {e}")

def write_name_formats(tree, taxid_to_name_dict, formats):
    """
    将树输出为基于科学名的多种格式
    :param tree: Tree object
    :param taxid_to_name_dict: dict, {TaxID: scientific name}
    :param formats: dict, Format dictionary
    """
    # 用科学名替换 TaxID
    replace_taxid_with_names(tree, taxid_to_name_dict)

    print("\nOutputting all Newick formats for name-based tree:")
    for fmt, description in formats.items():
        try:
            tree_output = tree.write(format=fmt)
            print(f"\nFormat {fmt} ({description}):")
            print(tree_output)

            # 保存到文件
            file_name = f"name_tree_format_{fmt}.nwk"
            save_tree_to_file(tree_output, fmt, file_name)

        except Exception as e:
            print(f"Error writing format {fmt}: {e}")

def main():
    # 使用 argparse 进行参数解析
    parser = argparse.ArgumentParser(description="Generate and output evolutionary trees from TaxIDs or scientific names.")
    parser.add_argument("taxon_names", metavar="TAXON", type=str, nargs="+", help="List of TaxIDs or scientific names (Latin names)")
    parser.add_argument("--input-type", choices=["taxids", "names"], required=True, help="Specify the input type: 'taxids' or 'names'.")
    args = parser.parse_args()

    taxid_list = []
    taxon_names = args.taxon_names

    # 判断输入类型
    if args.input_type == "taxids":
        # 如果明确输入的是 TaxID 列表，确保它们是整数
        try:
            taxid_list = [int(item) for item in taxon_names]
        except ValueError:
            print("Error: Invalid TaxID value detected.")
            sys.exit(1)
    elif args.input_type == "names":
        # 如果明确输入的是拉丁文名列表
        try:
            taxid_list.extend(name_to_taxid(taxon_names))
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)

    print(f"Input TaxIDs (or converted from names): {taxid_list}")

    # 定义所有格式
    formats = {
        0: "flexible with support values",
        1: "flexible with internal node names",
        2: "all branches + leaf names + internal supports",
        3: "all branches + all names",
        4: "leaf branches + leaf names",
        5: "internal and leaf branches + leaf names",
        6: "internal branches + leaf names",
        7: "leaf branches + all names",
        8: "all names",
        9: "leaf names",
        100: "topology only"
    }

    # 生成进化树
    try:
        tree = generate_tree_from_taxids(taxid_list)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

    # 替换 TaxID 为科学名
    try:
        taxid_to_name_dict = taxid_to_scientific_name(taxid_list)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

    # 输出树格式并保存
    write_all_formats(tree, formats)
    write_name_formats(tree, taxid_to_name_dict, formats)

if __name__ == "__main__":
    main()
