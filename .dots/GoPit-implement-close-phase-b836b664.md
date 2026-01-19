---
title: "implement: Close Phase 5 EPIC and Mobile Optimization task"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T11:30:04.477963-06:00"
---

## Description

Close the Phase 5 EPIC (GoPit-aoo) and update the Mobile Optimization task (GoPit-29a) to reflect completion status.

## Context

Research confirms Phase 5 success criteria are met:
- ✅ Unique music per biome
- ✅ Complete SFX coverage
- ✅ Particle effects for all actions
- ✅ Tutorial for new players
- ✅ Web export working
- ✅ All tests passing
- ⏳ Mobile performance (export presets done, device profiling is post-release work)

Device profiling on physical hardware is valuable but not a release blocker.

## Affected Files

- MODIFY: `.dots/GoPit-aoo.md` - Change status to closed
- MODIFY: `.dots/GoPit-29a.md` - Change status to closed with note about future Phase C work

## Implementation Notes

### Close GoPit-aoo (Phase 5 EPIC)

```bash
dot off GoPit-aoo -r 'Phase 5 complete. All polish items done: biome music, SFX, particles, tutorial. Device profiling deferred to post-release.'
```

### Close GoPit-29a (Mobile Optimization)

```bash
dot off GoPit-29a -r 'Phases A/B complete. Export presets added, profiling methodology documented. Phase C (device testing) deferred - requires physical iOS/Android hardware.'
```

### Optional: Create Future Task

Create a low-priority task for device profiling:
```bash
dot add 'Mobile device profiling (post-release)' -d 'Phase C of mobile optimization. Test on iPhone 12 and Pixel 6 per documented testing matrix in archived GoPit-29a.'
```

## Verify

- [ ] GoPit-aoo shows status: closed in `dot list`
- [ ] GoPit-29a shows status: closed in `dot list`
- [ ] Archive files exist for both tasks
- [ ] `dot tree` shows no blocking relationships
