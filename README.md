A multi rename tool for the command line, 
like the one in TotalCommander or DoubleCommander (strg+m)

Usage
======

```
$ ./mmv -h
Usage:
  cli [required&optional-params] 
Options(opt-arg sep :|=|spc):
  -h, --help                               print this cligen-erated help
  --help-syntax                            advanced: prepend,plurals,..
  -f=, --filePattern=    string  REQUIRED  glob syntax: *.mp3 foo*.mp3
  -r=, --renamePattern=  string  REQUIRED  like: [N]_foo_[E]
  -u, --usage            bool    false     print usage
  -d, --doit             bool    false     actually rename files

$ mmv -f *.mp3 -r [N][E] -d
$ mmv -f *.mp3 -r [N]_[isot]_[E] -d

```

File name
==========

```
[N]     file(N)ame
# [n]     (n)umber
[Nx:y]  name from pos x to pos y 
[Nx:]   name from pos x to end
[N:y]   name from start to pos y
[Nx]    char at position x

[E]     file ending (like: .png, .jpeg)
[Ex:y]  file ending (like: .png, .jpeg)
[Ex:]   file ending (like: .png, .jpeg)
# [Cx]  count
```

Time (modification time, extracted from file)
===========================

```
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
```