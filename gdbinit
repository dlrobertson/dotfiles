set print symbol-filename on
set print sevenbit-strings on
set print asm-demangle on
set auto-load safe-path /home/drobertson/git
alias -a di = disass
set step-mode off
set breakpoint pending on
set disassembly-flavor att
set confirm off
set verbose off
set pagination off
set output-radix 0x10
set print pretty on
handle SIGALRM print nopass
handle SIGTRAP print nopass
set confirm off
tui new-layout mine {-horizontal src 1 asm 1} 1 cmd 1
layout mine
focus cmd
set tui compact-source on

define start_gef
  source ~/git/gef/gef.py
  set disassembly-flavor att
  set step-mode off
end

define kasan_addr_to_shadow
  print/x ((unsigned long)$arg0 >> 3) + 0xdffffc0000000000
end
