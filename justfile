yatslc:
	swiftc src/yatsl.swift src/lexer.swift -o yatslc


# i give up trying to make this work in justfile
yatslc-static:
	bash ./build-static.sh
