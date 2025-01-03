# Đảm bảo giữ các lớp cần thiết cho Firebase
-keepattributes *Annotation*
-keepattributes InnerClasses
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
