A multi rename tool for the command line, 
like the one in TotalCommander or DoubleCommander (ctrl+m)

```
Usage:
  cli [required&optional-params] 
    
  Usage Examples
  ==============
  
    mmv -f *.mp3  -r [N][E]
    mmv -f *.jpeg -r [N].jpg # rename all *.jpegs to *.jpg
    mmv -f *.jpg -r [N]__[YYYY].[MM].[DD]__[E] # adds a timestamp to the file
    mmv -f *.foo.bak -r [N] # removes the .bak
    mmv -f "*/*.jpg" -r [N]_[isot]_[E] # timestamp to all jpg in all subfolders
    mmv -f "*" -r "[N][E]" --upperWord --replace=" " --with="_"
    
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

    
Options(opt-arg sep :|=|spc):
  -h, --help                               print this cligen-erated help
  --help-syntax                            advanced: prepend,plurals,..
  -f=, --filePattern=    string  REQUIRED  glob syntax: *.mp3 foo*.mp3
  -r=, --renamePattern=  string  REQUIRED  like: [N]_foo_[E]
  -l, --lower            bool    false     convert all chars to lowercase
  -u, --upper            bool    false     CONVERT ALL CHARS TO UPPERCASE
  --upperFirst           bool    false     Converts the first char to upper
  --upperWord            bool    false     Converts First Char Of Each Word To Upper
  --replace=             string  ""        replaces str value of `with` (done after upper,lower,...)
  -w=, --with=           string  ""        set with
  -d, --doit             bool    false     actually rename files
```