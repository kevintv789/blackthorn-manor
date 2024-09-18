# blackthorn-manor
Top-down 2D horror game

Folder structure:
```
/project_root
├── /assets
│   ├── /2D
│   │   ├── /sprites
│   │   ├── /tilesets
│   ├── /audio
│   │   ├── /music
│   │   ├── /sfx
│   ├── /fonts
│   └── /shaders
├── /entities
│   ├── /base
│   │   ├── actor.tscn
│   │   ├── actor.gd
│   │   └── actor.tres
│   ├── /player
│   │   ├── player.tscn
│   │   └── player.gd
│   ├── /enemies
│   │   ├── /monster
│   │   │   ├── zombie.tscn
│   │   │   └── zombie.gd
├── /globals  
│   ├── game_manager.gd
│   ├── audio_manager.gd
├── /menus
│   ├── /title
├── /scenes
│   ├── /common  # shared assets across levels
│   ├── /main
│   │   ├── main_scene.tscn
│   │   └── main_assets/  # assets specific to this scene
├── /ui
│   ├── /theme_default
│   │   ├── icon.png
│   │   ├── button.png
│   │   └── theme_default.tres
│   ├── cool_font.ttf
│   ├── font_uidefault.tres
│   └── ui_elements.tscn  # reusable UI elements like HUD, buttons, etc.
```