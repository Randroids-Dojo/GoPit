---
title: Mobile Optimization & Testing
status: open
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:42:47.222251-06:00
---

# Mobile Optimization & Testing

## Parent Epic
GoPit-aoo (Phase 5 - Polish & Release)

## Overview
Optimize for mobile performance, profile on devices, and prepare iOS/Android exports.

## Implementation Phases

This task naturally breaks into phases that can be done incrementally:

**Phase A: Export Presets (can do without devices)**
- Add iOS and Android export presets to `export_presets.cfg`
- Verify exports build without errors (CI can validate)
- Note: Cannot test on real devices until provisioning profiles are set up

**Phase B: Desktop/Web Profiling (can do without devices)**
- Profile on desktop as performance baseline
- Profile web export in Chrome DevTools
- Identify any obvious bottlenecks before device testing

**Phase C: Device Testing (requires physical devices)**
- Install on iOS/Android devices
- Profile with platform-specific tools
- Iterate on optimizations based on real data

**Recommendation:** Complete Phases A and B first, then Phase C when devices are available.

## Current State

**Already Implemented:**
- Object pooling for balls, gems, damage numbers (`scripts/autoload/pool_manager.gd`)
- Pool sizes: balls (20-50), damage numbers (30-100), gems (30-100)
- Renderer: `gl_compatibility` mode (mobile-optimized)
- Web export preset configured with custom shell

**Gaps:**
- No iOS export preset
- No Android export preset
- No profiling data on actual devices
- No particle system limits
- Enemies not pooled (could be added)

## Requirements

### 1. Export Presets
Add iOS and Android export presets to `export_presets.cfg`:

**iOS Requirements:**
- Team ID and provisioning profile
- App icons (multiple resolutions)
- Launch screen storyboard
- Capabilities declarations

**Android Requirements:**
- Keystore for signing
- App icons and adaptive icons
- Min SDK version (API 24+ recommended for Godot 4)
- Permissions declarations

### 2. Performance Profiling
Use Godot's built-in profiler and platform tools:

**Desktop Profiling (baseline):**
1. Run game with `--verbose` flag
2. Use Debugger > Profiler in editor
3. Monitor: frame time, physics time, script time

**Web Profiling:**
1. Use Chrome DevTools Performance tab
2. Check for long frame times, GC spikes
3. Monitor memory via Performance > Memory

**iOS Profiling (Instruments):**
1. Build with debug symbols
2. Use Time Profiler and Allocations
3. Check for CPU spikes, memory leaks

**Android Profiling:**
1. Use Android Studio Profiler (CPU, Memory, Energy)
2. Or `adb shell dumpsys gfxinfo <package>` for frame stats
3. Check logcat for performance warnings

### 3. Optimization Opportunities

**Particle Systems:**
- Audit all GPUParticles2D/CPUParticles2D usage
- Set `amount` limits based on device class
- Consider quality settings toggle (low/medium/high)

**Enemy Pooling (Optional):**
- Add enemy pool to pool_manager.gd
- More complex due to different enemy types
- May not be needed if enemy count stays low

**Draw Call Batching:**
- Check CanvasItem usage in profiler
- Combine static UI elements where possible
- Use AtlasTexture for sprite sheets

## Performance Targets
- 60fps stable (16.67ms frame budget)
- < 200MB memory usage
- < 5% CPU when idle/paused
- Touch latency < 16ms (1 frame)

## Testing Matrix
| Platform | Device | Target FPS | Notes |
|----------|--------|------------|-------|
| iOS | iPhone 12 | 60fps | Primary target |
| iOS | iPad (any recent) | 60fps | Larger screen |
| Android | Pixel 6 | 60fps | Mid-range reference |
| Android | Budget device | 30fps min | Graceful degradation |
| Web | Chrome (desktop) | 60fps | Already working |
| Web | Safari (macOS) | 60fps | WebGL testing |
| Web | Mobile Safari | 30fps min | Limited GPU |

## Files to Modify/Create

- MODIFY: `export_presets.cfg` - Add iOS and Android presets
- NEW: `android/build/` - Gradle project if custom build needed
- NEW: `ios/` - Xcode project assets if needed
- POTENTIALLY: `scripts/autoload/pool_manager.gd` - Add enemy pool
- POTENTIALLY: `project.godot` - Quality settings

## Export Preset Templates

**iOS Preset (add to export_presets.cfg):**
```ini
[preset.1]
name="iOS"
platform="iOS"
runnable=true
# ... additional iOS options
```

**Android Preset:**
```ini
[preset.2]
name="Android"
platform="Android"
runnable=true
# ... additional Android options
```

## Acceptance Criteria
- [ ] iOS export builds without errors
- [ ] Android export builds without errors
- [ ] 60fps maintained on iPhone 12 during intense gameplay (10+ enemies, particles)
- [ ] 60fps maintained on Pixel 6 during intense gameplay
- [ ] Memory usage under 200MB during 30-minute session
- [ ] No memory leaks (memory stable over time)
- [ ] Touch controls responsive (no perceptible lag)
- [ ] Web export continues working (no regression)
- [ ] All PlayGodot tests pass

## Verify
- [ ] `./test.sh` passes
- [ ] `godot --export-release "iOS" build/gopit.ipa` succeeds
- [ ] `godot --export-release "Android" build/gopit.apk` succeeds
- [ ] Install iOS build on test device - launches and plays
- [ ] Install Android build on test device - launches and plays
- [ ] Profile on iPhone 12:
  - Frame time < 16ms during boss fights
  - Memory < 200MB after 30 minutes
- [ ] Profile on Pixel 6:
  - Frame time < 16ms during normal gameplay
  - No GC stutters visible
- [ ] Web build works in Chrome, Safari, Firefox (no regression)
