package main

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"text/template"
)

var specs = `@assembler:
%{!M:%{!MM:%{!E:%{!S:lfi-leg {{ .LfiFlags }} -a {{ .Arch }} %i | as %(asm_debug) %(asm_options) %A }}}}

*invoke_as:
%{!fwpa*:   %{fcompare-debug=*|fdump-final-insns=*:%:compare-debug-dump-opt()}   %{!S:-o %|.s |
 lfi-leg {{ .LfiFlags }} -a {{ .Arch }} %m.s | as %(asm_options) %A }  }

*cc1:
+ {{ .CompilerFlags }}
`

type Args struct {
	Arch          string
	LfiFlags      string
	CompilerFlags string
}

func compilerFlags(lfiflags, arch string) string {
	buf := &bytes.Buffer{}
	cmd := exec.Command("sh", "-c", fmt.Sprintf("lfi-leg -a %s --flags=gcc %s", arch, lfiflags))
	cmd.Env = os.Environ()
	cmd.Stdout = buf
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		log.Fatal(err)
	}
	return strings.TrimSpace(buf.String())
}

var toLegArch = map[string]string{
	"x86_64":      "amd64",
	"aarch64_lfi": "arm64",
	"aarch64":     "arm64",
}

func main() {
	lfiarch := os.Getenv("ARCH")
	var arch string
	if _, ok := toLegArch[lfiarch]; ok {
		arch = toLegArch[lfiarch]
	} else {
		arch = runtime.GOARCH
	}
	lfiflags := os.Getenv("LFIFLAGS")

	t, err := template.New("lfi").Parse(specs)
	if err != nil {
		log.Fatal(err)
	}

	err = t.Execute(os.Stdout, Args{
		Arch:          arch,
		CompilerFlags: compilerFlags(lfiflags, arch),
		LfiFlags:      lfiflags,
	})
	if err != nil {
		log.Fatal(err)
	}
}
