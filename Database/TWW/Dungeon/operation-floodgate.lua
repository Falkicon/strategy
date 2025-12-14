--[[
Operation: Floodgate - Season 3 TWW Mythic+ Dungeon
Area-based strategy data for Midnight-compatible Strategy addon

Format: v2.0 (area-based strategies, not mob-based encounters)
This format uses player-initiated announcements via buttons/keybinds
instead of auto-detection via UnitName() which is blocked in Midnight.
]]--

-- Create global database table for Strategy addon
if not StrategyDatabase then
    StrategyDatabase = {}
end

if not StrategyDatabase.Instances then
    StrategyDatabase.Instances = {}
end

-- Operation: Floodgate instance data (v2.0 format)
StrategyDatabase.Instances["Operation: Floodgate"] = {
    -- Instance metadata
    instanceID = 2773,  -- Numeric ID for reliable detection
    expansion = "TWW",
    instanceType = "dungeon",
    
    -- Ordered list of strategic areas (keybinds 1-10)
    strategies = {
        -- =================================
        -- AREA 1: BEFORE BOSS 1
        -- =================================
        {
            id = "area1_opening",
            name = "Opening Pull",
            group = "Big M.O.M.M.A. TRASH",
            keybind = 1,
            strategy = {
                tank = {
                    "Pull Darkfuse mobs carefully - Hyenas require interrupts",
                    "Watch for Inspector shadow step mechanics"
                },
                interrupt = {
                    "Bloodthirsty Cackle (Hyena) - MUST interrupt",
                    "Surprise Inspection (Inspector) - shadow step + frontal"
                },
                all = {
                    "Stay grouped to prevent Inspector from kiting",
                    "Avoid R.P.G.G. explosion areas from Demolitionists"
                }
            }
        },
        
        -- =================================
        -- BOSS 1: BIG M.O.M.M.A.
        -- =================================
        {
            id = "boss1_momma",
            name = "Big M.O.M.M.A.",
            group = "Big M.O.M.M.A.",
            keybind = 2,
            strategy = {
                interrupt = {
                    "Maximum Distortion - interrupt before max energy",
                    "Must defeat 4 Mechadrones to prevent barrier"
                },
                tank = {
                    "Position around Darkfuse Mechadrones",
                    "Avoid Electrification patches"
                },
                dps = {
                    "Kill 4 Mechadrones quickly",
                    "Save CDs for Jumpstart (200% damage phase)"
                },
                healer = {
                    "Major CDs during Jumpstart intermission",
                    "Call externals if barrier lasts too long"
                },
                all = {
                    "Dodge Sonic Boom",
                    "Kill Mechadrones before max energy"
                }
            }
        },
        
        -- =================================
        -- AREA 2: AFTER BOSS 1
        -- =================================
        {
            id = "area2_loaderbots",
            name = "Loaderbot & Diver Packs",
            group = "Demolition Duo TRASH",
            keybind = 3,
            strategy = {
                interrupt = {
                    "Wind Up (Loaderbot) - CC the dangerous fixate",
                    "Harpoon (Diver) - MUST interrupt to prevent pull",
                    "Surveying Beam (Surveyor) - interrupt channel"
                },
                tank = {
                    "Loaderbot fixate cannot be tanked - help with CC",
                    "Position for easy interrupt rotations"
                },
                dps = {
                    "CC Loaderbot Wind Up immediately - dangerous for melee",
                    "Coordinate interrupt rotation for Harpoon"
                },
                healer = {
                    "Pre-heal fixated players from Wind Up",
                    "Seaforium Charge deals AoE damage"
                },
                all = {
                    "Stay spread to minimize bomb overlap",
                    "Interrupt priority: Harpoon > Wind Up > Surveying Beam"
                }
            }
        },
        
        -- =================================
        -- BOSS 2: DEMOLITION DUO
        -- =================================
        {
            id = "boss2_duo",
            name = "Demolition Duo (Keeza & Bront)",
            group = "Demolition Duo (Keeza & Bront)",
            keybind = 4,
            strategy = {
                tank = {
                    "Position bosses together for cleave",
                    "Watch for Wallop frontal from Bront"
                },
                dps = {
                    "Kill both bosses together - avoid Enrage",
                    "Use Charge/Gel to clear bombs before timer"
                },
                healer = {
                    "Dispel Gel on bombs to remove them",
                    "Major CDs if bombs explode"
                },
                dispel = {
                    "Kinetic Explosive Gel (Bombs) - Magic"
                },
                all = {
                    "Kill both simultaneously (within 10%)",
                    "Clear bombs with Charge/Gel abilities",
                    "Dodge B.B.B.F.G. frontals"
                }
            }
        },
        
        -- =================================
        -- AREA 3: WEAPON STOCKPILE ROUTE
        -- =================================
        {
            id = "area3_stockpiles",
            name = "Weapon Stockpile Route",
            group = "Swampface TRASH",
            keybind = 5,
            strategy = {
                tank = {
                    "Clear path to each of 5 Weapon Stockpiles",
                    "Watch for Shreddinator sawblades - immune to CC",
                    "Major CDs for Bloodwarper packs"
                },
                interrupt = {
                    "Blood Blast (Bloodwarper) - Tankbuster",
                    "Trickshot (Sniper) - heavy random damage",
                    "Lightning Bolt (Electrician) - HIGH priority"
                },
                healer = {
                    "Dispel Overcharge DoT (Electrician) immediately",
                    "Pre-heal during Warp Blood casts"
                },
                dispel = {
                    "Overcharge (Electrician) - Magic"
                },
                all = {
                    "Destroy all 5 Weapon Stockpiles to summon Swampface",
                    "Kill Bloodwarpers first - very dangerous",
                    "Avoid rotating flame frontal on Shreddinators"
                }
            }
        },
        
        {
            id = "area3_jumpstarter",
            name = "Darkfuse Jumpstarter (Hardest Trash)",
            group = "Swampface TRASH",
            keybind = 6,
            strategy = {
                tank = {
                    "Major cooldowns for Sparkslam",
                    "HARDEST non-boss enemy in dungeon",
                    "Immune to CC - pure tanking fight"
                },
                dps = {
                    "Focus fire - this mob is extremely dangerous",
                    "Kill quickly to reduce overall damage"
                },
                healer = {
                    "Sparkslam is a heavy tank buster",
                    "Battery Discharge requires constant group healing"
                },
                all = {
                    "Move out of Battery Discharge lightning puddles (Lethal Damage)",
                    "Continuous group-wide damage throughout fight",
                    "Use all defensives - extreme priority kill"
                }
            }
        },
        
        -- =================================
        -- BOSS 3: SWAMPFACE
        -- =================================
        {
            id = "boss3_swampface",
            name = "Swampface",
            group = "Swampface",
            keybind = 7,
            strategy = {
                tank = {
                    "Active mitigation for Sludge Claws"
                },
                dps = {
                    "Stay within 14y of vine partner",
                    "Move together to avoid Mudslide frontal"
                },
                healer = {
                    "Major CDs for Awaken the Swamp"
                },
                all = {
                    "Vines bind players in pairs (14y max)",
                    "Move together to dodge mechanics",
                    "Breaking vine = Lethal Damage"
                }
            }
        },
        
        -- =================================
        -- AREA 4: AFTER BOSS 3
        -- =================================
        {
            id = "area4_crabs",
            name = "Bombshell Crab Area",
            group = "Geezle Gigazap TRASH",
            keybind = 8,
            strategy = {
                tank = {
                    "Control pull sizes - crabs explode on death",
                    "Pinch applies stacking slow"
                },
                interrupt = {
                    "Restorative Algae (Kelp) - MUST interrupt healing",
                    "Jettison Kelp - use CC to end channel"
                },
                healer = {
                    "Crabsplosion creates stacking group DoT",
                    "More simultaneous crab deaths = more stacks"
                },
                all = {
                    "Don't kill too many crabs at once",
                    "Each explosion adds stacking DoT to everyone",
                    "Coordinate kills to manage DoT stacks"
                }
            }
        },
        
        -- =================================
        -- BOSS 4: GEEZLE GIGAZAP
        -- =================================
        {
            id = "boss4_geezle",
            name = "Geezle Gigazap",
            group = "Geezle Gigazap",
            keybind = 9,
            strategy = {
                tank = {
                    "Major CDs before Thunder Punch"
                },
                dps = {
                    "Use defensives during Turbo Charge",
                    "Avoid Dam Rubble puddles"
                },
                healer = {
                    "Major CDs for Turbo Charge damage"
                },
                all = {
                    "Defensives for Turbo Charge phase",
                    "Avoid water puddles when targeted",
                    "Lead Sparks to fresh water to remove them"
                }
            }
        },
        
        -- =================================
        -- GENERAL DUNGEON MECHANICS
        -- =================================
        {
            id = "general_mechanics",
            name = "Key Dungeon Mechanics",
            group = "General",
            keybind = 10,
            strategy = {
                all = {
                    "Destroy 5/5 Weapon Stockpiles to unlock Swampface",
                    "Kill Demolition Duo within 10% of each other",
                    "Vine break = Instant Lethal Damage on Swampface",
                    "Jumpstarter is hardest trash - save CDs"
                }
            }
        }
    }
}
