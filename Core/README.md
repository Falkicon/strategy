# Core Module Architecture

This folder contains the core functionality of the Strategy addon, organized into specialized modules for maintainability and clear separation of concerns.

> **Strategy 2.0 Note**: The architecture has been redesigned for Midnight (WoW 12.0) API compatibility. Target/mouseover detection has been replaced with an instance-based Strategy Panel where players click buttons or use keybinds to announce strategies.

## Module Overview

### 🎯 **Core.lua**

#### Primary Coordinator & Event Handler

The main addon entry point that coordinates all other modules and handles WoW events.

#### Key Responsibilities

- Addon initialization and module loading
- Slash command processing (`/ff`, `/Strategy`)
- Event handling (ADDON_LOADED, PLAYER_ENTERING_WORLD, ZONE_CHANGED_NEW_AREA)
- Module delegation coordination
- Utility functions (role parsing, debug logging)
- Tank validation and instance checking

#### Key Functions

- `OnInitialize()` - Sets up all modules and databases
- `SlashCommand(input)` - Processes all user commands
- `OnEvent(event, ...)` - Handles WoW game events
- Delegation functions that route calls to appropriate modules

---

### 📋 **StrategyPanel.lua** _(NEW in 2.0)_

#### Strategy Panel UI Component

The main user interface for Strategy 2.0, displaying all strategies for the current instance.

**Key Responsibilities:**

- Strategy panel creation and lifecycle management
- Button grid for strategy announcements
- Keybind indicator display on buttons
- Announced tracking visual feedback (dimming)
- Collapsible group headers
- Preview tooltips on hover

**Key Functions:**

- `CreatePanel(addon)` - Builds the strategy panel frame
- `ShowPanel(addon)` - Shows the panel (with optional animation)
- `HidePanel(addon)` - Hides the panel
- `UpdateStrategies(addon, strategies)` - Populates panel with instance strategies
- `MarkAnnounced(strategyId)` - Dims a strategy button after announcing
- `ResetAnnounced()` - Clears all announced tracking

**Usage Example:**

```lua
-- Show the strategy panel
self.StrategyPanel:ShowPanel(self)

-- Mark a strategy as announced
self.StrategyPanel:MarkAnnounced("boss1")
```

---

### ⌨️ **KeybindManager.lua** _(NEW in 2.0)_

#### Keybind Registration & Handling

Manages keybind registration for quick strategy announcements.

**Key Responsibilities:**

- Keybind registration with WoW's binding system
- Modifier key support (Shift, Ctrl, Alt)
- Focus mode vs Always mode handling
- Custom keybind assignments

**Key Functions:**

- `RegisterKeybinds(addon)` - Sets up default keybinds (1-0)
- `UnregisterKeybinds(addon)` - Removes keybinds when panel hidden
- `OnKeybindPressed(keyNumber, addon)` - Handles keybind press events
- `SetModifierMode(modifier)` - Configures modifier key requirement

**Keybind Modes:**

- **Focus Mode**: Keybinds only work when Strategy Panel has focus
- **Modifier Mode**: Hold Shift/Ctrl/Alt + number to announce
- **Always Mode**: Number keys always trigger (may conflict with action bars)

---

### 🏰 **InstanceDetector.lua** _(NEW in 2.0)_

#### Instance Detection & Data Loading

Detects current instance and loads appropriate strategy data.

**Key Responsibilities:**

- Instance detection via `GetInstanceInfo()`
- Strategy data loading for current instance
- Auto-show/hide of Strategy Panel
- Zone change event handling

**Key Functions:**

- `GetCurrentInstance()` - Returns current instance info (name, ID, type)
- `LoadInstanceStrategies(instanceID)` - Loads strategies for instance
- `IsSupported(instanceID)` - Checks if instance has strategy data
- `OnZoneChanged(addon)` - Handles zone change events

**Usage Example:**

```lua
-- Check if current instance is supported
local instanceID = self.InstanceDetector:GetCurrentInstance()
if self.InstanceDetector:IsSupported(instanceID) then
    local strategies = self.InstanceDetector:LoadInstanceStrategies(instanceID)
    self.StrategyPanel:UpdateStrategies(self, strategies)
end
```

---

### 🔧 **StrategyEngine.lua** (321 lines)

#### Strategy Formatting & Output Engine

Handles all strategy text formatting, role detection, and output to chat channels.

**Key Responsibilities:**

- Strategy text formatting and role-specific content
- Chat output with color coding and formatting
- Role header generation and parsing
- Active role detection from player spec/group
- Strategy content filtering by role

**Key Functions:**

- `FormatStrategy(bossName, bossData, addon)` - Formats strategy text for display
- `OutputStrategy(bossName, bossData, addon)` - Outputs formatted strategies to chat
- `GetRoleHeader(role)` - Returns colored role headers
- `GetActiveRoles(addon)` - Detects player's current roles
- `FilterAndFormatByRole()` - Role-specific strategy filtering

**Usage Example:**

```lua
-- Output a boss strategy to chat
self.StrategyEngine:OutputStrategy("Sikran", bossData, self)
```

---

### 🗃️ **DatabaseManager.lua**

#### Database Operations & Instance Data

Manages all database access, instance data loading, and strategy retrieval.

**Key Responsibilities:**

- Database loading and validation
- Instance data caching
- Strategy retrieval by ID
- Database status reporting

**Key Functions:**

- `LoadDatabase(instanceID)` - Loads database file for instance
- `GetStrategy(strategyId)` - Retrieves a specific strategy by ID
- `GetInstanceData(instanceID)` - Returns full instance data table
- `GetDatabaseStatus(addon)` - Reports loaded data status

**Usage Example:**

```lua
-- Load strategies for current instance
local instanceData = self.DatabaseManager:LoadDatabase(2773) -- Operation: Floodgate
```

---

### ⚙️ **DefaultsManager.lua** (594 lines)

#### Configuration System & Settings UI

Comprehensive settings management with AceConfig integration and profile support.

**Key Responsibilities:**

- Default configuration templates
- AceConfig options table generation
- Settings UI creation and management
- LibDataBroker minimap icon integration
- Profile management (per-character settings)

**Key Functions:**

- `GetDefaults()` - Returns complete default settings structure
- `InitializeSettings(addon)` - Sets up AceDB and AceConfig
- `OpenSettings(addon)` - Opens the settings configuration UI
- `CreateMinimapIcon(addon)` - Creates LibDataBroker minimap integration

**Settings Categories:**

- **General**: Basic addon behavior and output preferences
- **Strategy Window**: Window appearance, fonts, positioning, content filtering
- **Advanced**: Debug mode, role filtering, instance validation
- **Profiles**: Character-specific configuration management

**Usage Example:**

```lua
-- Open the addon settings panel
self.DefaultsManager:OpenSettings(self)
```

---

### 🪟 **WindowManager.lua** (521 lines)

#### Strategy Window UI Management

Complete strategy window system with AceGUI integration for displaying strategies in a dedicated UI.

**Key Responsibilities:**

- Strategy window creation and lifecycle management
- Content rendering and updates
- Font and styling application
- Window positioning and persistence
- Boss strategy display formatting

**Key Functions:**

- `OpenStrategyWindow(addon)` - Creates or shows the strategy window
- `CreateStrategyWindow(addon)` - Builds the AceGUI window structure
- `UpdateStrategyWindowContent(addon)` - Refreshes window with current strategies
- `ApplyStrategyWindowFont(container, addon)` - Applies user font preferences
- `AddBossToStrategyWindow(bossName, bossData, addon)` - Adds formatted boss strategies

**Window Features:**

- Clean, borderless design with custom styling
- Scrollable content with dynamic resizing
- Persistent positioning across sessions
- Font customization support
- Real-time content updates when bosses are encountered

**Usage Example:**

```lua
-- Open the strategy window for current zone
self.WindowManager:OpenStrategyWindow(self)
```

---

## Module Integration Pattern

All modules follow a consistent integration pattern:

### 1. **Module Loading** (in Core.lua OnInitialize)

```lua
function Strategy:OnInitialize()
    -- Load specialized modules
    self.StrategyEngine = Strategy_StrategyEngine
    self.DatabaseManager = Strategy_DatabaseManager
    self.DefaultsManager = Strategy_DefaultsManager
    self.StrategyPanel = Strategy_StrategyPanel      -- NEW in 2.0
    self.KeybindManager = Strategy_KeybindManager    -- NEW in 2.0
    self.InstanceDetector = Strategy_InstanceDetector -- NEW in 2.0

    -- Initialize each module with addon reference
    self.StrategyEngine:SetAddon(self)
    self.DatabaseManager:SetAddon(self)
    self.DefaultsManager:SetAddon(self)
    self.StrategyPanel:SetAddon(self)
    self.KeybindManager:SetAddon(self)
    self.InstanceDetector:SetAddon(self)
end
```

### 2. **Delegation Pattern** (Core.lua delegates to modules)

```lua
-- Core.lua provides clean API that delegates to appropriate module
function Strategy:AnnounceStrategy(strategyId)
    local strategy = self.DatabaseManager:GetStrategy(strategyId)
    if strategy then
        self.StrategyEngine:OutputStrategy(strategy.name, strategy, self)
        self.StrategyPanel:MarkAnnounced(strategyId)
    end
end

function Strategy:ShowPanel()
    return self.StrategyPanel:ShowPanel(self)
end
```

### 3. **Module Communication**

- All modules receive the main addon reference via `SetAddon(addon)`
- Modules can access other modules through the main addon: `addon.DatabaseManager`
- Cross-module communication goes through the main addon for consistency

## File Loading Order

The TOC file loads modules in dependency order:

```lua
-- Core\StrategyEngine.lua
-- Core\DatabaseManager.lua
-- Core\DefaultsManager.lua
-- Core\InstanceDetector.lua   -- NEW in 2.0
-- Core\StrategyPanel.lua      -- NEW in 2.0
-- Core\KeybindManager.lua     -- NEW in 2.0
-- Core\Core.lua               -- Main coordinator loads last
```

## Modules Removed in 2.0

### ~~WindowManager.lua~~ → Replaced by StrategyPanel.lua

The old WindowManager handled the Strategy Window (popup display). The new StrategyPanel provides a dedicated panel with button-based interaction.

### ~~Events.lua~~ → Merged into Core.lua / InstanceDetector.lua

Target and mouseover event handlers have been removed. Zone change events moved to InstanceDetector.

## Development Benefits

This modular architecture provides:

- ✅ **Midnight Compatibility**: No blocked API calls (`UnitName`, `UnitGUID`)
- ✅ **Separation of Concerns**: Each module has a single, well-defined responsibility
- ✅ **Maintainability**: Changes to one system don't affect others
- ✅ **Testability**: Individual modules can be tested in isolation
- ✅ **Extensibility**: New features can be added as new modules
- ✅ **Code Reuse**: Modules can be reused across different parts of the addon
- ✅ **Clear Interfaces**: Well-defined API boundaries between modules

## Refactoring History

**v1.0**: Single monolithic `Core.lua` file (1,741 lines) → 5 focused modules
**v2.0**: Midnight compatibility refactor → 3 new modules (StrategyPanel, KeybindManager, InstanceDetector), removed WindowManager and Events.lua

This refactoring transformed a target-detection addon into a button-based strategy panel that works within Midnight's API restrictions.
