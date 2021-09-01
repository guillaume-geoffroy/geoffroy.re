import marko
import configparser
import langdetect

import argparse
import sys
import os
import shutil
import tempfile

languages=["en", "fr"]
longLanguages={"fr": "french", "en": "UKenglish"}

#parser = argparse.ArgumentParser(description='Generate CV.')
#parser.add_argument('source', metavar='source',
#                    help='path to the source repo')

#args = parser.parse_args()
#source = args.source


oldCwd = os.getcwd()
while not os.path.isfile(os.getcwd()+"/cvdata.ini"):
  cwd = os.getcwd()
  os.chdir("..")
  if os.getcwd() == cwd:
    print("File cvdata.ini not found", file=sys.stderr)
    sys.exit(1)
source = os.getcwd()
os.chdir(oldCwd)

config = configparser.ConfigParser()
config.read(source+"/cvdata.ini")

from marko.ast_renderer import ASTRenderer

def processSection(ast, lang=None):
  yield "\\section*{"+ast["children"][0]["children"]+"}"

def processSubsection(ast, lang=None):
  yield "\\subsection*{"+ast["children"][0]["children"]+"}"

def flattenInlineHtml(html, lang=None):
  if html == "<BR>":
    return "\\newline"
  else:
    return html

def plainTextParagraph(ast):
  if isinstance(ast, list):
    return " ".join([plainTextParagraph(child) for child in ast])
  elif isinstance(ast, dict) and "element" in ast:
    if ast["element"] == "raw_text":
      return ast["children"]
    elif ast["element"] == "paragraph":
      return plainTextParagraph(ast["children"])
    elif ast["element"] == "strong_emphasis":
      return plainTextParagraph(ast["children"])
    elif ast["element"] == "emphasis":
      return plainTextParagraph(ast["children"])
    elif ast["element"] == "link" or ast["element"] == "auto_link":
      return ""
    elif ast["element"] == "inline_html":
      return ""
  return ""
  
def paragraphLang(ast):
  return langdetect.detect(plainTextParagraph(ast))

def fixLang(plainText, tex, lang=None):
  if lang is None or lang not in languages:
    return tex
  detectedLang = langdetect.detect(plainText)
  if detectedLang == lang or detectedLang not in languages:
    return tex
  else:
    #print(detectedLang+":", tex, file=sys.stderr)
    return "\\foreignlanguage{"+longLanguages[detectedLang]+"}{"+tex+"}"
  
def flattenParagraph(ast, lang=None):
  if isinstance(ast, list):
    return "".join([flattenParagraph(child, lang=lang) for child in ast])
  elif isinstance(ast, dict) and "element" in ast:
    if ast["element"] == "raw_text":
      return ast["children"]
    elif ast["element"] == "paragraph":
      return flattenParagraph(ast["children"], lang=lang)
    elif ast["element"] == "strong_emphasis":
      plainText = plainTextParagraph(ast)
      tex = "\\textbf{"+flattenParagraph(ast["children"], lang=lang)+"}"
      return fixLang(plainText, tex, lang)
    elif ast["element"] == "emphasis":
      plainText = plainTextParagraph(ast)
      tex = "\\textit{"+flattenParagraph(ast["children"], lang=lang)+"}"
      return fixLang(plainText, tex, lang)
    elif ast["element"] == "link" or ast["element"] == "auto_link":
      return "\\href{" + ast["dest"] + "}{\linkstyle{" + flattenParagraph(ast["children"], lang=lang) + "}}"
    elif ast["element"] == "inline_html":
      return flattenInlineHtml(ast["children"], lang=lang)
  return ""

def splitParagraph(tex):
  split = tex.split("::", 1)
  if len(split) > 1:
    return (split[0].strip(), split[1].strip())
  else:
    return ("", split[0].strip())

def convertChars(tex):
  tex = tex.replace("π", "$\\pi$")
  tex = tex.replace("&", "\\&")
  return tex
  
def processParagraph(ast, lang=None):
  (date, text) = splitParagraph(flattenParagraph(ast, lang=lang))
  yield convertChars("\\cvline{"+date+"}{"+text+"}")

def processAst(ast, lang=None):
  bodyStarted=False  
  for child in ast["children"]:
    if ("element" in child
        and child["element"] == "setext_heading"
        and "level" in child
        and child["level"] == 1):
      bodyStarted=True
      yield from processSection(child)
    if ("element" in child
        and child["element"] == "heading"
        and "level" in child
        and child["level"] == 3):
      yield from processSubsection(child)
    if ("element" in child
        and child["element"] == "paragraph"
        and bodyStarted):
      yield from processParagraph(child, lang=lang)

dataSection = {"en": "Personal data", "fr": "État civil"}
      
oldCwd = os.getcwd()
with tempfile.TemporaryDirectory() as tmpDirName:
  shutil.copy2(source+"/lib/leafcv/leafcv.cls", tmpDirName)
  os.chdir(tmpDirName)
  for lang in languages:
    filebasename = "cv-"+("-".join(word.lower() for word in config["common"]["author"].split(" ")))+"-"+lang
    texfilename = filebasename + ".tex"
    pdffilename = filebasename + ".pdf"
    with open(source+"/"+lang+"/cv.md", "r") as mdfile:
      # TODO: remove jekyll header
      ast = marko.Markdown(renderer=ASTRenderer)(mdfile.read())
    with open(texfilename, "w") as texfile:
      texfile.write("\\documentclass["+lang+"]{leafcv}\n")
      texfile.write("\\usepackage[utf8]{inputenc}\n")
      texfile.write("\\author{"+config["common"]["author"]+"}\n")
      texfile.write("\\email{"+config["common"]["email"]+"}\n")
      texfile.write("\\website{"+config["common"]["website"]+"}\n")
      texfile.write("\\jobtitle{"+config[lang]["jobtitle"]+"}\n")
      texfile.write("\\address{"+config[lang]["address"]+"}\n")
      texfile.write("\\date{\\today}\n")
      texfile.write("\\begin{document}\n")
      texfile.write("\\maketitle\n")

      texfile.write("\\section*{"+dataSection[lang]+"}\n")
      texfile.write("\\cvline{}{"+config[lang]["personaldata"]+"}\n")

      for text in processAst(ast, lang=lang):
        texfile.write(text)
        texfile.write("\n")

      texfile.write("\\end{document}\n")
      
    #shutil.copy2(texfilename, oldCwd)
    os.system("pdflatex "+texfilename)
    os.system("pdflatex "+texfilename)
    shutil.copy2(pdffilename, source+"/docs")

  os.chdir(oldCwd)

