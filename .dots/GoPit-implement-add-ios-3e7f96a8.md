---
title: "implement: Add iOS and Android export presets"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T11:06:25.315668-06:00"
---

## Description

Add iOS and Android export presets to export_presets.cfg so the game can be built for mobile platforms.

## Context

The Mobile Optimization task (GoPit-29a) notes this can be done without physical devices. Web export already works. This is Phase A of mobile optimization.

## Implementation

### 1. Check current export presets

```bash
cat export_presets.cfg
```

### 2. Add iOS preset

```ini
[preset.N]
name="iOS"
platform="iOS"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path=""
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.N.options]
custom_template/debug=""
custom_template/release=""
architectures/arm64=true
application/app_store_team_id=""
application/provisioning_profile_uuid_debug=""
application/provisioning_profile_uuid_release=""
application/code_sign_identity_debug=""
application/code_sign_identity_release=""
application/export_project_only=false
application/bundle_identifier="com.randroid.gopit"
application/signature=""
application/short_version="1.0"
application/version="1.0.0"
application/icon_interpolation=4
application/launch_screens_interpolation=4
capabilities/access_wifi=false
capabilities/push_notifications=false
user_data/accessible_from_files_app=false
privacy/camera_usage_description=""
privacy/camera_usage_description_localized={}
privacy/microphone_usage_description=""
privacy/microphone_usage_description_localized={}
privacy/photolibrary_usage_description=""
privacy/photolibrary_usage_description_localized={}
icons/iphone_120x120=""
icons/iphone_180x180=""
icons/ipad_76x76=""
icons/ipad_152x152=""
icons/ipad_167x167=""
icons/app_store_1024x1024=""
icons/spotlight_40x40=""
icons/spotlight_80x80=""
storyboard/use_launch_screen_storyboard=false
storyboard/image_scale_mode=0
storyboard/custom_image@2x=""
storyboard/custom_image@3x=""
storyboard/use_custom_bg_color=false
storyboard/custom_bg_color=Color(0, 0, 0, 1)
```

### 3. Add Android preset

```ini
[preset.M]
name="Android"
platform="Android"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path=""
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.M.options]
custom_template/debug=""
custom_template/release=""
gradle_build/use_gradle_build=false
gradle_build/export_format=0
gradle_build/min_sdk="24"
gradle_build/target_sdk="34"
architectures/armeabi-v7a=false
architectures/arm64-v8a=true
architectures/x86=false
architectures/x86_64=false
version/code=1
version/name="1.0.0"
package/unique_name="com.randroid.gopit"
package/name="GoPit"
package/signed=true
package/app_category=0
package/retain_data_on_uninstall=false
package/exclude_from_recents=false
package/show_in_android_tv=false
package/show_in_app_library=true
package/show_as_launcher_app=false
launcher_icons/main_192x192=""
launcher_icons/adaptive_foreground_432x432=""
launcher_icons/adaptive_background_432x432=""
graphics/opengl_debug=false
xr_features/xr_mode=0
screen/immersive_mode=true
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
user_data/accessible_from_files_app=false
permissions/custom_permissions=PackedStringArray()
```

## Affected Files

- MODIFY: export_presets.cfg

## Verify

- [ ] ./test.sh passes
- [ ] `godot --headless --export-release "iOS" /dev/null` shows iOS export options (may warn about missing signing)
- [ ] `godot --headless --export-release "Android" /dev/null` shows Android export options (may warn about missing keystore)
- [ ] Both presets visible in Godot editor Export dialog
