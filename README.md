# Flutter NoCode Platform — Visual Editor

A browser-based drag-and-drop UI editor built with Flutter Web. Users visually compose Flutter layouts without writing code — selecting components, configuring properties, and exporting production-ready Dart/Flutter code.

Served at `/flutter/` via the platform's Nginx reverse proxy.

---

## Features

- **Visual Canvas** — Drag-and-drop components to build Flutter UI layouts
- **Property Inspector** — Configure layout, styling, color, and behavior per component
- **Multi-page Support** — Manage multiple pages within a single project
- **Undo / Redo** — Full edit history
- **Code Export** — Generate clean, formatted Flutter/Dart source code
- **Project Save / Load** — Export and import project files locally
- **AI Integration** — Communicates with the MCP service to generate or adjust layouts from natural language prompts

---

## Tech Stack

| Category         | Library                    |
|------------------|----------------------------|
| Framework        | Flutter (Web target)       |
| State Management | Flutter Riverpod 2.6.1     |
| Code Generation  | dart_style 3.1.0           |
| Syntax Highlight | flutter_syntax_view 4.1.7  |
| Color Picker     | flutter_colorpicker 1.1.0  |
| HTTP             | http 1.4.0                 |

---

## Editor Layout

```
┌────────────────────────────────────────────────┐
│                 Canvas Toolbar                 │
│         (Undo · Redo · Zoom · Export)          │
├──────────┬─────────────────────────┬───────────┤
│          │                         │           │
│   Left   │       Canvas View       │   Right   │
│  Panel   │   (Drag-and-drop area)  │   Panel   │
│          │                         │(Inspector)│
│ Pages &  │                         │ Props &   │
│Component │                         │ Styling   │
│   Tree   │                         │           │
└──────────┴─────────────────────────┴───────────┘
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.7+

### Development

```bash
flutter pub get

flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8082
```

Access at `http://localhost:8082/flutter/`

### Production (Docker)

Built and served automatically via `docker-compose.services.yml` in `flutter_nocode_backend`.

```bash
# Build image manually
docker build -t flutter-editor .

# Run container
docker run -p 8082:8082 flutter-editor
# Access at http://localhost:8082/flutter/
```

### Build for Web

```bash
flutter build web --release --base-href /flutter/
```

---

## Project Structure

```
lib/
├── main.dart              # App entry point & shell layout
├── editor/
│   ├── components/        # Component registry & definitions
│   ├── models/            # Data models (nodes, properties)
│   └── properties/        # Property type definitions
├── ui/
│   ├── canvas/            # Canvas view & toolbar
│   ├── left/              # Left panel (pages, component tree)
│   ├── right/             # Right panel (property inspector)
│   ├── global/            # Project overview mode
│   └── common/            # Shared widgets
├── providers/             # Riverpod providers
├── services/              # Code generator, AI bridge
└── state/                 # App-level state
```
