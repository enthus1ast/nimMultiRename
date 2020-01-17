import strutils, os, times
const help = """

Usage
======

mmv *.mp3 [n][N][E]


File name
==========

[N]     file(N)ame
[n]     (n)umber
[Nx:y]  name from pos x to pos y
[Nx:]  name from pos x to end
[Nx]    char at position x

[E]     file ending (like: .png, .jpeg)
[C]     count


Time (extracted from the renamed file)
===========================

[iso]
[YY]     year 2 chars (like: 18, 19, 20)
[YYYY]   year 4 chars (like: 2018, 2019, 2020)
[M]      month in digest (like 9, 10, 11)
[MM]     month in digest (like 09, 10, 11)
[MMM]    month, short form (like: Jan, Sep, Oct)
[MMMM]   month, long form (like: January, September, October)
[D]      day of the month, (like: 9, 10, 11)
[DD]     day of the month, (like: 09, 10, 11)
[DDD]    day name, (like: Fr, Sa, So)
[DDDD]   day name, (like: Friday, Saturday, Sunday)
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


proc dmmv(input, pattern: string, idx = 0): string =
  if pattern == "": return ""
  let (dir, file, ext) = splitFile(input)

  var creationTime: Time 
  if fileExists(input):
    creationTime = getCreationTime(input)
  for tok in tokenize(pattern):
    echo tok
    result.add tok.text
    case tok.op
    of "N": result.add file
    of "E": result.add ext



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
      # check tokenize("[foo]") == @[("", "[foo]")]
      # check tokenize("[foo]") == @[("", "[foo]")]
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


# [n][e]

