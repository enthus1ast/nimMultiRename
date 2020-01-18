import strutils, os, times
import cligen, glob
const help = """

Usage
======

mmv *.mp3 [N][E]


File name
==========

[N]     file(N)ame
[n]     (n)umber
[Nx:y]  name from pos x to pos y 
[Nx:]  name from pos x to end
[N:y]  name from start to pos y
[Nx]    char at position x

[E]     file ending (like: .png, .jpeg)
[Ex:y]     file ending (like: .png, .jpeg)
[Ex:]     file ending (like: .png, .jpeg)
# [Cx]     count


Time (modification time, extracted from file)
===========================

[iso]    yyyy-MM-dd HH:mm:ss
[isot]   yyyy-MM-dd'T'HH:mm:ss
[YY]     year 2 chars (like: 18, 19, 20)
[YYYY]   year 4 chars (like: 2018, 2019, 2020)
[M]      month in digest (like 9, 10, 11)
[MM]     month in digest (like 09, 10, 11)
[MMM]    month, short form (like: Jan, Sep, Oct)
[MMMM]   month, long form (like: January, September, October)
[D]      day of the month, (like: 9, 10, 11)
[DD]     day of the month, (like: 09, 10, 11)
[DDD]    day of the week name, (like: Fr, Sa, So)
[DDDD]   day of the week name, (like: Friday, Saturday, Sunday)
[h]      hour, (like: 9, 10, 11)
[hh]     hour, (like: 09, 10, 11)
[m]      minute, (like: 9, 10, 11)
[mm]     minute, (like: 09, 10, 11)
[s]      second, (like: 9, 10, 11)
[ss]     second, (like: 09, 10, 11)
"""

template yop() =
  if op.len != 0:
    yield (text, op)
  text.setLen 0
  op.setLen 0
  continue

template ytxt() =
  if text.len != 0:
    yield (text, op)
  text.setLen 0
  op.setLen 0
  continue

iterator tokenize(str: string): tuple[text, op: string] =
  var text = ""
  var op = ""
  var cur: char
  var inop: bool
  var skipnext: bool
  for idx, ch in str:
    # echo idx, ch
    if skipnext: 
      skipnext = false
      text.add ch
      continue
    if ch == '\\':
      skipnext = true
      continue
    if ch == '[':
      inop = true
      ytxt
    if ch == ']':
      inop = false
      yop
      
    if inop:
      op.add ch
    else:
      text.add ch

  if text.len != 0 or op.len != 0:
    yield (text, op)

proc strRange(str, a, b: string): string =
  var ai: int
  var bi: int

  ## Nx:
  if a == "":
    bi = parseInt(b)
    return str[0..bi]
  
  ## N:y
  if b == "":
    ai = parseInt(a)
    return str[ai..^1]

  ## Nx:y
  # try:
  ai = parseInt(a)
  bi = parseInt(b)
  # except:
    # return str
  return str[ai .. bi]

proc dmmv(input, pattern: string, idx = 0): string =
  if pattern == "": return ""
  let (dir, file, ext) = splitFile(input)

  var modificationTime: Time 
  if fileExists(input):
    modificationTime = getLastModificationTime(input)
  for tok in tokenize(pattern):
    # echo tok
    result.add tok.text
    case tok.op
    of "N": 
      result.add file
      continue
    of "E": 
      result.add ext
      continue
    of "isot":
      result.add modificationTime.format("yyyy-MM-dd'T'HH:mm:ss")
    of "iso":
      result.add modificationTime.format("yyyy-MM-dd HH:mm:ss")
    of "YY":
      result.add modificationTime.format("yy")
    of "YYYY":
      result.add modificationTime.format("yyyy")
    of "M":
      result.add modificationTime.format("M")
    of "MM":
      result.add modificationTime.format("MM")
    of "MMM":
      result.add modificationTime.format("MMM")
    of "MMMM":
      result.add modificationTime.format("MMMM")
    of "D":
      result.add modificationTime.format("d")
    of "DD":
     result.add modificationTime.format("dd")
    of "DDD":
      result.add modificationTime.format("ddd")
    of "DDDD":
     result.add modificationTime.format("dddd")
    of "h":
      result.add modificationTime.format("H")
    of "hh":
     result.add modificationTime.format("HH")
    of "m":
      result.add modificationTime.format("m")
    of "mm":
     result.add modificationTime.format("mm")
    of "s":
      result.add modificationTime.format("s")
    of "ss":
     result.add modificationTime.format("ss")

    # one char range
    var toadd: string 
    if tok.op.startsWith("N"):
      toadd = file
    elif tok.op.startsWith("E"):
      toadd = ext
    
    if tok.op.len > 0:
      # range x:y
      var rngStr = tok.op[1..^1]
      if rngStr.contains(":"):
        var rng = rngStr.split(":")
        result.add toadd.strRange(rng[0], rng[1])
      else:
        # one char
        try:
          var idx = parseInt(rngStr)
          result.add toadd[idx]
        except:
          result.add toadd

proc cli(filePattern, renamePattern: string, usage = false, doit = false) = 
  if usage:
    echo help
    quit()
  for path in walkGlob(filePattern):
    # every file in `src` or its subdirectories, lazily
    let oldname = path
    let newname = path.dmmv(renamePattern)
    echo path, " -> " , newname
    if doit:
      moveFile(oldname, newname)

if paramCount() > 0:
  dispatch(cli, help = {
    "filePattern": "glob syntax: *.mp3 foo*.mp3",
    "renamePattern": "like: [N]_foo_[E]",
    "usage": "print usage",
    "doit": "actually rename files",
  })

when isMainModule:
  import unittest, sequtils
  suite "tokenize":
    test "empty":
      check toSeq(tokenize("")).len == 0
    test "op":
      check toSeq(tokenize("[op]")) == @[("", "op")]
    test "txt[op]":
      check toSeq(tokenize("txt[op]")) == @[("txt",""), ("", "op")]
    test "[op1][op2]":
      check toSeq(tokenize("[op1][op2]")) == @[("","op1"), ("", "op2")]
      check toSeq(tokenize("[op1] [op2]")) == @[("","op1"), (" ",""), ("", "op2")]
    test "escaped":
      check toSeq(tokenize("\\[foo\\]")) == @[("[foo]", "")]
      check toSeq(tokenize("""\\""")) == @[("""\""", "")]
  suite "mmv":
    test "empty":
      check dmmv("foo.ext", "") == ""
    test "no pattern":
      check dmmv("foo.ext", "baa") == "baa"
    test "simple":
      check dmmv("foo.ext", "[N][E]") == "foo.ext"
      check dmmv("foo.ext", "FOO[N][E]") == "FOOfoo.ext"
      check dmmv("foo.ext", "FOO_[N][E]") == "FOO_foo.ext"
      check dmmv("foo.ext", "[N]") == "foo"
      check dmmv("foo.ext", "[E][E]") == ".ext.ext"
      check dmmv("foo.ext", "[E]_[E]") == ".ext_.ext"
    test "one char impl (empty)":
      check strRange("foa", "1", "") == "oa"
      check strRange("foa", "", "1") == "fo"
    test "one char impl (range)":
      check strRange("foa", "0", "2") == "foa"
      check strRange("foa", "0", "1") == "fo"
      check strRange("foa", "0", "0") == "f"

    test "one char N":
      check dmmv("foa.ext", "[N0][E]") == "f.ext"
    test "one char E":
      check dmmv("foa.ext", "[N][E0]") == "foa."
    test "ranges":
      check dmmv("foa.ext", "[E0:1]") == ".e"
      check dmmv("foa.ext", "[N0:2][E]") == "foa.ext"
      check dmmv("foa.ext", "[E1:]") == "ext"
      check dmmv("foa.ext", "[E:1]") == ".e"

    #   check dmmv("foa.ext", "[N-0][E]") == "a.ext"
    #   check dmmv("foa.ext", "[N-1][N1[E]") == "oo.ext"
