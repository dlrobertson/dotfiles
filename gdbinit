set print symbol-filename on
set print sevenbit-strings on
set print asm-demangle on
set auto-load safe-path /home/drobertson/git
alias -a di = disass
source ~/git/gef/gef.py
set breakpoint pending on
set confirm off

define kasan_addr_to_shadow
  print/x ((unsigned long)$arg0 >> 3) + 0xdffffc0000000000
end
