# Reuse the Android native dependency setup (including Oboe), while the
# NTG_TERMUX_RUNTIME compile flag disables Android-app JNI video integration.
include("${ROOT_DIR}/targets/android/build.cmake")
