# Google Play Services & AdMob Rules
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.gms.googleservices.** { *; }

# Hive Database Rules
-keep class io.hive.** { *; }
-dontwarn io.hive.**

# Keep generic structures needed for JSON serialization
-keepattributes Signature, InnerClasses, EnclosingMethod, AnnotationDefault
