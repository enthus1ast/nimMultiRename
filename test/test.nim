import  ../src/mmv
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
    test "doUpperWord":
      check doUpperWord("foo baa baz") == "Foo Baa Baz"
      check doUpperWord("foo  baa  baz") == "Foo  Baa  Baz"
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
    test "upper":
      check dmmv("foa.ext", "[E:1]", upper = true) == ".E"
    test "lower":
      check dmmv("FOA.EXT", "[N][E]", lower = true) == "foa.ext"      
    test "upperFirst":
      check dmmv("foa.ext", "[N][E]", upperFirst = true) == "Foa.ext"
    test "upperWord":
      check dmmv("foo baa baz", "[N]", upperWord = true) == "Foo Baa Baz"
    test "replaceWith":
      check dmmv(
        "foo baa baz", 
        "[N]", 
        upperWord = true, 
        replace = " ", 
        with = "_") == "Foo_Baa_Baz"
    #   check dmmv("foa.ext", "[N-0][E]") == "a.ext"
    #   check dmmv("foa.ext", "[N-1][N1[E]") == "oo.ext"
