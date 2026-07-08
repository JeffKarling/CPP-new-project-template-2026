---
name: power_control
description: Change the host machine's Linux power profile using tuned-adm.
---

## Skill: Change System Power Profile

### Description
Use this skill to switch the host machine's Linux power profile between throughput-performance, balanced, and powersave.

### Tools

#### Set Performance Mode
Run this to maximize CPU clock speeds and ignore power limits.
```bash
tuned-adm profile throughput-performance
```

#### Set Balanced Mode
Run this to return to normal desktop usage.
```bash
tuned-adm profile balanced
```

#### Set Power Saver Mode
Run this to silence fans and save battery.
```bash
tuned-adm profile powersave
```
