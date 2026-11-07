set(LIBCXX_INCLUDE ${DEPS_DIR}/libcxx)
set(LIBCXXABI_INCLUDE ${DEPS_DIR}/libcxxabi)

# The Termux build uses the NDK compiler but deliberately skips Chromium's
# bundled libc++. Add the matching NDK libc++ headers explicitly because the
# compiler is selected by FindClang.cmake after the Android toolchain setup.
if (TERMUX_RUNTIME OR "$ENV{TERMUX_RUNTIME}" STREQUAL "ON")
    if (NOT NDK_SRC)
        get_filename_component(NDK_SRC "${CMAKE_CURRENT_LIST_DIR}/../deps/ndk/src" ABSOLUTE)
    endif ()
    set(TERMUX_LIBCXX_INCLUDE "${NDK_SRC}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/c++/v1")
    if (NOT EXISTS "${TERMUX_LIBCXX_INCLUDE}/cassert")
        message(FATAL_ERROR "NDK libc++ headers not found: ${TERMUX_LIBCXX_INCLUDE}")
    endif ()
    add_compile_options(
        "$<$<COMPILE_LANGUAGE:CXX>:-isystem${TERMUX_LIBCXX_INCLUDE}>"
        "$<$<COMPILE_LANGUAGE:OBJCXX>:-isystem${TERMUX_LIBCXX_INCLUDE}>"
    )
endif ()

if((LINUX OR MACOS OR WINDOWS OR ANDROID) AND USE_LIBCXX)
    GitClone(
        URL https://chromium.googlesource.com/external/github.com/llvm/llvm-project/libcxx.git
        COMMIT ${LIBCXX_COMMIT}
        DIRECTORY ${LIBCXX_INCLUDE}
    )
    GitFile(
        URL https://chromium.googlesource.com/chromium/src/buildtools.git/+/${BUILDTOOLS_COMMIT}/third_party/libc++/__config_site
        DIRECTORY ${LIBCXX_INCLUDE}/include/__config_site
    )
    GitFile(
        URL https://chromium.googlesource.com/chromium/src/buildtools.git/+/${BUILDTOOLS_COMMIT}/third_party/libc++/__assertion_handler
        DIRECTORY ${LIBCXX_INCLUDE}/include/__assertion_handler
    )
    if (WINDOWS)
        add_compile_options("$<$<COMPILE_LANGUAGE:CXX>:-I${LIBCXX_INCLUDE}/include>")
    else ()
        GitClone(
            URL https://chromium.googlesource.com/external/github.com/llvm/llvm-project/libcxxabi.git
            COMMIT ${LIBCXX_ABI_COMMIT}
            DIRECTORY ${LIBCXXABI_INCLUDE}
        )
        add_compile_options(
            "$<$<COMPILE_LANGUAGE:CXX>:-nostdinc++>"
            "$<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:LIBCXX_INCLUDE_DIR>>:-isystem${LIBCXX_INCLUDE}/include>"
            "$<$<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:LIBCXXABI_INCLUDE_DIR>>:-isystem${LIBCXXABI_INCLUDE}/include>"
            "$<$<COMPILE_LANGUAGE:OBJCXX>:-nostdinc++>"
            "$<$<AND:$<COMPILE_LANGUAGE:OBJCXX>,$<BOOL:LIBCXX_INCLUDE_DIR>>:-isystem${LIBCXX_INCLUDE}/include>"
            "$<$<AND:$<COMPILE_LANGUAGE:OBJCXX>,$<BOOL:LIBCXXABI_INCLUDE_DIR>>:-isystem${LIBCXXABI_INCLUDE}/include>"
        )
    endif ()
endif ()
