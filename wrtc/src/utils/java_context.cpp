//
// Created by Lauren on 15/09/24.
//

#include <wrtc/utils/java_context.hpp>

#if defined(IS_ANDROID) && !defined(IS_TERMUX)
#include <sdk/android/native_api/jni/jvm.h>
#include <sdk/android/src/jni/jvm.h>
#endif

namespace wrtc::utils {
    void* get_jni_env() {
#if defined(IS_ANDROID) && !defined(IS_TERMUX)
        return webrtc::AttachCurrentThreadIfNeeded();
#else
        return nullptr;
#endif
    }
} // wrtc::utils
