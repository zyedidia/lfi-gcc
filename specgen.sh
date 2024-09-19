#!/bin/sh

# usage: ./specgen.sh GCC_PATH

DUMPSPEC=$($1 -dumpspecs)

if [ "$ARCH" = "x86_64" ]
then
    LFIARCH=amd64
elif [ "$ARCH" = "aarch64_lfi" ] || [ "$ARCH" = "aarch64" ]
then
    LFIARCH=arm64
elif [ "$ARCH" = "riscv64" ]
then
    LFIARCH=riscv64
    RVSPEC="%{!march:-march=rv64g_zba}"
fi

cat << EOM
$DUMPSPEC

@assembler:
%{!M:%{!MM:%{!E:%{!S:lfi-leg $LFIFLAGS -a $LFIARCH %i | as %(asm_debug) %(asm_options) %A }}}}

@assembler-with-cpp:
%(trad_capable_cpp) -lang-asm %(cpp_options) -fno-directives-only %{E|M|MM:%(cpp_debug_options)} %{!M:%{!MM:%{!E:%{!S:-o %|.s |
   lfi-leg $LFIFLAGS -a $LFIARCH %m.s | as %(asm_debug) %(asm_options) %A }}}}

*invoke_as:
%{!fwpa*:   %{fcompare-debug=*|fdump-final-insns=*:%:compare-debug-dump-opt()}   %{!S:-o %|.s |
 lfi-leg $LFIFLAGS -a $LFIARCH %m.s | as %(asm_options) %A }  }

*cpp:
+ -D__LFI__

*cc1:
+ $(lfi-leg -a $LFIARCH --flags=gcc $LFIFLAGS) -fPIC $CC1FLAGS

*link:
%{!static|static-pie:--eh-frame-hdr} %{!mandroid|tno-android-ld:%{shared:-shared}   %{!shared:     %{!static:       %{!static-pie: 	%{rdynamic:-export-dynamic} -dynamic-linker %:getenv(GCC_EXEC_PREFIX ../../$ARCH-lfi-linux-musl/lib/ld-musl-$ARCH.so.1)}}     %{static:-static} %{static-pie:-static -pie --no-dynamic-linker -z text}};:%{shared:-shared} %{!shared: %{!static: %{!static-pie:	%{rdynamic:-export-dynamic}	-dynamic-linker %:getenv(GCC_EXEC_PREFIX ../../$ARCH-lfi-linux-musl/lib/ld-musl-$ARCH.so.1}}     %{static:-static} %{static-pie:-static -pie --no-dynamic-linker -z text}} %{shared: -Bsymbolic}} -z separate-code -z now

*self_spec:
$RVSPEC

*post_link:
lfi-postlink %{o*:%*;:a.out} -a $LFIARCH $(lfi-leg -a $LFIARCH --flags=postlink $LFIFLAGS)
EOM

