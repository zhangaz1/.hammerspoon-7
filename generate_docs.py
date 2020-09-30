#!/usr/bin/env python3

import glob
import os
import re

parent_dir = os.path.abspath(os.path.dirname(__file__))
docfile = os.path.join(parent_dir, "README.md")

docs = []
files = sorted(glob.glob(os.path.join(parent_dir, "Spoons/*.spoon/init.lua")))
for file in files:
    with open(file, 'r') as file_object:
        contents = file_object.read()
        comments = re.findall(
            r"^---.+?^[^-]", contents, flags=re.MULTILINE | re.DOTALL)
        spoon_name = os.path.basename(os.path.dirname(file))
        docs.append(f"\n### {spoon_name}\n")
        if len(comments) == 0:
            continue

                # if re.match(r"\.app", spoon_desc):
        for (idx, block) in enumerate(comments):
            block = block.replace("--- ", "")
            block = block.replace(" * ", "- ")
            block = block.split('\n')
            if idx == 0:
                spoon_desc = block[1]
                docs.append(spoon_desc)
                continue
            signature = f"\n#### {block[0]}\n"
            objtype = f"_{block[1]}_\n"
            docs.append(signature)
            docs.append(objtype)
            # discussion
            for sentence in block[2:]:
                if len(sentence) == 1:
                    # regex parsing artifacts
                    continue
                if sentence.startswith("Parameter") or sentence.startswith("Return"):
                    sentence = f"\n**{sentence}**\n"
                docs.append(sentence)
        if len(comments) == 1:
            docs.append("**Documentation underway**")
            # docs.append(DISCUSSION)



with open(docfile, "r") as file_object:
    txt = file_object.read()

txt = re.sub(r"(?<=API\n).+(?=## To Do)", "\n".join(docs) + "\n", txt, flags=re.DOTALL)

with open(docfile, "w") as file_object:
    file_object.write(txt)
