import strutils, os, times, sequtils
import cligen, glob
const help = """


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

iterator tokenize*(str: string): tuple[text, op: string] =
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

proc strRange*(str, a, b: string): string =
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
  ai = parseInt(a)
  bi = parseInt(b)
  return str[ai .. bi]

proc doUpperWord*(str: string): string =
  var prev: char
  var first = true
  for ch in str:
    if prev == ' ' or first:
      result.add ($ch).capitalizeAscii
      first = false
    else:
      result.add $ch
    prev = ch

proc dmmv*(input, renamePattern: string, lower = false, upper = false, 
    upperWord = false, upperFirst = false, replace = "", with = "", idx = 0): string =
  if renamePattern == "": return ""
  let (dir, file, ext) = splitFile(input)
  var modificationTime: Time 
  if fileExists(input):
    modificationTime = getLastModificationTime(input)
  for tok in tokenize(renamePattern):
    result.add tok.text
    case tok.op
    of "N": 
      result.add file
      continue
    of "E": 
      result.add ext
      continue
    of "C":
      result.add $idx
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
  

  # Modificators
  if upper:
    result = result.toUpper
  elif lower:
    result = result.toLower
  elif upperWord:
    result = result.doUpperWord
  elif upperFirst:
    result = result.capitalizeAscii
  else:
    discard

  # Replaces
  if replace != "":
    result = result.multiReplace((replace, with))
  

  result = dir / result

proc cli(filePattern, renamePattern: string, lower = false, upper = false, upperFirst = false, upperWord = false, replace = "", with = "", doit = false) = 
  var idx = 1
  for path in walkGlob(filePattern):
    let oldname = path
    let newname = path.dmmv(
      renamePattern = renamePattern, 
      idx = idx, 
      lower = lower, 
      upper = upper, 
      upperFirst = upperFirst, 
      upperWord = upperWord,
      replace = replace,
      with = with
    )
    echo path, " -> " , newname
    if doit:
      moveFile(oldname, newname)
    idx.inc

when isMainModule:
  dispatch(cli, help = {
    "filePattern": "glob syntax: *.mp3 foo*.mp3",
    "renamePattern": "like: [N]_foo_[E]",
    "lower": "convert all chars to lowercase",
    "upper": "CONVERT ALL CHARS TO UPPERCASE",
    "upperFirst": "Converts the first char to upper",
    "upperWord": "Converts First Char Of Each Word To Upper",
    "doit": "actually rename files",
    "replace": "replaces str value of `with` (done after upper,lower,...)"
    # "with": ""
    } , doc = 
    """
    
  Usage Examples
  ==============
  
    mmv -f *.mp3  -r [N][E]
    mmv -f *.jpeg -r [N].jpg # rename all *.jpegs to *.jpg
    mmv -f *.jpg -r [N]__[YYYY].[MM].[DD]__[E] # adds a timestamp to the file
    mmv -f *.foo.bak -r [N] # removes the .bak
    mmv -f "*/*.jpg" -r [N]_[isot]_[E] # timestamp to all jpg in all subfolders

  Rename Patterns
  ===============

    [N]     file(N)ame
    [n]     (n)umber
    [Nx:y]  name from pos x to pos y 
    [Nx:]   name from pos x to end
    [N:y]   name from start to pos y
    [Nx]    char at position x

    [E]     file ending (like: .png, .jpeg)
    [Ex:y]  file ending (like: .png, .jpeg)
    [Ex:]   file ending (like: .png, .jpeg)
    [C]     incrementing counter 

  Time (modification time, extracted from file)
  =============================================

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

    """)


