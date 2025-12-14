# Strategy Database Guidelines

This directory contains modular encounter data for the Strategy addon. Each file represents a single instance (dungeon/raid) with all its strategic areas organized in progression order.

The database uses an area-based organization. Strategies are keyed by strategic areas (boss fights, big pulls, key mechanics) rather than individual mob names. This enables button-based announcements.

## Directory Structure

```
Database/
├── TWW/                    # The War Within expansion
│   ├── Dungeon/           # Mythic+ dungeons
│   │   ├── operation-floodgate.lua
│   │   ├── halls-of-atonement.lua
│   │   └── [other-dungeons].lua
│   └── Raid/              # Raid encounters (future)
│       └── [raid-files].lua
├── DF/                    # Dragonflight (future expansion)
└── [OTHER-EXPANSIONS]/    # Future expansion support
```

## File Naming Conventions

### ✅ Correct Naming

- `operation-floodgate.lua` (lowercase, hyphens)
- `halls-of-atonement.lua`
- `ara-kara.lua`
- `tazavesh-streets.lua`

### ❌ Incorrect Naming

- `Operation_Floodgate.lua` (uppercase, underscores)
- `operation floodgate.lua` (spaces)
- `OperationFloodgate.lua` (camelCase)

## File Structure Template

Each instance file must return a data table with this exact structure:

```lua
--[[
Instance Name - Season X Expansion Mythic+/Raid
Brief description of the instance
]]--

return {
    -- Instance metadata
    instanceName = "Operation: Floodgate",
    instanceID = 2773,  -- For reliable detection via GetInstanceInfo()
    instanceType = "dungeon", -- or "raid"
    expansion = "TWW", -- or "DF", "SL", etc.

    -- Ordered list of strategic areas (shown in Strategy Panel)
    strategies = {
        -- Each entry represents a button in the Strategy Panel
        {
            id = "opening",           -- Unique identifier (for tracking)
            name = "Opening Pull",    -- Button label
            group = "First Area",     -- Collapsible group header
            keybind = 1,              -- Default keybind (1-10)

            -- Role-specific strategies (same format as before)
            strategy = {
                interrupt = {
                    "Ability Name - must interrupt"
                },
                tank = {
                    "Tank-specific guidance (3-6 words)"
                },
                dps = {
                    "DPS priority notes"
                },
                healer = {
                    "Healing focus points"
                },
                all = {
                    "Party-wide mechanics"
                }
            }
        },
        {
            id = "boss1",
            name = "Big M.O.M.M.A.",
            group = "Boss 1",
            keybind = 2,
            strategy = {
                interrupt = {"Maximum Distortion - must interrupt"},
                tank = {"Major CDs during Jumpstart"},
                dps = {"Kill Mechadrones quickly"},
                healer = {"Heavy damage during Jumpstart"},
                all = {"Dodge Sonic Boom"}
            }
        },
        -- Continue with more strategic areas...
    }
}
```



## Data Quality Standards

### Instance Identification

- **Use instanceID**: The numeric ID from `GetInstanceInfo()` is most reliable
- **instanceName**: Human-readable name for UI display
- **Verify In-Game**: Use `/run print(GetInstanceInfo())` to get the correct ID

### Strategy Ordering

- **Logical Progression**: Order strategies as players encounter them in the dungeon
- **Group by Area**: Use `group` field to organize related strategies
- **Keybind Assignment**: Assign keybinds 1-10 to most frequently used strategies

### Strategy Content Guidelines

#### Combat-Friendly Writing Principles ⚡

**GOAL**: Provide instant, actionable advice readable during intense combat situations.

#### Length Guidelines

- **Boss Strategies**: 3-6 words per point maximum
- **Trash Mobs**: Single line format only
- **Action-First**: Lead with what to DO, not explanations
- **Abbreviations OK**: "CDs" for "cooldowns", "14y" for "14 yards"

#### ✅ EXCELLENT Examples (Combat-Ready)

```lua
-- Boss strategies (concise, actionable)
tank = {
    "Major CDs before Thunder Punch",
    "Position bosses together for cleave"
},
dps = {
    "Kill both simultaneously",
    "Use Charge/Gel to clear bombs"
},

-- Trash mobs (one-line format)
["Shreddinator 3000"] = {
    mobType = "trash",
    all = {
        "Immune to CC, dodge sawblades, avoid rotating flame frontal"
    }
},
```

#### ❌ BAD Examples (Too Verbose for Combat)

```lua
-- TOO LONG - Can't read during fight
tank = {
    "Use major defensive cooldowns before each Thunder Punch to mitigate the heavy damage",
    "Be careful to position both bosses together so DPS can cleave them down efficiently"
},

-- TRASH TOO DETAILED - Should be one line
["Shreddinator 3000"] = {
    interrupt = {"Immune to CC - cannot be controlled"},
    tank = {"Point Flamethrower frontal away from group"},
    dps = {"Move out of sawblades spawned under every player"}
}
```

#### Interrupt Section Format

```lua
interrupt = {
    "Ability Name - interrupt before [consequence]",
    "Another Ability - must interrupt"
},
-- OR for trash (preferred):
all = {
    "Interrupt [Ability], dodge [mechanic], avoid [danger]"
}
```

#### Combat Abbreviations (Encouraged)

- **CDs** = cooldowns
- **14y** = 14 yards
- **max** = maximum
- **Pri** = priority
- **CC** = crowd control
- **DoT** = damage over time
- **AoE** = area of effect

### Mob Type Classifications

#### Boss (`mobType = "boss"`)

- **Format**: Role-specific sections with 2-6 word actionable points
- **Focus**: Critical mechanics, cooldown usage, positioning
- **Style**: "Major CDs before Thunder Punch" not "Use major defensive cooldowns before each Thunder Punch to mitigate heavy damage"

#### Trash (`mobType = "trash"`)

- **Format**: Single `all = {}` section with one-line summary
- **High Priority Only**: Mobs that frequently cause wipes
- **Style**: "Interrupt [Ability], avoid [mechanic], priority target"
- **Example**: `"Immune to CC, dodge sawblades, avoid flame frontal"`

#### Trash Mob One-Line Format Template

```lua
["Mob Name"] = {
    mobType = "trash",
    priority = "high",
    all = {
        "[Action 1], [action 2], [action 3]"
    }
}
```

#### Priority Levels for Trash

- `"high"` - Critical mobs that often cause wipes (interrupt required, positioning critical)
- `"medium"` - Important but not wipe-inducing (reserved for future expansion)
- `"low"` - Minor threats (not included in current system)

## Content Standards

### Research Requirements

- **Official Guides**: Reference Wowhead, Method, or other authoritative guides
- **In-Game Testing**: Verify all ability names and mechanics in actual runs
- **Community Validation**: Cross-check with experienced players when possible

### Writing Style

- **Combat-Ready**: Must be readable during intense M+ combat
- **Ultra-Concise**: 3-6 words max per strategy point
- **Action-First**: Lead with verbs ("Interrupt", "Dodge", "Use", "Kill")
- **No Fluff**: Remove articles (a, an, the), conjunctions, explanatory text
- **Abbreviations Welcome**: Use "CDs", "14y", "pri", "max" to save space
- **One-Line Trash**: All trash mechanics in single readable line

### Ability Names

- **Exact Match**: Use the exact spell names as they appear in-game
- **Spell Links**: When possible, verify against spell databases
- **Consistency**: Same ability should have same name across all references

## Testing Requirements

### Before Submitting

1. **Syntax Validation**: Ensure Lua syntax is correct
2. **In-Game Loading**: Test that the file loads without errors
3. **Name Verification**: Confirm all boss names match exactly in-game
4. **Strategy Accuracy**: Verify mechanics are current and accurate

### Testing Commands

```lua
/ff list             -- List all strategies for current instance
/ff 1                -- Test announcing strategy #1
/reload              -- Reload to test file loading
/ff status           -- Verify instance loaded correctly
```

## Common Mistakes to Avoid

### ❌ File Structure Errors

- Missing `return` statement at the beginning
- Incorrect table structure
- Missing required fields (`instanceID`, `instanceName`, `strategies`)

### ❌ Strategy Organization Errors

- Not ordering strategies by dungeon progression
- Missing `id` field (needed for announced tracking)
- Duplicate `id` values within same instance
- Keybind conflicts (same number for multiple strategies)

### ❌ Strategy Content Issues (Critical!)

- **TOO VERBOSE**: "Use major defensive cooldowns before each Thunder Punch" ❌
- **CORRECT**: "Major CDs before Thunder Punch" ✅
- **TRASH TOO DETAILED**: Multiple role sections for trash ❌
- **CORRECT**: Single one-line `all = {}` entry ✅
- **EXPLANATORY TEXT**: "to mitigate damage", "in order to avoid" ❌
- **ACTION-FIRST**: "Dodge", "Interrupt", "Kill" ✅

### ❌ Combat Readability Failures

- Long sentences players can't read during combat
- Multiple trash strategies when one line would suffice
- Explanations instead of direct commands
- Missing abbreviations that save critical space

### ❌ Zone Detection Problems

- Zone names that don't match WoW's internal zone detection
- Missing zone entries for bosses that appear in multiple instances
- Inconsistent zone naming within the same file

## Expansion Guidelines

### Adding New Dungeons

1. Create new file following naming convention
2. Get instanceID via `/run print(GetInstanceInfo())` in the dungeon
3. Organize strategies by progression order
4. Focus on boss fights and wipe-causing trash packs
5. Test in-game with `/ff list` to verify loading
6. Assign keybinds 1-10 to most important strategies

### Adding New Expansions

1. Create new expansion folder (e.g., `Database/DF/`)
2. Create appropriate subfolders (`Dungeon/`, `Raid/`)
3. Follow same structure and standards
4. Update instance detection logic for new IDs

### Seasonal Updates

- Review and update strategies when mechanics change
- Add new dungeons as they enter the M+ rotation
- Remove or archive outdated content appropriately

## Quality Assurance Checklist

Before adding any new encounter data:

### ✅ Structure & Technical

- [ ] File follows exact naming convention
- [ ] instanceID verified in-game via `/run print(GetInstanceInfo())`
- [ ] All required fields present (`instanceID`, `instanceName`, `strategies`)
- [ ] Each strategy has unique `id` field
- [ ] Strategies ordered by dungeon progression
- [ ] File tested in-game with `/reload` and `/ff list`
- [ ] No Lua syntax errors

### ✅ Combat-Ready Content Standards

- [ ] **Boss strategies**: 3-6 words max per point
- [ ] **Trash/pulls**: Concise, actionable format
- [ ] **Action-first**: Starts with verbs (Interrupt, Dodge, Kill, Use)
- [ ] **No fluff**: Removed "a", "the", "in order to", explanatory text
- [ ] **Abbreviations used**: "CDs", "14y", "max", "pri" where appropriate
- [ ] **Strategies verified** against authoritative guides
- [ ] **Combat tested**: Readable during intense M+ situations

### ✅ Examples Pass This Test

**Can you read this strategy in 2 seconds during combat?**

- ✅ "Major CDs before Thunder Punch"
- ❌ "Use major defensive cooldowns before each Thunder Punch to mitigate the heavy damage"

## Support

For questions about database standards or contribution guidelines:

1. Reference existing files as examples (especially `operation-floodgate.lua`)
2. Test thoroughly before submitting
3. Follow the established patterns for consistency
4. Prioritize quality over quantity - better to have fewer, high-quality encounters than many poor ones

---

**Remember**: The goal is to provide instant, accurate, actionable advice that helps groups succeed in challenging M+ content. Every piece of data should serve that mission. 🎯
