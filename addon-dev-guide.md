**The Modern Developer's Guide to Creating High-Quality World of Warcraft Addons**

**Part I: Foundations of Addon Development**

Developing addons for World of Warcraft is a process of extending and customizing an already complex software ecosystem. Success requires not only a grasp of the Lua programming language but also a deep understanding of the game's unique API, file structure, and event-driven architecture. This part of the guide establishes the essential groundwork, ensuring a developer begins with the right tools, a solid understanding of the addon file structure, and a firm grasp of the fundamental programming model that underpins all WoW addons.

**Section 1: Assembling Your Development Toolkit**

While it is technically possible to write an addon using a simple text editor like Notepad, creating high-quality, maintainable projects demands a professional development environment. A well-configured toolchain enhances productivity, reduces errors, and provides critical insights into the game's inner workings.

**1.1. Choosing Your Integrated Development Environment (IDE)**

The choice of a primary coding environment is a foundational one, with options ranging from lightweight, highly customizable text editors to fully integrated, WoW-specific development suites. This decision often reflects a trade-off between granular control and out-of-the-box convenience. A developer who sets up a lightweight editor manually gains a deeper understanding of the components that make an addon work, while a developer using an integrated suite can become productive more quickly by leveraging automation.

**The Lightweight Path (VS Code, Sublime Text)**

This approach is ideal for developers who prefer a minimalist setup they can tailor to their exact needs. It involves augmenting a powerful text editor with specialized extensions that provide support for the Lua language and the World of Warcraft API.

-   **Visual Studio Code (VS Code) Setup:** VS Code has become a popular choice due to its extensive library of extensions. A proper setup involves installing the base editor and then adding extensions that provide syntax highlighting, code completion (IntelliSense), and file-specific support. Key extensions include:
    -   **Ketho's WoW API:** Provides comprehensive IntelliSense for the WoW Lua API, parsing documentation from both official Blizzard sources and the Warcraft Wiki.
    -   **Septh's WoW Bundle:** A collection of tools that enhance the development experience.
    -   **Stanzilla's WoW TOC:** Offers syntax highlighting and validation for .toc files, helping to prevent common loading errors.
-   **Sublime Text Setup:** Another powerful and lightweight option, Sublime Text can be configured for WoW development through its package manager, "Package Control". The essential steps include:
    -   Installing **Package Control** to manage extensions.
    -   Using Package Control to install the **"Lua Dev"** package, which provides syntax highlighting and build commands (e.g., pressing F7 to check Lua syntax).

**The Integrated Path (AddOn Studio for WoW)**

For developers seeking an all-in-one solution, AddOn Studio for World of Warcraft is a fully-featured IDE built upon the Microsoft Visual Studio Shell. It is designed specifically for WoW addon creation and offers numerous advantages:

-   **Advanced Code Editing:** Includes a powerful Lua editor with built-in IntelliSense for WoW functions and events, code snippets, and navigation features.
-   **Visual UI Designer:** Allows developers to design UI layouts visually, which can be a significant time-saver for complex interfaces. It also permits switching between the visual designer and the raw XML editor, providing a useful way to learn the FrameXML structure.
-   **Project Management:** Features project-based file management and can automatically generate and maintain the addon's .toc file, removing a common source of manual error.
-   **Deployment:** Supports one-click deployment of the addon files to the correct World of Warcraft directory.

It is critical to note that AddOn Studio has specific version requirements for its underlying Visual Studio installation. For example, AddOn Studio 2022 has been known to have bugs with certain recent versions of Visual Studio 2022, requiring developers to install a specific Long-Term Servicing Channel (LTSC) version or revert to an older release.

| Development Environment    | Pros                                                                                                                | Cons                                                                                                                             | Best For...                                                                                                    |
|----------------------------|---------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| **Simple Text Editor**     | No setup required; maximum simplicity.                                                                              | No syntax highlighting, no code completion, no debugging tools.                                                                  | Quick, minor edits to existing files. Not recommended for new projects.                                        |
| **VS Code / Sublime Text** | Highly customizable; large ecosystem of extensions; low resource usage; forces understanding of addon structure.    | Requires manual setup and configuration; deployment is a manual process.                                                         | Developers who want full control over their toolchain and a deeper understanding of the build process.         |
| **AddOn Studio for WoW**   | All-in-one solution; visual UI designer; automatic .toc generation; one-click deployment; built-in WoW API support. | Higher resource usage; can have strict Visual Studio version dependencies; may obscure underlying mechanics from new developers. | Developers who want maximum productivity, especially for UI-heavy addons, and prefer an integrated experience. |

Export to Sheets

**1.2. Essential In-Game Development Tools**

Effective development and debugging are not confined to the IDE. Several in-game addons are indispensable for capturing errors and inspecting the live game state.

-   **Error Reporting:** By default, the WoW client suppresses most Lua errors generated by addons to avoid interrupting gameplay. For a developer, this is counterproductive. Addons like **BugSack** and **BugGrabber** are essential as they capture these hidden errors and display them in an in-game window, complete with stack traces, making it possible to identify and fix bugs.
-   **API Introspection and Debugging:** While print() statements are a basic form of debugging, more advanced tools provide a far richer view of the addon's runtime state. **DevTool** is a powerful multipurpose tool that acts like an in-game debugger. It allows developers to visually inspect the contents of tables, trace game events in real-time, and log function calls and their return values. This is vastly superior to cluttering the chat window with debug messages and is a critical tool for understanding complex data structures and event sequences.

**1.3. The Ultimate Reference: Extracting Blizzard's UI Source**

While online wikis are invaluable, the ultimate source of truth for the WoW API is Blizzard's own UI source code. The game client provides a mechanism to export all of the default interface's Lua and XML files to a local folder for inspection.

-   **Procedure:** To perform the export, the developer console must be enabled. This can be done by adding the -console flag in the game's launch options or, on a Mac, by creating a commandline.txt file with that content in the game directory. Once in-game (typically at the character select screen to avoid issues), the console can be opened with the tilde (

\~) or backtick (\`) key. Typing the command exportInterfaceFiles code will freeze the client for a few moments and create a BlizzardInterfaceCode folder inside the main WoW directory.

-   **Significance:** This local copy of the UI source is the definitive reference. It allows a developer to see exactly how Blizzard implements its own UI frames, handles events, and uses the API. It often reveals undocumented functions, arguments, or behaviors that are not present in public documentation. When an online resource is ambiguous or outdated, consulting the source code provides the correct answer.

**Section 2: The Anatomy of an Addon: Core File Structure**

Every World of Warcraft addon, from a simple "Hello World" to a complete UI overhaul, is built upon a foundation of three core file types. Understanding the distinct role of each file, particularly the manifest-like .toc file, is the first step in building a functional addon.

**2.1. The Three Pillars:.toc,.lua, and.xml**

An addon is fundamentally a directory placed within the World of Warcraft/_retail_/Interface/AddOns/ folder. For the game to recognize this directory as an addon, it must contain at least one specially named file: the Table of Contents, or .toc file.

-   **.toc (Table of Contents):** This is the addon's manifest and is the only file the WoW client actively looks for when scanning for new addons. It is a mandatory plain text file that must have the exact same name as the folder it resides in (e.g., MyAddon\\MyAddon.toc). Its primary roles are to declare metadata about the addon and to list, in order, all other script and layout files that the client should load.
-   **.lua (Lua Script):** This is where the addon's logic resides. Lua is the scripting language used for all WoW addons, and these files contain the functions, event handlers, and algorithms that define what the addon does.
-   **.xml (Extensible Markup Language):** The WoW user interface is built upon a system of widgets called Frames. XML files provide a declarative way to define the structure, appearance, and hierarchy of these Frames, much like how HTML is used to structure web pages. While UI can be created entirely in Lua, XML is often used for defining static layouts and templates.

**2.2. Mastering the.toc File**

The .toc file has evolved from a simple file list into a sophisticated manifest that enables developers to manage complex addons that can support multiple versions of the game from a single codebase. This evolution was a direct response to developer needs that arose with the introduction of WoW Classic, which required authors to maintain separate versions of their addons. Blizzard first supported client-specific .toc files and later introduced more flexible in-line conditional loading, streamlining the development process.

-   **Metadata Tags (\#\#):** Lines beginning with \#\# are directives that provide metadata to the game client. These are essential for the addon to be correctly identified and loaded.

| Directive                       | Example                                        | Purpose                                                                                                                                                                                                                                                                                                         |
|---------------------------------|------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| \#\# Interface                  | \#\# Interface: 110200                         | **Crucial.** Specifies the game client version the addon was designed for. An incorrect value will cause the addon to be marked as "out of date." The current version can be found in-game via /dump select(4, GetBuildInfo()). Multiple versions can be listed, separated by commas, for multi-client support. |
| \#\# Title                      | \#\# Title: My Awesome Addon                   | The name of the addon as it appears in the in-game addon list.                                                                                                                                                                                                                                                  |
| \#\# Author                     | \#\# Author: Jane Doe                          | The name of the addon's creator.                                                                                                                                                                                                                                                                                |
| \#\# Notes                      | \#\# Notes: Displays a custom unit frame.      | A short description of the addon's function.                                                                                                                                                                                                                                                                    |
| \#\# Version                    | \#\# Version: 1.2.3                            | The addon's version number, displayed in the addon list.                                                                                                                                                                                                                                                        |
| \#\# SavedVariables             | \#\# SavedVariables: MyAddonDB                 | Declares a global Lua variable that the client should save on logout and restore on login for account-wide data persistence.                                                                                                                                                                                    |
| \#\# SavedVariablesPerCharacter | \#\# SavedVariablesPerCharacter: MyAddonCharDB | Same as SavedVariables, but data is saved on a per-character basis.                                                                                                                                                                                                                                             |
| \#\# Dependencies               | \#\# Dependencies: Details                     | Specifies that another addon must be loaded before this one. The addon will be disabled if the dependency is missing or disabled.                                                                                                                                                                               |

-   **File Loading Order:** Any line in the .toc file that is not a comment (\#) or a metadata tag (\#\#) is treated as a path to a file that should be loaded. The client loads these files sequentially, from top to bottom. This order is critical. For example, if

Core.lua defines functions that are used in Options.lua, then Core.lua *must* be listed before Options.lua in the .toc file.

-   **Modern .toc Features (Conditional Loading):** To support multiple game clients (Retail, Classic, etc.) from a single addon folder, the .toc format includes directives for conditional loading.
    -   **Client-Specific TOCs:** An older method involves shipping multiple .toc files, such as MyAddon.toc (for retail) and MyAddon_Classic.toc (for Classic). The client will automatically load the most specific .toc file available for its version. While functional, this can lead to duplicated metadata.
    -   **In-line Conditionals:** A more modern and flexible approach is to use conditional directives within a single .toc file. This allows specific files to be loaded only for certain game versions or client languages. For example:

Code snippet

\#\# Interface: 110200, 11507

\# Core files, loaded for all clients

Libs\\LibStub\\LibStub.lua

Core.lua

\# Retail-only features

RetailFeatures.lua

\# Classic-only features

ClassicFeatures.lua

\# English localization

Locales\\enUS.lua

\# German localization

Locales\\deDE.lua

-   This structure allows a developer to maintain a single, clean addon package that intelligently loads the correct files for the user's environment, a best practice for modern addon development.

**Section 3: The Event-Driven World**

The entire World of Warcraft addon ecosystem operates on an event-driven programming model. An addon's code is not a continuously running process; rather, it lies dormant until the game client fires an event, at which point the addon's registered functions execute in response. Understanding this paradigm is fundamental to creating any functional addon.

**3.1. The Heartbeat of WoW: The Event Loop**

The game client constantly generates events to signal that something has happened. These events can be related to combat (UNIT_HEALTH, COMBAT_LOG_EVENT_UNFILTERED), player actions (PLAYER_ENTERING_WORLD, LOOT_OPENED), UI interactions, and hundreds of other occurrences. An addon's purpose is to "listen" for these events and execute code when they fire.

**3.2. Creating an Event Listener**

A surprising and crucial design principle of the WoW API is that the fundamental unit for both UI and logic is the Frame widget. There is no separation between the UI object model and the event-handling system. This means that any addon, even one with no visible interface, must create a Frame object to serve as its event listener.

Lua

\-- Create a non-visual frame to handle our addon's events.

\-- The frame needs no name and has no parent, so it will be hidden and exist only in memory.

local eventFrame = CreateFrame("Frame")

This simple line is the starting point for most addons. The eventFrame object now exists and can be configured to listen for events.

**3.3. Registering and Handling Events**

The process of listening for an event involves two steps: registering interest in the event and providing a function (a callback) to execute when the event occurs.

-   **Registering:** The frame:RegisterEvent("EVENT_NAME") method tells the client that this frame is interested in a particular event. A single frame can be registered for many different events. For events that are specific to a game unit (like the player, target, or party members), it is more efficient to use

frame:RegisterUnitEvent("EVENT_NAME", "unitToken"), as this will prevent the event handler from firing unnecessarily for other units.

-   **Handling:** The frame:SetScript("OnEvent", handlerFunction) method assigns a function to be the frame's event handler. This function will be called every time *any* of the events the frame is registered for are fired by the client. The handler function always receives

self (a reference to the frame itself) and event (the name of the event that fired) as its first two arguments. Any additional arguments are specific to the event and are passed after.

A complete, simple example would look like this:

Lua

\-- 1. Create a frame to act as the event listener.

local myAddonFrame = CreateFrame("Frame")

\-- 2. Define the function that will handle the events.

local function OnEventHandler(self, event,...)

\-- The '...' captures all additional arguments passed by the event.

if event == "PLAYER_LEVEL_UP" then

\-- The PLAYER_LEVEL_UP event passes the new level as the first argument.

local newLevel =...

print("Congratulations on reaching level ".. newLevel.. "!")

elseif event == "PLAYER_REGEN_DISABLED" then

\-- This event signals entering combat.

print("Entering combat!")

end

end

\-- 3. Register the frame for the events we care about.

myAddonFrame:RegisterEvent("PLAYER_LEVEL_UP")

myAddonFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

\-- 4. Set the handler function for the frame's "OnEvent" script.

myAddonFrame:SetScript("OnEvent", OnEventHandler)

**3.4. Debugging Events**

Discovering the correct event name for a specific in-game action can be challenging. The client provides a built-in event tracing tool that is invaluable for this purpose. By typing the slash command /etrace into the chat window, a developer can open the Event Trace window, which displays a live, scrolling log of all events being fired by the game, along with their arguments. This allows a developer to perform an action in the game (e.g., open their bags) and see exactly which event (BAG_OPENED) was fired as a result.

**Part II: Building Functionality and User Interface**

With a solid understanding of the foundational components, the next stage of addon development involves creating tangible functionality. This includes building the visual elements that users will interact with, implementing systems to save data and settings between play sessions, and providing intuitive configuration panels within the game's options menu.

**Section 4: Crafting the User Interface**

The visual component of an addon is constructed from a hierarchy of widgets. While the traditional method for defining these layouts is XML, the modern best practice has shifted towards programmatic creation in Lua. This trend is driven by the desire for better debugging capabilities and finer control over the global namespace, as XML can automatically create global variables for named frames, leading to potential conflicts and hard-to-trace bugs.

**4.1. The Building Blocks: Frames, Textures, and FontStrings**

The WoW UI is built from a few fundamental object types that are combined to create complex interfaces:

-   **Frames (Frame):** The primary container widget. All other UI elements are children of a frame. Frames can be nested within other frames to create structured layouts. They are also the objects responsible for handling events, as detailed previously.
-   **Textures (Texture):** A region used to display an image. This can be an icon from the game files, a custom .tga or .blp file included with the addon, or just a solid color.
-   **FontStrings (FontString):** A region used to display text with a specific font, size, and color.

**4.2. Programmatic UI Creation in Lua**

Creating UI elements directly in Lua offers the most flexibility and is considered the modern best practice for its clarity and debuggability.

-   **Instantiation:** Objects are created dynamically using a set of API functions. CreateFrame() is used to make a new frame, while child elements are created using methods on the parent frame, such as frame:CreateTexture() and frame:CreateFontString().
-   **Positioning and Sizing:** The layout of UI elements is controlled through a powerful anchor system using the object:SetPoint() method. This method anchors a point on one object (e.g., "TOPLEFT") to a point on another object (e.g., "TOPRIGHT"), with optional offsets. object:SetSize() sets explicit dimensions, and object:SetAllPoints() is a convenient shorthand to make an object fill its parent completely.
-   **Layering:** The stacking order of elements is controlled by two properties: frameStrata and frameLevel.
    -   frameStrata: A broad layer for the frame, such as BACKGROUND, LOW, MEDIUM, HIGH, or DIALOG. A frame in a higher strata will always appear above a frame in a lower strata.
    -   frameLevel: A numeric value that determines the stacking order of frames *within the same strata*. A higher frameLevel appears on top.

The following Lua code creates a simple, visible frame with a border and text:

Lua

\-- Create a main frame, parented to the default UI's main screen (UIParent)

local myFrame = CreateFrame("Frame", "MyAddonFrame", UIParent)

myFrame:SetSize(200, 80)

myFrame:SetPoint("CENTER", 0, 0)

\-- Set a backdrop with a background color and border

myFrame:SetBackdrop({

bgFile = "Interface/DialogFrame/UI-DialogBox-Background",

edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",

tile = true, tileSize = 32, edgeSize = 32,

insets = { left = 11, right = 12, top = 12, bottom = 11 }

})

myFrame:SetBackdropColor(0, 0, 0, 0.8)

\-- Create a text element as a child of the frame

local myText = myFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

myText:SetPoint("CENTER")

myText:SetText("Hello, World!")

**4.3. Declarative UI Layout with XML**

XML provides a way to define UI layouts statically. While less flexible than pure Lua, it excels at creating templates that can be reused.

-   **Structure:** An XML file defines a hierarchy of frames and their children using tags like \<Frame\>, \<Size\>, \<Anchors\>, and \<Layers\>.
-   **Templates and Inheritance:** A key feature of XML is the ability to define a virtual="true" frame. This frame is not created in the game world but serves as a template. Other frames can then use inherits="MyTemplateName" to inherit all the properties of the template, reducing code duplication.
-   **Script Handlers:** Lua code can be embedded directly into the XML within a \<Scripts\> block, with tags for different handlers like \<OnLoad\> or \<OnClick\>.

**4.4. Secure Templates for Protected Actions**

To prevent automation, the WoW API restricts certain "protected" actions, such as casting spells, targeting units, or using items. These actions can only be initiated by a direct hardware event (a physical mouse click or key press) on a "secure" frame. Addons cannot call these functions directly from normal event handlers.

To perform these actions, an addon must use a special **Secure Template**. This involves:

1.  Creating a frame (typically a Button) that inherits a Blizzard-provided secure template, such as SecureUnitButtonTemplate.
2.  Configuring the button's behavior out of combat using the frame:SetAttribute("attributeName", value) method. For example, myButton:SetAttribute("type1", "target") would configure the left-click action to target the button's unit.
3.  The secure template contains its own protected OnClick handler that reads these attributes and executes the corresponding protected action in a secure environment, bypassing the taint system.

**Section 5: Data Persistence with SavedVariables**

To create a useful and configurable addon, it is essential to store data and user settings between game sessions. World of Warcraft provides a built-in system called SavedVariables for this purpose, which automatically handles saving and loading designated Lua tables to files in the user's WTF (Warcraft Text File) directory.

**5.1. The SavedVariables System**

-   **Mechanism:** The system works by serializing specified global Lua tables into a .lua file when the user logs out, exits the game, or executes a /reload command. The client has sole control over when this save operation occurs; it cannot be triggered manually by the addon. When the game launches and the addon is loaded, the client automatically deserializes this file, repopulating the global variables with their saved values.
-   **Declaration:** For the client to recognize which variables to manage, they must be explicitly declared in the addon's .toc file using one of two directives :
    -   \#\# SavedVariables: MyAddonGlobalDB: This directive is for data that should be saved on an account-wide basis, accessible to all characters on that account.
    -   \#\# SavedVariablesPerCharacter: MyAddonCharacterDB: This directive is for data that is specific to each character.

**5.2. Best Practices for Managing Saved Data**

The SavedVariables system is straightforward but has a critical timing-related nuance that can cause bugs if not handled correctly. A common mistake for new developers is attempting to access saved data immediately when their Lua file is loaded. However, the data is not yet available at that point. The client loads the addon's files first, then populates the saved variables, and finally fires the ADDON_LOADED event. This sequence means that any code relying on saved settings must be deferred until the ADDON_LOADED event fires.

-   **Use a Single Root Table:** To avoid polluting the global namespace and to simplify data management, it is strongly recommended to declare only one global table per scope (account or character) and store all settings and data as keys within that table. This makes the code cleaner and easier to maintain.

Code snippet

\#\# Interface: 110200

\#\# Title: My Addon

\#\# SavedVariables: MyAddonDB

MyAddon.lua

-   **Initializing Defaults:** The first time a user runs an addon, its saved variable table will be nil. The addon must handle this case gracefully by creating a default set of options. A robust pattern involves defining a defaults table and merging it with the loaded saved variables. This also ensures that when the addon is updated with new settings, they are seamlessly added for existing users.

Lua

\-- MyAddon.lua

local addonName, MyAddon =... -- Addon namespace

\-- Define default settings

local defaults = {

profile = {

enabled = true,

showAlerts = true,

framePosition = { "CENTER", 0, 200 }

}

}

local function OnAddonLoaded(self, event, addon)

if addon == addonName then

\-- Initialize the database by merging defaults with saved data

MyAddonDB = MyAddonDB or {} -- If MyAddonDB is nil, create an empty table

\-- A proper implementation would use a deep copy/merge function here

\-- For simplicity, we'll just check one value

if MyAddonDB.profile == nil then

MyAddonDB.profile = defaults.profile

end

\-- Now it is safe to access MyAddonDB

if MyAddonDB.profile.enabled then

MyAddon:EnableFeatures()

end

\-- Unregister the event handler once initialization is complete

self:UnregisterEvent("ADDON_LOADED")

end

end

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", OnAddonLoaded)

This structure ensures that code accessing MyAddonDB only runs after the data has been loaded by the client, preventing common initialization errors.

**Section 6: Creating User Configuration Panels**

A high-quality addon should allow users to customize its behavior. The standard way to do this is by adding a configuration panel to the game's built-in Interface Options menu (accessible via Escape -\> Options -\> AddOns). Developers can choose between creating this panel using the native WoW API or leveraging powerful libraries like Ace3, which greatly simplify the process. This choice often represents a "build vs. buy" decision, where the native approach offers full control at the cost of significant boilerplate code, while libraries offer rapid development in exchange for a dependency and adherence to their specific API.

**6.1. The Native Approach: InterfaceOptions_AddCategory**

Creating an options panel natively involves building a standard Frame widget and then registering it with the interface options system.

1.  **Create the Panel Frame:** A main Frame is created to act as the container for all the option controls. Its .name property is important, as this is the text that will appear in the addon list on the left side of the options window.
2.  **Add Widgets:** Standard UI widgets like checkboxes (CheckButton), sliders (Slider), and dropdowns are created as children of the panel frame. Their

OnClick or OnValueChanged scripts are then used to update the addon's SavedVariables table.

1.  **Register the Panel:** The final step is to call InterfaceOptions_AddCategory(panel). This function registers the frame with the system, making it appear in the addon list.

**6.2. Building a Scrollable Options Panel**

For addons with more than a few options, a scrollable panel is necessary to prevent the content from overflowing. This requires a specific three-frame hierarchy :

1.  **The Main Panel:** The frame registered with InterfaceOptions_AddCategory.
2.  **The ScrollFrame:** A child of the main panel, created from the UIPanelScrollFrameTemplate. This provides the visible scrollbar and viewport.
3.  **The ScrollChild:** A frame designated as the scrollable content via scrollFrame:SetScrollChild(scrollChild). All option widgets are made children of this frame. The scrollChild's height will expand automatically as content is added, and the ScrollFrame will activate its scrollbar as needed.

**6.3. Using Libraries for Simplicity (The Ace3 Framework)**

For all but the simplest addons, manually creating an options panel is tedious and error-prone. The **Ace3** library suite, specifically its **AceConfig-3.0** module, provides a far more efficient, data-driven approach.

Instead of creating frames and widgets in Lua, the developer defines the entire options structure within a Lua table. This "options table" describes the type of control (e.g., checkbox, slider, dropdown), its label, its description, and the functions to get and set the corresponding value in the SavedVariables. AceConfig then parses this table and automatically generates the entire interactive UI panel.

This approach has several major advantages:

-   **Reduced Boilerplate:** It eliminates dozens or even hundreds of lines of manual UI creation code.
-   **Maintainability:** Adding, removing, or changing an option is as simple as modifying a few lines in the options table.
-   **Rich Features:** AceConfig provides advanced features like profiles, sub-menus, and more, with no extra implementation effort.
-   **Efficiency:** Ace3 is a shared library. If multiple addons used by a player depend on it, the library code is only loaded into memory once, potentially reducing the overall memory footprint compared to each addon implementing its own options panel code.

For any addon with more than a handful of settings, using a library like AceConfig is a definitive best practice that saves significant development time and results in a more robust and user-friendly product.

**Part III: Advanced Topics and Best Practices**

Moving beyond the fundamentals of functionality and UI, this section addresses the principles that elevate an addon from merely functional to truly high-quality. These include a deep understanding of performance optimization, the ability to navigate the complex taint system to ensure stability, and adherence to best practices for code organization and localization that result in a maintainable and globally accessible product.

**Section 7: Writing Performant Code: CPU vs. Memory**

A common misconception within the player community is that addons with high memory usage are the cause of poor in-game performance. On modern computer systems, this is almost universally false. The primary bottleneck and the true cause of lag, stuttering, and reduced frames-per-second (FPS) is an addon's **CPU usage**.

**7.1. The Performance Myth: Memory is Not the Enemy**

All addon Lua code executes on the game's main client thread. This work must be completed *between* the rendering of each frame. Therefore, the more time the CPU spends executing addon code, the less time it has to render the next frame, directly lowering the player's FPS. A target of 60 FPS means the game has only 16.67 milliseconds (

1000ms÷60) for *all* processing, including game logic, rendering, and addon execution. An addon that consistently uses 5ms of CPU time per frame is consuming nearly a third of this budget, making high frame rates impossible.

In contrast, memory usage is largely irrelevant unless it is so excessive that it exhausts the system's available RAM. In fact, well-designed addons often intentionally use more memory to cache data, which reduces the need for repeated, CPU-intensive calculations, thereby trading abundant memory for scarce CPU time.

**7.2. Profiling Your Addon's CPU Usage**

To optimize an addon, one must first measure its performance. Several tools exist for this purpose.

-   **Profiling Addons:** Tools like **AddonUsage** or **Addons CPU Usage** provide an in-game interface to monitor the CPU time consumed by each addon, typically measured in milliseconds per second. These tools are essential for identifying which addons, or which specific situations, are causing performance drops.
-   **Blizzard's Built-in Profiler:** Since patch 11.0, the game client includes its own addon profiler, which displays CPU usage in the addon list. While convenient, this profiler has known limitations: it does not always account for all CPU usage (e.g., code in WeakAuras can be "invisible"), and it can sometimes misattribute the CPU usage of a shared library to the wrong addon. Therefore, while it is a useful starting point, dedicated profiling addons often provide a more detailed and accurate picture.

**7.3. Key Optimization Techniques**

Most addon performance issues stem from a few common anti-patterns. Adhering to the following techniques can prevent the vast majority of performance problems.

-   **The OnUpdate Trap:** The OnUpdate script handler fires on every single frame, making it the most frequent and performance-sensitive code block in any addon. It is the number one cause of addon-related lag. The

OnUpdate handler should be used *only* for tasks that absolutely must be updated visually every frame, such as the position of a moving bar. All other logic should be moved to specific event handlers. For example, instead of checking a buff's status every frame in OnUpdate, the code should be placed in a UNIT_AURA event handler, which only fires when buffs or debuffs actually change.

-   **Localizing Globals (upvaluing):** In Lua, accessing a local variable is significantly faster than accessing a global one. In performance-critical code that is called frequently (like OnUpdate or a combat log event handler), any global functions or variables that are used multiple times should be aliased to a local variable at the top of the function or file. This practice is known as "upvaluing".

Lua

\-- Inefficient: Accesses the global 'print' function 10,000 times

function FrequentlyCalledFunction()

for i = 1, 10000 do

print("Hello")

end

end

\-- Efficient: The global 'print' is looked up only once.

local print = print -- Upvalue

function FrequentlyCalledFunction()

for i = 1, 10000 do

print("Hello") -- Accesses the faster local variable

end

end

-   **Efficient Event Handling:** An addon should only register for the events it absolutely needs. Using frame:RegisterAllEvents() is extremely wasteful and should be avoided. When dealing with unit-specific events, frame:RegisterUnitEvent("EVENT", "unit") is preferable to the generic frame:RegisterEvent("EVENT"), as it ensures the handler only fires for the specified unit (e.g., "player" or "target").
-   **Table Reuse:** Creating new tables is a relatively expensive operation in Lua. In functions that are called frequently, one should avoid creating and discarding "throw-away" tables inside the loop. If a temporary table is needed, it should be created once outside the loop and cleared and reused on each iteration to reduce the workload on Lua's garbage collector.

**Section 8: Understanding and Navigating Taint**

One of the most complex and often misunderstood aspects of WoW addon development is the "taint" system. It is not a bug, but rather a deliberate security feature designed to prevent addons from automating protected actions like casting spells or moving the player character. An addon that mishandles taint will cause the infamous "Interface action failed because of an AddOn" error, creating a frustrating experience for the user.

**8.1. What is Taint? A Secure Execution Model**

The WoW Lua environment operates in one of two states: **secure** or **insecure (tainted)**.

-   **Secure Execution:** When the game client is running its own code (from the default UI), the execution path is considered secure. In this state, it is allowed to call protected API functions.
-   **Tainted Execution:** As soon as the execution path interacts with any code or data from a user-created addon, it becomes tainted. A tainted execution path is forbidden from calling any protected function.

**8.2. The Flow of Taint**

Taint propagates virally throughout the Lua environment. Once introduced, it spreads easily:

-   If secure code calls a function defined by an addon, the execution path becomes tainted.
-   If secure code reads a value from a variable created by an addon, the execution path becomes tainted.
-   Any variable written to or function created during a tainted execution is itself tainted.

The introduction of the modern Edit Mode UI in Dragonflight has made taint propagation more unpredictable. The Edit Mode system can act as a "taint bridge," connecting disparate UI elements. An addon that taints a seemingly harmless frame can cause that taint to flow through the Edit Mode manager and contaminate core, protected elements like action bars, leading to errors that are very difficult to trace back to their source.

**8.3. Common Causes and Solutions**

Most taint issues arise from a few common programming errors.

-   **Improper Function Hooking:** This is the most frequent cause of taint. If an addon replaces a secure Blizzard function with its own function to add functionality (a "hook"), any time Blizzard's code calls that function, it will instead be running the addon's tainted code, tainting the entire call stack.
    -   **Solution: hooksecurefunc():** Blizzard provides a special function, hooksecurefunc(functionName, hookFunction), specifically to solve this problem. It registers a "post-hook" that runs *after* the original, secure function has completed. Crucially, the taint from the addon's hook function is contained and does not spread back to the original secure execution path, allowing for safe modification of Blizzard's UI flow.
-   **Insecure UI Handlers:** Attempting to call a protected function from a standard script handler like OnClick.
    -   **Solution: Secure Templates:** As described in Section 4.4, protected actions must be initiated through secure templates like SecureActionButtonTemplate. The desired action is defined via SetAttribute, which allows the secure template's protected code to execute the action safely.

**8.4. Debugging Taint**

Taint errors are notoriously difficult to debug because the error message often blames an innocent addon that happened to trigger the final protected function call, rather than the addon that was the original source of the taint. To find the true source, developers must use the taint log:

1.  Enable taint logging by executing /console taintLog 1 in the chat window.
2.  Reproduce the error in-game.
3.  Exit the game client.
4.  Navigate to the World of Warcraft/_retail_/Logs/ directory and open the taint.log file. This file will contain a detailed stack trace showing the exact sequence of function calls that led from the initial tainting action to the final blocked function call, allowing the developer to identify the root cause.

**Section 9: Best Practices for Robust Addons**

Beyond performance and stability, a high-quality addon is defined by its maintainability, clear organization, and consideration for a global player base.

**9.1. Code Organization and Structure**

-   **File Organization:** For any non-trivial addon, it is best practice to separate code into multiple files based on functionality (e.g., Core.lua, Config.lua, Frames.lua). This makes the codebase easier to navigate, understand, and maintain. These files are then listed in the correct loading order in the .toc file.
-   **Namespacing:** The Lua global environment is a shared space for all addons and the Blizzard UI. To prevent conflicts, an addon should avoid creating more than one or two global variables. The standard practice is to create a single global table for the addon (e.g., MyAddon = {}) and then assign all its functions and variables as keys on that table. All other variables within the files should be declared as local.

**9.2. Localization**

World of Warcraft is played in many languages. To ensure an addon is accessible to a global audience, all user-visible text strings should be localized.

-   **Abstracting Text:** Never hardcode English strings directly in the logic of the addon. Instead, create a localization table (commonly named L) and store all strings there. The code then references L["some_key"] instead of "Some Text".
-   **Locale Files:** Create separate Lua files for each language, such as Locales/enUS.lua and Locales/deDE.lua. Each file populates the same L table with the translated strings for that language. The .toc file can then use conditional loading (\`\`) to load only the file that matches the user's game client.
-   **Locale-Independent API Calls:** Many API functions can accept either a localized name or a language-independent ID (e.g., an item ID or spell ID). It is always best practice to use the ID-based version of the function, as this will work correctly regardless of the user's client language. For example,

GetItemInfo(2589) is robust, whereas GetItemInfo("Linen Cloth") will fail on a non-English client.

**9.3. Creating a Good User Experience**

The most successful addons are not only powerful but also intuitive and reliable.

-   **Intuitive Design:** The addon's purpose should be clear, and its configuration options should be easy to understand.
-   **Reliability and Compatibility:** Addons must be kept up-to-date with new game patches to ensure they remain compatible with API changes and do not cause errors.
-   **Minimal Intrusion:** An addon should respect the user's screen space and attention. Avoid overly large, flashy, or distracting elements unless they are core to the addon's functionality. Provide options to customize or disable visual components.
-   **Slash Commands:** Implementing slash commands (e.g., /myaddon config) provides a quick and convenient way for users to access the addon's options or perform common actions.

**Part IV: The Addon Lifecycle and Community**

Creating an addon is only the first step. The lifecycle of a successful project involves ongoing maintenance to keep pace with a constantly evolving game, engaging with the community for support and feedback, and utilizing established platforms for distribution.

**Section 10: Keeping Pace with a Living Game**

World of Warcraft receives major patches several times a year, and these patches frequently include changes to the Lua API. An addon that is not updated will quickly become outdated and may cease to function correctly. Staying current is a critical responsibility for any addon author.

**10.1. Summary of Recent Major API Changes (Patches 11.0.0 - 11.2.0)**

Recent patches for *The War Within* expansion have introduced significant and sometimes breaking changes that developers must be aware of.

| Patch               | Key Changes and Deprecations                                                                                          | Modern Replacement / Method                                                                                                                                                                                                      |
|---------------------|-----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **11.0.0**          | UIDropDownMenu framework is deprecated. GetMouseFocus() function replaced. Major overhaul of SpellBook API functions. | A completely new menuing system using DropdownButton and MenuUtil.CreateContextMenu. Use GetMouseFoci() which returns a table. Use new C_SpellBook and C_Spell namespaced functions.                                             |
| **11.1.5 / 11.1.7** | New TOC directives introduced. New namespaces for profiling and data encoding. New native table.create function.      | Use \#\# LoadSavedVariablesFirst for better data initialization. Utilize C_AddOnProfiler for performance measurement and C_EncodingUtil for data tasks. Use table.create for pre-allocating tables in performance-critical code. |
| **11.2.0**          | Global variables StaticPopup_DisplayedFrames and STATICPOPUP_NUMDIALOGS removed.                                      | Iterate over popups using the new StaticPopup_ForEachShownDialog function. Use new accessor methods for popup elements.                                                                                                          |

**10.2. Monitoring for Future Changes**

-   **Warcraft Wiki:** The most reliable and actively maintained resources for tracking API changes are the dedicated pages on the Warcraft Wiki. Each patch has its own page detailing every new, removed, and modified function, event, and CVar (e.g., warcraft.wiki.gg/wiki/Patch_11.2.0/API_changes).
-   **Public Test Realm (PTR):** Blizzard opens a PTR before every major patch. This is an essential opportunity for developers to install and test their addons against the upcoming changes, identify breaking changes, and prepare an update before the patch goes live to the public.

**Section 11: Essential Resources for the Addon Developer**

No developer works in a vacuum. The WoW addon community is vibrant and supportive, with a wealth of shared knowledge and resources available.

**11.1. Documentation and API References**

-   **Warcraft Wiki (warcraft.wiki.gg):** This should be the first destination for any API question. It is the most comprehensive and actively updated public resource for WoW API documentation.
-   **Wowpedia (wowpedia.fandom.com):** Another major wiki with a vast amount of information, though it is sometimes less current than the Warcraft Wiki for the very latest API changes.
-   **Blizzard's UI Source:** As mentioned in Section 1, the locally extracted UI files are the ultimate, ground-truth reference for how the game's own systems work.

**11.2. Community Hubs and Support**

When documentation is not enough, direct interaction with other developers is invaluable.

-   **WoWInterface Forums:** This is a long-standing and highly active community hub for addon authors. The "Developer Discussions" section has dedicated forums for Lua/XML help, tutorials, and general authoring questions, and is an excellent place to get detailed help from experienced developers.
-   **Reddit:** The subreddits r/wowaddons and r/wowaddondev are active communities for both users and developers. They are good places to announce new addons, get user feedback, and ask for help.
-   **WoWUIDev Discord Server:** For real-time interaction, this Discord server is the most active gathering of addon developers. It features dedicated help channels where both new and veteran authors collaborate and solve problems.

**11.3. Distribution and Publishing**

Once an addon is ready for the public, it needs to be hosted on a platform where users can find and download it.

-   **CurseForge:** The largest and most popular distribution platform for WoW addons. It is integrated with several addon manager applications, making installation easy for users. CurseForge provides project pages, bug tracking, and an API for developers to automate the process of uploading new versions.
-   **Wago.io:** While originally focused on sharing WeakAuras and Plater profiles, Wago.io has expanded to host standalone addons and is a growing alternative distribution platform.
-   **WoWInterface:** Another major, long-standing distribution site with a strong focus on the developer community that hosts its forums.

**Conclusion**

The landscape of World of Warcraft addon development is one of continuous evolution, shaped by both Blizzard's design decisions and the collective ingenuity of the community. Creating a high-quality addon in the modern era requires more than just functional Lua code; it demands a holistic approach that prioritizes performance, stability, and user experience from the outset.

The analysis reveals a clear trajectory in best practices. There is a decisive shift towards programmatic UI creation in Lua to gain maintainability and avoid the pitfalls of the global namespace. Performance optimization has matured beyond simplistic memory metrics to a sophisticated focus on minimizing CPU usage within the critical frame budget. The introduction of complex UI systems like Edit Mode has elevated the importance of a deep understanding of the taint system to prevent stability issues. Furthermore, the expansion of the .toc file's capabilities underscores the need for developers to build a single, adaptable codebase that can serve multiple game clients efficiently.

For the aspiring developer, the path to creating a successful addon is paved with a commitment to these best practices. It involves selecting a professional toolchain, leveraging community resources like the Warcraft Wiki and developer forums, and rigorously profiling code to ensure it is as efficient as possible. By embracing an event-driven mindset, managing data persistence carefully, and building intuitive user interfaces, a developer can create addons that not only add powerful functionality to the game but also enhance the player experience without compromising performance. The tools, documentation, and community support are more accessible than ever, providing a robust foundation for the next generation of addon authors to build upon.

Sources used in the report

![](media/81addaa406504038756c8f1613668203.png)

github.com

pbrianmackey/WorldOfWarcraftAddOn: How to setup your ... - GitHub

Opens in a new window

![](media/512fa9586f7ddc1cb3260d9d00dd7fed.png)

dev-hq.net

How to Create a WoW Addon \| Dev-HQ: Other Tutorial

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

Creating a WoW Addon - Part 1: A Fresh Start : r/wowaddondev - Reddit

Opens in a new window

![](media/81addaa406504038756c8f1613668203.png)

github.com

Ketho/vscode-wow-api: VS Code extension for World of Warcraft AddOns - GitHub

Opens in a new window

![](media/3b45cff06a043f948b9f49a70d18f94f.png)

addonstudio.org

AddOn Studio 2022 for World of Warcraft - AddOn Studio

Opens in a new window

![](media/3b45cff06a043f948b9f49a70d18f94f.png)

addonstudio.org

AddOn Studio

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

Learning resources for addon development : r/wowaddons - Reddit

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

Overwhelmed by amount of WoW add-ons. Been told they are essential to end-game. - Reddit

Opens in a new window

![](media/c6e37dfe960e0545a69cf21e3cd1269c.png)

addons.wago.io

DevTool - Wago Addons

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

[DEVHELP] Any good resources/tutorials for coding addons? : r/wowaddons - Reddit

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

New to Lua, Creating Addons for WoW, Advice Request - WoWInterface

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

Where did you learn to develop addons for WOW? Is there any blogs or tutorials that go through how to find WOW specific functions or variables to hook into? : r/wowaddons - Reddit

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Building a UI suite from scratch? - WoWInterface

Opens in a new window

![](media/15f8512c362d1b0b7f23355ad981cd71.png)

warcraft.wiki.gg

TOC format - Warcraft Wiki - Your wiki guide to the World of Warcraft

Opens in a new window

![](media/3b45cff06a043f948b9f49a70d18f94f.png)

addonstudio.org

WoW:TOC format - AddOn Studio

Opens in a new window

![](media/3b45cff06a043f948b9f49a70d18f94f.png)

addonstudio.org

WoW:TOC file - AddOn Studio

Opens in a new window

![](media/3b45cff06a043f948b9f49a70d18f94f.png)

addonstudio.org

WoW:XML/Frame - AddOn Studio

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Saved Variables - WoWInterface

Opens in a new window

![](media/15f8512c362d1b0b7f23355ad981cd71.png)

warcraft.wiki.gg

Patch 11.2.0/API changes - Warcraft Wiki - Your wiki guide to the ...

Opens in a new window

![](media/15f8512c362d1b0b7f23355ad981cd71.png)

warcraft.wiki.gg

Events - Warcraft Wiki - Your wiki guide to the World of Warcraft

Opens in a new window

![](media/15dfc652cc2fb57610767a910ad1cd5e.png)

slaptijack.com

Delving into WoW: Creating Mods with Lua - slaptijack

Opens in a new window

![](media/15f8512c362d1b0b7f23355ad981cd71.png)

warcraft.wiki.gg

Frame - Warcraft Wiki - Your wiki guide to the World of Warcraft

Opens in a new window

![A blue text on a black background AI-generated content may be incorrect.](media/54bcddfd362cbd6fe2effcbc350d0444.png)

us.forums.blizzard.com

Lua - how do I create frames? - UI and Macro - World of Warcraft Forums

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Unit Frames - WoWInterface

Opens in a new window

![](media/3b45cff06a043f948b9f49a70d18f94f.png)

addonstudio.org

WoW:Secure Execution and Tainting - AddOn Studio

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Saving Data To File - WoWInterface

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

How would I get data from an addon to...anywhere really. : r/wowaddons - Reddit

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

How To Make AddOn Options? - WoWInterface

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Using the Interface Options Addons panel - WoWInterface

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

Adding Addon Options : r/wowaddons - Reddit

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

Creating a WoW Addon - Part 10: Creating a Settings Interface : r ...

Opens in a new window

![](media/c6e37dfe960e0545a69cf21e3cd1269c.png)

addons.wago.io

ACU - Addon CPU Usage

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

AddonUsage : Utility Mods : World of Warcraft AddOns - WoWInterface

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Addons optimization: reducing lag - where to start? - WoWInterface

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

About the new addon performance tracking - common misconceptions and clarifications : r/wow - Reddit

Opens in a new window

![A red play button with a white arrow AI-generated content may be incorrect.](media/e0ee6c260e6b9241d3470d2421474fcf.png)

youtube.com

Are Addons Hurting Your FPS in WoW? - YouTube

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Efficient LUA code? - WoWInterface

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

About add-ons optimization - WoWInterface

Opens in a new window

![](media/3b45cff06a043f948b9f49a70d18f94f.png)

addonstudio.org

WoW:UI best practices - AddOn Studio

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

Is anybody else getting messages like this constantly? It prevents me from using abilities seemingly at random until I reload : r/wow - Reddit

Opens in a new window

![A blue text on a black background AI-generated content may be incorrect.](media/54bcddfd362cbd6fe2effcbc350d0444.png)

us.forums.blizzard.com

'Addon' has been blocked from an action only available to the Blizzard UI - Page 2 - Bug Report - World of Warcraft Forums

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

Has anyone figured out a solution to this problem with Blizzard's UI? This \$%!+ is driving me insane : r/wow - Reddit

Opens in a new window

![A blue text on a black background AI-generated content may be incorrect.](media/54bcddfd362cbd6fe2effcbc350d0444.png)

us.forums.blizzard.com

Compactframe Error Taint Issue? - UI and Macro - World of Warcraft Forums

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Addon file system structuring - WoWInterface

Opens in a new window

![](media/1a292ce1aab19bffc691d997a3824153.png)

joegannon.dev

How to Write a WoW Addon - Joe Gannon

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Localization Help - WoWInterface

Opens in a new window

![A blue and white logo AI-generated content may be incorrect.](media/28d0bace8714eb699555ffcf7d64293c.png)

skycoach.gg

Best The War Within Addons 2025 - Top 10 Must Have WoW Addons List - Skycoach

Opens in a new window

![](media/15f8512c362d1b0b7f23355ad981cd71.png)

warcraft.wiki.gg

Patch 11.0.0/API changes - Warcraft Wiki - Your wiki guide to the World of Warcraft

Opens in a new window

![](media/15f8512c362d1b0b7f23355ad981cd71.png)

warcraft.wiki.gg

Patch 11.1.7/API changes - Warcraft Wiki - Your wiki guide to the ...

Opens in a new window

![](media/15f8512c362d1b0b7f23355ad981cd71.png)

warcraft.wiki.gg

Patch 11.1.5/API changes - Warcraft Wiki - Your wiki guide to the ...

Opens in a new window

![](media/15f8512c362d1b0b7f23355ad981cd71.png)

warcraft.wiki.gg

API change summaries - Warcraft Wiki - Your wiki guide to the World ...

Opens in a new window

![](media/15f8512c362d1b0b7f23355ad981cd71.png)

warcraft.wiki.gg

World of Warcraft API

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

Developer Discussions - WoWInterface

Opens in a new window

![](media/3b45cff06a043f948b9f49a70d18f94f.png)

addonstudio.org

WoW:Development - AddOn Studio

Opens in a new window

![A logo of a cartoon character AI-generated content may be incorrect.](media/e368163e98d51167a47ba2c572766932.png)

reddit.com

r/wowaddons - Reddit

Opens in a new window

![A blue and white logo AI-generated content may be incorrect.](media/f183eaee969fd96c436e7e7fe2248b38.png)

wowvendor.com

The War Within 11.2: 10 Best WoW addons for beginners 2025 - WowVendor

Opens in a new window

![](media/c93896013044744c4916cb947043cafe.png)

support.curseforge.com

CurseForge Upload API

Opens in a new window

![](media/363d634a06b2618c0f1c0dc1ce811f88.jpeg)

wowinterface.com

WoWInterface

Opens in a new window

Sources read but not used in the report
