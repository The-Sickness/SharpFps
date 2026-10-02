# Sharp FPS

**A performance HUD for World of Warcraft that actually looks good.**

Sharp FPS shows your framerate and latency in a sleek, themeable panel with a live graph, a gauge, signal bars, and effects that react to how your game is running. It also has a classic plain text mode if you want to keep it simple.

Made by **Sharpedge_Gaming** · Version 5.0 · Built for WoW 12.1.0 (Midnight)


## Features

### HUD Display
* **Big FPS readout** that rolls smoothly to each new value
* **Mood word** next to the number (SMOOTH, OKAY, or CHUG) that pops when you cross into a new bracket
* **Frame time** in milliseconds, plus your recent **average** and session **low**
* **Gradient gauge** that fills toward a cap you set, like your monitor refresh rate, with a marker for your recent average
* **Live graph** of your last 10 to 60 samples in three styles: Bars, Line, or Line + Fill
* **Latency overlay** that draws world latency on the graph, so you can tell whether a hitch came from your PC or the server
* **Signal bars** for World and Home latency, lighting 1 to 4 bars based on your thresholds

### Color and Effects
* **Smart color coding** that blends smoothly from green to yellow to red based on thresholds you choose
* **Soft glow** around the frame that can follow your FPS, your class color, a custom color, or a full rainbow **Chroma Cycle**
* **Low FPS pulse** that makes the glow throb when performance drops
* **Red combat glow** the moment you pull
* **Shine sweep**, a glossy highlight that glides across the panel
* **CRT scanlines** for a retro monitor look
* **Fade out of combat** that dims the display until you hover it or enter combat

### Themes
Nine presets that set colors, glow, graph style, and effects in one click:

* **Midnight:** deep navy with a status driven accent
* **Neon:** black and magenta with a cyan glow
* **Synthwave:** purple and pink with chroma, shine, and scanlines all on
* **Glass:** light and translucent
* **Frost:** icy blue with shine
* **Terminal:** green on black with scanlines
* **Ember:** warm oranges
* **Gilded:** gold with the Morpheus font and shine
* **Class Pride:** your class color as the accent

Change any color after picking a theme and it switches to Custom, so you can use a preset as a starting point.

### Classic Text Mode
The original plain readout is still here. It supports a stacked or single line layout, left, center, or right alignment, and an optional background and border.

### Hover Tooltip
Mouse over the frame for current FPS, frame time, recent average, session low and high, home and world latency, and download and upload bandwidth.

Stats pause for 5 seconds after every loading screen so a load hitch never becomes your session low.


## Controls

### Mouse
* **Left drag:** move the frame (while unlocked)
* **Mouse wheel:** resize the frame (while unlocked)
* **Right click:** open options
* **Shift + right click:** swap between HUD and Classic Text
* **Middle click:** cycle to the next theme

When the frame is locked with the tooltip turned off, it becomes fully click through so it never gets in the way.

### Slash Commands
`/sfps` or `/sharpfps`

* `/sfps`: Open options
* `/sfps lock`: Lock or unlock the frame
* `/sfps reset`: Move the frame back to center at normal size
* `/sfps stats`: Clear session low, high, and average
* `/sfps toggle`: Turn the display on or off
* `/sfps style`: Swap between HUD and Classic Text
* `/sfps theme`: Cycle to the next theme
* `/sfps neon`: Apply a theme by name (midnight, neon, synthwave, glass, frost, terminal, ember, gold, class)
* `/sfps help`: List all commands in chat


## Options

Open with `/sfps`, right click on the frame, or through **Game Menu > Options > AddOns > Sharp FPS**.

* **General:** enable, lock, tooltip, display style, which values to show, combat behavior (always show, hide in combat, or only in combat), update interval, and fade out of combat
* **Look:** theme, font, outline, scale, label color, color coding, accent source, and glow settings
* **HUD:** width, number size, rolling number, mood word, frame time, gauge, graph style and size, latency overlay, panel colors, shine, and scanlines
* **Classic Text:** font size, layout, alignment, background, and border
* **Thresholds:** your Good and Warning values for FPS and latency
* **Profiles:** share or copy settings between characters (when AceDBOptions is installed)


## Installation

1. Download the latest release.
2. Extract the **SharpFps** folder into `World of Warcraft\_retail_\Interface\AddOns\`.
3. Restart the game or type `/reload`.

### Libraries
Sharp FPS uses **Ace3** and **LibSharedMedia**. These are bundled with the addon.

Two libraries are optional and are picked up automatically if present:
* **AceDBOptions** adds the Profiles tab
* **LibDataBroker** adds a feed for Titan Panel, ChocolateBar, Bazooka, and other broker displays

The addon runs fine without either one.


## Performance

Sharp FPS samples on a timer (0.5 seconds by default), not every frame, so it stays light. The only per frame work is the smooth number roll, fade, and chroma color, and each of those does nothing when idle or turned off.


## Upgrading from Older Versions

Your saved settings carry over. Position, font, colors, and toggles from earlier versions are kept, and new options start at their defaults.


## Feedback

Found a bug or have an idea? Leave a comment on the addon page with your game version and a description of what happened.

**Sharpedge_Gaming**
