# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Color Critters! is an iOS educational game built with SpriteKit for kids ages 3-8. The game teaches color recognition through drag-and-drop interactions where players match colors to colorless animal critters.

**Enhanced Gamification Features:**
- **Streak System**: Multiplier bonuses for consecutive correct matches
- **Achievement System**: Unlockable badges for various milestones
- **Power-up System**: Special abilities and boosts
- **Daily Challenges**: Time-limited objectives with rewards
- **Progression System**: Player levels, experience points, and unlockables
- **Currency System**: Coins and gems for purchases and rewards
- **Particle Effects**: Celebration animations and visual feedback

## Build Commands

This is an Xcode iOS project. Use these standard Xcode commands:

- **Build**: `⌘+B` in Xcode or `xcodebuild -project "Color Critters!.xcodeproj" -scheme "Color Critters!" build`
- **Run**: `⌘+R` in Xcode or build and deploy to simulator/device
- **Test**: `⌘+U` in Xcode or `xcodebuild -project "Color Critters!.xcodeproj" -scheme "Color Critters!" test -destination 'platform=iOS Simulator,name=iPhone 15'`
- **Archive**: Product → Archive in Xcode for App Store builds

The project targets iOS 18.5+ and uses Swift 5.0.

## Architecture

### Core Design Pattern
The app follows a **Singleton + Delegate pattern** with clear separation of concerns:

- **GameScene**: Main SpriteKit scene containing all game logic, UI, and touch handling
- **Shared Singletons**: SoundManager, GameSettings, AdManager, PowerUpManager, DailyChallengeManager for cross-scene state management
- **Overlay Classes**: TutorialOverlay, EnhancedStatsScreen, PowerUpUI as separate UI components
- **Gamification Managers**: Dedicated managers for power-ups and daily challenges

### Key Architectural Decisions

1. **State Management**: Game state persisted via GameSettings singleton using UserDefaults
2. **Audio System**: SoundManager handles both sound effects and background music with programmatic sound generation
3. **Ad Integration**: AdManager with placeholder implementation ready for Google AdMob integration
4. **Modular UI**: Separate overlay classes for tutorial and stats instead of embedding in GameScene

### Core Game Loop

```
GameScene.didMove(to:) → setupGame() → startNewLevel()
  ↓
User drags color blob → touchesMoved → checkMatch()
  ↓
Correct match → handleCorrectMatch() → checkLevelComplete()
  ↓
Level complete → showCompletionAnimation() → startNewLevel()
```

### Data Flow

- **Persistent Data**: GameSettings ↔ UserDefaults
- **Audio**: SoundManager ← GameScene (plays sounds)
- **Ads**: AdManager ← GameScene (shows ads every 3 levels)
- **UI State**: GameScene ↔ TutorialOverlay/StatsScreen

## Key Implementation Details

### Color System
- 10 predefined colors: red, blue, green, yellow, orange, purple, pink, brown, cyan, magenta
- Progressive difficulty: starts with 3 colors, increases to 5 colors max
- Target color randomly selected for each level

### Critter System
- 10 animal types stored in `critters` array
- Critter sprites created as colorless silhouettes
- Successful color match fills the critter with target color

### Sound Architecture
- **Programmatic Generation**: SoundManager creates sound effects via AVAudioEngine synthesis
- **Background Music**: Looping cheerful melody generated programmatically
- **Audio Session**: Configured for `.ambient` category to mix with other apps

### Touch Handling
- Custom drag-and-drop implementation in GameScene
- Touch tracking via `isDragging`, `draggedNode`, `originalPosition`
- Collision detection for color blob drops on critter

## Important Code Locations

- **Game Logic**: `GameScene.swift:checkMatch()` - core matching algorithm
- **Level Progression**: `GameScene.swift:startNewLevel()` - difficulty scaling
- **Persistence**: `GameSettings.swift` - all UserDefaults keys and properties
- **Audio Generation**: `SoundManager.swift:generateCorrectSound()` - programmatic sound creation
- **Ad Placeholders**: `AdManager.swift` - ready for AdMob integration

## Testing Structure

- **Unit Tests**: `Color Critters!Tests/` - test game logic and scoring
- **UI Tests**: `Color Critters!UITests/` - test user interactions and flows
- Both test targets configured in Xcode project with iOS 18.5 deployment target