Yet Another Toy Scripting Language

YATSL is a scripting language built with Swift. it's main intended purpose is to be used for builds (akin to just/make/nob.h). But, ideally, it should be useful for other stuff.

It does aim for ergonomics and clarity but not for performance (as of now).



## Language concepts
To see a 'real world' example, check the example.yatsl


- Everything is passed as an array. Calling a function with a value (`someFunc!var`) is just syntax sugar for (`someFunc![var]`)
- The program interacts with the CLI. The entrypoint is the first procedure provided (or `_start` in the lack of it). 
	exported constants may also be mutated via cli-args 	
	e.g. `yatsl build! --cc clang`

- Atoms: atoms are typeless values wich hold an array. Think of an infinite Rust enum which values hold a [any; unknown_size].
	they are prepended with a period (`.`) and intended to be used as options for stuff like OS 
	e.g. `set supportedOSs [.linux .darwin .windows]`

- identifiers are immutable and may only be shadowed.
	- keyword: `let <identifier> <val>`   / assigns a value to an identifier 
	- keyword: `set <identifier> <val>`   / ' '  in the global scope. in practice, like mutation. useful for imperative paradigms in loops
	- keyword: `const <identifier> <val>` / ' '  pre-runtime, before the entrypoint being executed
- procedures accept a single array as argument and return one (might be a unit (empty array) `[]` for no intended return)
	- keword: `proc <identifier>!inputArr(?) <body>` / assigns a procedure to an identifier




## Building
For now, the interpreter (well, lexer, for now) is intended to be built via swiftc.
	1. Install the swift toolchain (https://www.swift.org/install) 
		if you're on arch:
			git clone https://aur.archlinux.org/packages/swift-bin; cd swift-bin
			makepkg -si

	2. run the build command (manually, if you want, use just)
		swiftc src/yatsl.swift src/lexer.swift -o yatslc

	3. use the lexer on your YATSL file !
		./yatsl example.yatsl
		and see the tokens log !
-----------------------
STATIC BUILDS
To build using the musl static sdk, first
1. install the Static Linux SDK via the swift toolchain (you may also download it but uou'll have to edit the build script with the according folders)
2. run the command in build-static.sh
That's it! It will give you an executable, just as the 
dynamic one except for it being like 20 times heavier
(and static!)
-----------------------
Installing  just (https://github.com/casey/just)
	it most likely is in your repos (apt install just; pacman -S just; ...)
	or you can just install it through npm :skull: (npm install -g rust-just)
