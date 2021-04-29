# goissue45702

This is a minimized reproducer for https://github.com/golang/go/issues/45702.

To reproduce the error, run:
```
PKG_CONFIG=$PWD/pkg-config.sh GO=/your/path/to/gotip /your/path/to/gotip run .
```

You probably need rust installed to run this.

To be completely honest, I don't have a good understanding of our pkg-config wrapper,
nor exactly how libflux is supposed to interact with it.
But this bug seems very likely related to our use of pkg-config,
because with our current `import _ "github.com/influxdata/flux/libflux/go/libflux"` call in main.go,
you can reduce that directory to one file containing only:

```go
package libflux

// #cgo pkg-config: flux
import "C"
```

and you will get the segmentation violation.

The output on my machine, using `go version devel go1.17-5b328c4a2f Wed Apr 28 16:13:40 2021 +0000 darwin/amd64
`, looks like:

```
fatal error: unexpected signal during runtime execution
[signal SIGSEGV: segmentation violation code=0x1 addr=0xb01dfacedebac1e pc=0x7fff708253a6]

runtime stack:
runtime: unexpected return pc for runtime.sigpanic called from 0x7fff708253a6
stack: frame={sp:0x7ffeefbff538, fp:0x7ffeefbff588} stack=[0x7ffeefb805d8,0x7ffeefbff640)
0x00007ffeefbff438:  0x01007ffeefbff458  0x0000000000000004 
0x00007ffeefbff448:  0x000000000000001f  0x00007fff708253a6 
0x00007ffeefbff458:  0x0b01dfacedebac1e  0x0000000000000001 
0x00007ffeefbff468:  0x00007ffeefbff508  0x0000000004033571 <runtime.throw+0x0000000000000071> 
0x00007ffeefbff478:  0x0000000004435420  0x00007ffeefbff4c0 
0x00007ffeefbff488:  0x0000000004033828 <runtime.fatalthrow.func1+0x0000000000000048>  0x000000000468af00 
0x00007ffeefbff498:  0x0000000000000001  0x0000000000000001 
0x00007ffeefbff4a8:  0x00007ffeefbff508  0x0000000004033571 <runtime.throw+0x0000000000000071> 
0x00007ffeefbff4b8:  0x000000000468af00  0x00007ffeefbff4f8 
0x00007ffeefbff4c8:  0x00000000040337b0 <runtime.fatalthrow+0x0000000000000050>  0x00007ffeefbff4d8 
0x00007ffeefbff4d8:  0x00000000040337e0 <runtime.fatalthrow.func1+0x0000000000000000>  0x000000000468af00 
0x00007ffeefbff4e8:  0x0000000004033571 <runtime.throw+0x0000000000000071>  0x00007ffeefbff508 
0x00007ffeefbff4f8:  0x00007ffeefbff528  0x0000000004033571 <runtime.throw+0x0000000000000071> 
0x00007ffeefbff508:  0x00007ffeefbff510  0x00000000040335a0 <runtime.throw.func1+0x0000000000000000> 
0x00007ffeefbff518:  0x000000000443a635  0x000000000000002a 
0x00007ffeefbff528:  0x00007ffeefbff578  0x0000000004048816 <runtime.sigpanic+0x0000000000000396> 
0x00007ffeefbff538: <0x000000000443a635  0x000000c00004ccbc 
0x00007ffeefbff548:  0x000000007fffff80  0x0000000000000000 
0x00007ffeefbff558:  0x000000c00004cca0  0x00007ffeefbff5b0 
0x00007ffeefbff568:  0x00007fff70a2ecaa  0x000000c00004cca0 
0x00007ffeefbff578:  0x00007ffeefbff5c0 !0x00007fff708253a6 
0x00007ffeefbff588: >0x00007ffeefbff5c0  0x000000000461e000 
0x00007ffeefbff598:  0x00000000000004ad  0x000000000407b225 <internal/syscall/unix.libc_getentropy_trampoline+0x0000000000000005> 
0x00007ffeefbff5a8:  0x00000000040632bf <runtime.syscall+0x000000000000001f>  0x000000c000167bc0 
0x00007ffeefbff5b8:  0x00000000040631cc <runtime.pthread_mutex_unlock_trampoline+0x000000000000000c>  0x000000c000167b90 
0x00007ffeefbff5c8:  0x0000000004061150 <runtime.asmcgocall+0x0000000000000070>  0x00007ffeefbff600 
0x00007ffeefbff5d8:  0x000000000400e1ae <runtime.persistentalloc.func1+0x000000000000002e>  0x0000000000001018 
0x00007ffeefbff5e8:  0x0000000000000010  0x00000000046bbcf8 
0x00007ffeefbff5f8:  0x0000000000000498  0x000000c0000001a0 
0x00007ffeefbff608:  0x000000000405f269 <runtime.systemstack+0x0000000000000049>  0x0000000000000004 
0x00007ffeefbff618:  0x0000000004474e30  0x000000000468af00 
0x00007ffeefbff628:  0x00007ffeefbff670  0x000000000405f165 <runtime.mstart+0x0000000000000005> 
0x00007ffeefbff638:  0x000000000405f11d <runtime.rt0_go+0x000000000000013d> 
runtime.throw({0x443a635, 0xc00004ccbc})
	/Users/mr/gotip/src/github.com/golang/go/src/runtime/panic.go:1198 +0x71
runtime: unexpected return pc for runtime.sigpanic called from 0x7fff708253a6
stack: frame={sp:0x7ffeefbff538, fp:0x7ffeefbff588} stack=[0x7ffeefb805d8,0x7ffeefbff640)
0x00007ffeefbff438:  0x01007ffeefbff458  0x0000000000000004 
0x00007ffeefbff448:  0x000000000000001f  0x00007fff708253a6 
0x00007ffeefbff458:  0x0b01dfacedebac1e  0x0000000000000001 
0x00007ffeefbff468:  0x00007ffeefbff508  0x0000000004033571 <runtime.throw+0x0000000000000071> 
0x00007ffeefbff478:  0x0000000004435420  0x00007ffeefbff4c0 
0x00007ffeefbff488:  0x0000000004033828 <runtime.fatalthrow.func1+0x0000000000000048>  0x000000000468af00 
0x00007ffeefbff498:  0x0000000000000001  0x0000000000000001 
0x00007ffeefbff4a8:  0x00007ffeefbff508  0x0000000004033571 <runtime.throw+0x0000000000000071> 
0x00007ffeefbff4b8:  0x000000000468af00  0x00007ffeefbff4f8 
0x00007ffeefbff4c8:  0x00000000040337b0 <runtime.fatalthrow+0x0000000000000050>  0x00007ffeefbff4d8 
0x00007ffeefbff4d8:  0x00000000040337e0 <runtime.fatalthrow.func1+0x0000000000000000>  0x000000000468af00 
0x00007ffeefbff4e8:  0x0000000004033571 <runtime.throw+0x0000000000000071>  0x00007ffeefbff508 
0x00007ffeefbff4f8:  0x00007ffeefbff528  0x0000000004033571 <runtime.throw+0x0000000000000071> 
0x00007ffeefbff508:  0x00007ffeefbff510  0x00000000040335a0 <runtime.throw.func1+0x0000000000000000> 
0x00007ffeefbff518:  0x000000000443a635  0x000000000000002a 
0x00007ffeefbff528:  0x00007ffeefbff578  0x0000000004048816 <runtime.sigpanic+0x0000000000000396> 
0x00007ffeefbff538: <0x000000000443a635  0x000000c00004ccbc 
0x00007ffeefbff548:  0x000000007fffff80  0x0000000000000000 
0x00007ffeefbff558:  0x000000c00004cca0  0x00007ffeefbff5b0 
0x00007ffeefbff568:  0x00007fff70a2ecaa  0x000000c00004cca0 
0x00007ffeefbff578:  0x00007ffeefbff5c0 !0x00007fff708253a6 
0x00007ffeefbff588: >0x00007ffeefbff5c0  0x000000000461e000 
0x00007ffeefbff598:  0x00000000000004ad  0x000000000407b225 <internal/syscall/unix.libc_getentropy_trampoline+0x0000000000000005> 
0x00007ffeefbff5a8:  0x00000000040632bf <runtime.syscall+0x000000000000001f>  0x000000c000167bc0 
0x00007ffeefbff5b8:  0x00000000040631cc <runtime.pthread_mutex_unlock_trampoline+0x000000000000000c>  0x000000c000167b90 
0x00007ffeefbff5c8:  0x0000000004061150 <runtime.asmcgocall+0x0000000000000070>  0x00007ffeefbff600 
0x00007ffeefbff5d8:  0x000000000400e1ae <runtime.persistentalloc.func1+0x000000000000002e>  0x0000000000001018 
0x00007ffeefbff5e8:  0x0000000000000010  0x00000000046bbcf8 
0x00007ffeefbff5f8:  0x0000000000000498  0x000000c0000001a0 
0x00007ffeefbff608:  0x000000000405f269 <runtime.systemstack+0x0000000000000049>  0x0000000000000004 
0x00007ffeefbff618:  0x0000000004474e30  0x000000000468af00 
0x00007ffeefbff628:  0x00007ffeefbff670  0x000000000405f165 <runtime.mstart+0x0000000000000005> 
0x00007ffeefbff638:  0x000000000405f11d <runtime.rt0_go+0x000000000000013d> 
runtime.sigpanic()
	/Users/mr/gotip/src/github.com/golang/go/src/runtime/signal_unix.go:719 +0x396

goroutine 1 [syscall, locked to thread]:
syscall.syscall(0x407b220, 0xc000132500, 0xc, 0x0)
	/Users/mr/gotip/src/github.com/golang/go/src/runtime/sys_darwin.go:22 +0x3b fp=0xc000167bc0 sp=0xc000167ba0 pc=0x405df7b
syscall.syscall(0x43ed600, 0x444e468, 0xc000167c30, 0x405e279)
	<autogenerated>:1 +0x26 fp=0xc000167c08 sp=0xc000167bc0 pc=0x4063a26
internal/syscall/unix.GetEntropy({0xc000132500, 0xc, 0x7bba9fd743fb5})
	/Users/mr/gotip/src/github.com/golang/go/src/internal/syscall/unix/getentropy_darwin.go:18 +0x50 fp=0xc000167c40 sp=0xc000167c08 pc=0x407b130
crypto/rand.getEntropy({0xc000132500, 0xc, 0xc})
	/Users/mr/gotip/src/github.com/golang/go/src/crypto/rand/rand_getentropy.go:25 +0x8e fp=0xc000167c70 sp=0xc000167c40 pc=0x40af02e
crypto/rand.(*devReader).Read(0xc0001161b0, {0xc000132500, 0xc, 0x4a58a68})
	/Users/mr/gotip/src/github.com/golang/go/src/crypto/rand/rand_unix.go:62 +0x137 fp=0xc000167d90 sp=0xc000167c70 pc=0x40af2b7
io.ReadAtLeast({0x4479620, 0xc0001161b0}, {0xc000132500, 0xc, 0xc}, 0xc)
	/Users/mr/gotip/src/github.com/golang/go/src/io/io.go:328 +0x9a fp=0xc000167dd8 sp=0xc000167d90 pc=0x4079e5a
io.ReadFull(...)
	/Users/mr/gotip/src/github.com/golang/go/src/io/io.go:347
crypto/rand.Read({0xc000132500, 0xc0001061a0, 0x4656fa0})
	/Users/mr/gotip/src/github.com/golang/go/src/crypto/rand/rand.go:24 +0x3e fp=0xc000167e18 sp=0xc000167dd8 pc=0x40aeefe
main.init.0()
	/tmp/goissue45702/main.go:11 +0x32 fp=0xc000167e40 sp=0xc000167e18 pc=0x4140692
runtime.doInit(0x4141060)
	/Users/mr/gotip/src/github.com/golang/go/src/runtime/proc.go:6416 +0x123 fp=0xc000167f80 sp=0xc000167e40 pc=0x40427c3
runtime.main()
	/Users/mr/gotip/src/github.com/golang/go/src/runtime/proc.go:238 +0x1e6 fp=0xc000167fe0 sp=0xc000167f80 pc=0x4035bc6
runtime.goexit()
	/Users/mr/gotip/src/github.com/golang/go/src/runtime/asm_amd64.s:1581 +0x1 fp=0xc000167fe8 sp=0xc000167fe0 pc=0x4061441
exit status 2
```
