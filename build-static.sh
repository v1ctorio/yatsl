STATIC_SDK_ROOT="$HOME/.swiftpm/swift-sdks/\
swift-6.3.3-RELEASE_static-linux-0.1.0.artifactbundle/\
swift-6.3.3-RELEASE_static-linux-0.1.0/\
swift-linux-musl"

SYSROOT="$STATIC_SDK_ROOT/musl-1.2.5.sdk/x86_64"
SWIFT_RESOURCES="$SYSROOT/usr/lib/swift_static"
TOOLS="$STATIC_SDK_ROOT/swift.xctoolchain/usr/bin"

swiftc src/yatsl.swift src/lexer.swift \
    -target x86_64-swift-linux-musl \
    -sdk "$SYSROOT" \
    -resource-dir "$SWIFT_RESOURCES" \
    -tools-directory "$TOOLS" \
    -static-executable \
    -static-stdlib \
    -Xcc --sysroot \
    -Xcc "$SYSROOT" \
    -O \
    -o yatslc
