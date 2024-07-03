#!/bin/sh

if [ "$ARCH" = "x86_64" ]
then
    LFIARCH=amd64
elif [ "$ARCH" = "aarch64_lfi" ] || [ "$ARCH" = "aarch64" ]
then
    LFIARCH=arm64
fi

cat << EOM
@assembler:
%{!M:%{!MM:%{!E:%{!S:lfi-leg $LFIFLAGS -a $LFIARCH %i | as %(asm_debug) %(asm_options) %A }}}}

*invoke_as:
%{!fwpa*:   %{fcompare-debug=*|fdump-final-insns=*:%:compare-debug-dump-opt()}   %{!S:-o %|.s |
 lfi-leg $LFIFLAGS -a $LFIARCH %m.s | as %(asm_options) %A }  }

*cc1:
+ $(lfi-leg -a $LFIARCH --flags=gcc $LFIFLAGS)
EOM
