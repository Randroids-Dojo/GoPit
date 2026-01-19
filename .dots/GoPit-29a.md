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
Optimize for mobile performance, test on devices, and prepare exports.

## Requirements
1. Maintain 60fps on mid-range devices
2. Memory management for long sessions
3. Touch controls feel responsive
4. Battery usage reasonable
5. iOS and Android exports working
6. Web export functional

## Performance Targets
- 60fps stable gameplay
- < 200MB memory usage
- < 5% CPU idle
- Responsive touch (< 16ms latency)

## Optimization Areas
**Rendering:**
- Batch draw calls where possible
- Limit active particle systems
- Use object pooling for balls/gems
- Reduce overdraw

**Memory:**
- Pool frequently created objects
- Clear unused resources between stages
- Monitor for memory leaks

**Touch:**
- Profile input latency
- Ensure hit targets are adequate
- Test with various screen sizes

## Testing Matrix
| Platform | Devices |
|----------|---------|
| iOS | iPhone 12, iPad |
| Android | Pixel 6, budget device |
| Web | Chrome, Safari, Firefox |

## Files to Modify
- MODIFY: Various scripts for pooling
- MODIFY: export_presets.cfg
- MODIFY: project.godot (renderer settings)

## Acceptance Criteria
- [ ] 60fps on target devices
- [ ] Memory stable during long sessions
- [ ] Touch controls responsive
- [ ] iOS export works
- [ ] Android export works
- [ ] Web export works
- [ ] All PlayGodot tests pass

## Verify
- [ ] `./test.sh` passes
- [ ] Profile on iPhone 12 - maintains 60fps during intense gameplay
- [ ] Profile on mid-range Android (Pixel 6) - maintains 60fps
- [ ] Play 30-minute session - memory usage stays under 200MB
- [ ] Touch input latency < 16ms on mobile devices
- [ ] Export iOS build successfully
- [ ] Export Android build successfully
- [ ] Web export plays correctly in Chrome, Safari, Firefox
