--[[
    Manaforge Omega - Midnight Raid
    Strategy Data
]]

if not StrategyDatabase then StrategyDatabase = {} end
if not StrategyDatabase.Instances then StrategyDatabase.Instances = {} end

StrategyDatabase.Instances["Manaforge Omega"] = {
    instanceID = 0, -- TODO: Update with actual Midnight ID
    expansion = "Midnight",
    instanceType = "raid",
    strategies = {
        -- =================================
        -- BOSS 1: PLEXUS
        -- =================================
        {
            id = "mo_boss1",
            name = "Plexus",
            group = "Boss 1",
            keybind = 1,
            strategy = {
                tank = {
                    "Obliteration Arcanocannon: Run to corner",
                    "Swap after each Arcanocannon cast"
                },
                healer = {
                    "Eradicating Salvo: Group soak damage",
                    "Spot heal Manifest Matrices targets"
                },
                all = {
                    "P1: Stack behind boss for Salvo",
                    "Place Matrices pools away from group",
                    "P2: Use Phase Blink to pass walls"
                }
            }
        },
        
        -- =================================
        -- BOSS 2: LOOM'ITHAR
        -- =================================
        {
            id = "mo_boss2",
            name = "Loom'ithar",
            group = "Boss 2",
            keybind = 2,
            strategy = {
                tank = {
                    "Piercing Strand: Swap back-to-back",
                    "P2: Writhing Wave (Frontal) needs soak"
                },
                all = {
                    "Infusion Tether: Run to edge to break",
                    "Place Living Silk pools together",
                    "P2: Bloodlust (Unbound Rage)"
                }
            }
        },
        
        -- =================================
        -- BOSS 3: SOULBINDER NAAZINDHRI
        -- =================================
        {
            id = "mo_boss3",
            name = "Soulbinder Naazindhri",
            group = "Boss 3",
            keybind = 3,
            strategy = {
                tank = {
                    "Mystic Lash = Stacking Dmg Taken",
                    "Position boss near target chambers"
                },
                interrupt = {
                    "Void Burst (Mage Add) - PRIORITY"
                },
                all = {
                    "Annihilation Beams: Break 6 nearest chambers",
                    "Avoid Soulfire Convergence lines",
                    "Knockback hazard (Edges)"
                }
            }
        },
        
        -- =================================
        -- BOSS 4: FORGEWEAVER ARAZ
        -- =================================
        {
            id = "mo_boss4",
            name = "Forgeweaver Araz",
            group = "Boss 4",
            keybind = 4,
            strategy = {
                tank = {
                    "Arcane Obliteration: Move away + Raid Soak",
                    "Intermission: Tank Shielded Attendants"
                },
                dps = {
                    "Kill Pylons during Intermission",
                    "Mana Splinter = BURST WINDOW"
                },
                all = {
                    "Astral Harvest: Spawn orbs under boss",
                    "P2: Dark Singularity = Lethal Damage",
                    "Aim Intermission knockback toward entrance"
                }
            }
        },
        
        -- =================================
        -- BOSS 5: SOUL HUNTERS
        -- =================================
        {
            id = "mo_boss5",
            name = "Soul Hunters (Council)",
            group = "Boss 5",
            keybind = 5,
            strategy = {
                tank = {
                    "Fracture: Clear Shattered Souls ASAP",
                    "Eye Beam: Face away, swap after"
                },
                healer = {
                    "Spirit Bomb = Heavy absorb/damage",
                    "Dispel Devourer's Ire (Mobile players)"
                },
                all = {
                    "Kill ALL 3 bosses simultaneously",
                    "The Hunt: Split soak (Move to melee)",
                    "Intermissions: Avoid center (Event Horizon)"
                }
            }
        },
        
        -- =================================
        -- BOSS 6: FRACTILLUS
        -- =================================
        {
            id = "mo_boss6",
            name = "Fractillus",
            group = "Boss 6",
            keybind = 6,
            strategy = {
                tank = {
                    "Shockwave Slam spawns wall (Swap)",
                    "Watch arrow for spawn location"
                },
                all = {
                    "Designate 1 SAFE LANE (No walls)",
                    "Max 5 walls per lane (6 = Fatal)",
                    "Shattershell: Break walls in crowded lanes"
                }
            }
        },
        
        -- =================================
        -- BOSS 7: NEXUS-KING SALHADAAR
        -- =================================
        {
            id = "mo_boss7",
            name = "Nexus-King Salhadaar",
            group = "Boss 7",
            keybind = 7,
            strategy = {
                tank = {
                    "P1: Swap Conquer (Soak) / Vanquish (Solo)",
                    "P3: Swap after Galactic/Starkiller hit"
                },
                all = {
                    "P1: Clear Oath-Bound stacks via Conquer",
                    "P2: Dragon Breath -> Group at edge -> Portal",
                    "P3: Destroy Dark Stars with Boss Attacks"
                }
            }
        },
        
        -- =================================
        -- BOSS 8: DIMENSIUS (Placeholder)
        -- =================================
        {
            id = "mo_boss8",
            name = "Dimensius the All-Devouring",
            group = "Boss 8",
            keybind = 8,
            strategy = {
                all = {
                    "Strategy data not yet available.",
                    "Check back later!"
                }
            }
        }
    }
}
