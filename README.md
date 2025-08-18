# MindMap AI – Demo README

This document describes the demo app, its structure, data flow, API contracts, and how AI generation is integrated. It is written as a project handoff note.

---

## 1) Demo Summary

- **What it is:** A Flutter app that renders **multiple mind‑map trees** (a forest). Nodes are editable, resizable by text, and laid out left‑to‑right with connectors that match the spec.
- **How data arrives:** Either from an API (fetching an existing forest) or from an **AI prompt** that returns a valid forest JSON.
- **Architecture:** MVVM with `UI → ViewModel (Controller) → Repository → Service` abstractions. Two service implementations are planned: API‑driven and AI‑driven.
- **Persistence model:** Entire forest can be **saved** back via a single endpoint for demo purposes.

---

## 2) At a Glance

| Item | Description |
|---|---|
| **Pattern** | MVVM (UI + ViewModel + Repository + Service) |
| **Data Structure** | **Rooted ordered forest** represented as an **adjacency‑list tree**. Each node has `id`, `label`, and an ordered array of `children` (recursive). Forest = array of trees; each tree has a `root` node. Invariants: unique node IDs within a forest, children preserve order, parent→child edges only (no cycles). |
| **Transport Types** | DTOs (for JSON), mapped to domain **Entities**, then adapted to **UI models** (palette/color + view concerns). |
| **AI** | OpenAI **Responses API** with **JSON‑Schema constrained** output to guarantee a valid forest payload. |
| **Save Strategy** | Demo uses **two endpoints**: `fetch` (GET current forest) and `save` (POST entire forest). Granular add/update/delete endpoints are omitted here by design. |

---

## 3) Project Structure (Flutter)

```
lib/
├─ presentation/
│  └─ mind_map/
│     ├─ widgets/
│     │  ├─ mind_map_page.dart        # Screen (UI)
│     │  ├─ forest_layout.dart        # Forest and single-tree layout
│     │  ├─ node_widget.dart          # Node card
│     │  ├─ hint_button.dart          # “+” affordance
│     │  ├─ painters/
│     │  │  ├─ edge_painter.dart      # Connectors/chevrons
│     │  │  └─ hint_painter.dart      # Dotted hint run
│     │  ├─ ml_text.dart              # AIPromptBar (glow, button, animation)
│     │  ├─ custom_app_bar.dart
│     │  ├─ node_context_menu.dart
│     │  └─ toast.dart                # Bottom toasts (Flushbar)
│     └─ ui_data/
│        └─ node_ui_data_model.dart   # UINode model (color, etc.)
├─ repository/
│  └─ mind_map/
│     ├─ entity/
│     │  ├─ node_dto_model.dart       # DTOs (JSON)
│     │  ├─ node_entity_model.dart    # Domain entities
│     │  └─ mappers.dart              # DTO → Entity → UI mapping
│     ├─ mind_map_repository.dart     # Repository + abstraction
│     └─ ...
├─ services/
│  └─ mind_map/
│     ├─ mind_map_service_interface.dart
│     ├─ api_service/…                # API impl (fetch/save)
│     └─ ml_service/
│        └─ mind_map_ml_service.dart  # OpenAI impl (prompt → forest)
├─ view_model/
│  └─ mind_map/
│     ├─ mind_map_view_model.dart     # Controller (ChangeNotifier)
│     ├─ i_mind_map_view_model.dart   # Interface for VM
│     └─ ui_event.dart                # Success/Error events
├─ utility/
│  ├─ constant.dart, styles.dart, node_color_palette.dart, utility.dart
└─ mock_data/ mind_map_mocks.dart
```

---

## 4) Data Model & Mapping

### JSON (DTO)
```jsonc
{
  "mapId": "demo_001",
  "title": "Demo Forest",
  "version": 1,
  "trees": [
    { "root": { "id": "t1_root", "label": "Project Alpha", "children": [] } }
  ]
}
```

### Domain (Entity)
```dart
class NodeEntity { final String id; final String label; final List<NodeEntity> children; }
class TreeEntity { final NodeEntity root; }
class ForestEntity { final String mapId; final String title; final List<TreeEntity> trees; final int version; }
```

### UI Model
```dart
class UINode { String id; String label; INodeColorPalette nodeColorPalette; List<UINode> children; }
```

### Mapping Pipeline
1. **DTO → Entity**: parse JSON → immutable domain graph.
2. **Entity → UI**: assign **per‑tree color palette** to every node of that tree; preserve order.
3. **UI → Layout**: `ForestLayout.compute()` produces positioned boxes to render with `EdgePainter` and `MindNodeCard`.

---

## 5) AI Generation (OpenAI Responses API)

- Endpoint: `POST https://api.openai.com/v1/responses`
- Model: `gpt-4.1-mini` (configurable)
- The request **enforces a JSON‑Schema** for `ForestDto`, so responses are always valid for the mapper.
- API key is read from `.env` as `OPEN_API_KEY` (via `flutter_dotenv`).

**Prompting (concept):**
- The prompt can be short (“**Create a product roadmap**”) or rich.
- The system adds constraints: max trees/children, ID prefixes, uniqueness, etc.
- If user intent implies multiple themes, the model generates **multiple trees**.

---

## 6) API Contracts (Demo)

Base URL is illustrative. The app uses two endpoints.

### 6.1 GET `v1/api/mindmap/fetch`
**Purpose:** Fetch the current forest for the signed‑in user (or a map by query `mapId`).  
**Auth:** Bearer token.

**Query (optional):**
```
?mapId=demo_001
```

**Response 200 (application/json):**
```json
{
  "mapId": "demo_001",
  "title": "Demo Forest",
  "version": 3,
  "trees": [
    {
      "root": {
        "id": "t1_root",
        "label": "Project Alpha",
        "children": [
          { "id": "t1_c1", "label": "Scope", "children": [] },
          { "id": "t1_c2", "label": "Timeline", "children": [] },
          { "id": "t1_c3", "label": "Risks", "children": [] }
        ]
      }
    },
    {
      "root": {
        "id": "t2_root",
        "label": "Marketing",
        "children": [
          { "id": "t2_c1", "label": "Channels", "children": [] },
          { "id": "t2_c2", "label": "Budget", "children": [] }
        ]
      }
    }
  ]
}
```

### 6.2 POST `v1/api/mindmap/save`
**Purpose:** Save the entire forest (overwrite by `mapId`, bump `version`).  
**Auth:** Bearer token.

**Request Body (application/json):**
```json
{
  "mapId": "demo_001",
  "title": "Demo Forest",
  "version": 3,
  "trees": [
    { "root": { "id": "t1_root", "label": "Project Alpha", "children": [] } }
  ]
}
```

**Response 200:**
```json
{ "status": "ok", "mapId": "demo_001", "version": 4 }
```

**Response 409 (version conflict):**
```json
{ "status": "conflict", "expectedVersion": 4, "message": "Please refetch and retry." }
```

---

## 7) Layout & Rendering Notes

- **ForestLayout** stacks trees top‑to‑bottom with a configurable gap; boxes are measured via `TextPainter` and clamped to min/max widths; height grows as lines wrap.
- **MindMapLayout** places the first child on the parent row, subsequent children below; connectors are drawn with a straight top run and a quadratic elbow for the last child; arrowheads have a fixed 6px gap to cards.
- **Hint affordance** shows a “+” circle; if the node already has children, only the plus renders (no dashed hint).

---

## 8) AIPromptBar (Bottom)

- Center/left‑anchored bar with a **rotating rainbow border** and soft halo.
- Suffix button animates (gradient + stars) while generating.
- Uses `.env` key `OPEN_API_KEY`; ViewModel exposes `isGenerating` to animate, and emits `UiEvent` for success/error toasts.

---

## 9) Toasts (Bottom)

- Package: `another_flushbar` (floating, bottom aligned).
- ViewModel exposes `ValueNotifier<UiEvent?> toastEvent`.
- `MindMapPage` subscribes and displays a Flushbar on success/error.
- Styles: light gradient background (green→white for success, red→white for error), outlined small icon, dark green/red text.

---

## 10) Running the Demo

1. Create a `.env` in project `assets/env/` folder:
   ```env
   OPEN_API_KEY=sk-****************
   ```
2. `flutter pub get`
3. Run on device/emulator: `flutter run`
4. Use the bottom **AIPromptBar** to generate a mind‑map forest, or wire the API service for fetch/save.

---

## 11) Final Forest JSON (reference)

```json
{
  "mapId": "demo_001",
  "title": "Demo Forest",
  "version": 1,
  "trees": [
    {
      "root": {
        "id": "t1_root",
        "label": "Project Alpha",
        "children": [
          { "id": "t1_c1", "label": "Scope",    "children": [] },
          { "id": "t1_c2", "label": "Timeline", "children": [] },
          { "id": "t1_c3", "label": "Risks",    "children": [] }
        ]
      }
    },
    {
      "root": {
        "id": "t2_root",
        "label": "Marketing",
        "children": [
          { "id": "t2_c1", "label": "Channels", "children": [] },
          { "id": "t2_c2", "label": "Budget",   "children": [] }
        ]
      }
    },
    {
      "root": {
        "id": "t3_root",
        "label": "Personal",
        "children": [
          { "id": "t3_c1", "label": "Health",   "children": [] },
          { "id": "t3_c2", "label": "Learning", "children": [] },
          { "id": "t3_c3", "label": "Travel",   "children": [] },
          { "id": "t3_c4", "label": "Finance",  "children": [
            { "id": "t3_c4_1", "label": "Finance - 1", "children": [] },
            { "id": "t3_c4_2", "label": "Finance - 2", "children": [] }
          ] }
        ]
      }
    }
  ]
}
```

---

## 12) Notes on the Data Structure

Rooted ordered forest represented as an adjacency‑list tree. Each node has id, label, and an ordered array of children (recursive). Forest = array of trees; each tree has a root node. Invariants: unique node IDs within a forest, children preserve order, parent→child edges only (no cycles).

- **Forest**: ordered list of independent **trees** to be displayed one under another.
- **Tree**: one **root** node; traversal is pre‑order for layout; connectors computed using measured child sub‑heights.
- **Node**: `id` is a string; `label` is free text; `children` is an ordered list of nodes.
- **Complexity**: layout is **O(N)** over nodes; measurement is O(N) with per‑node `TextPainter.layout` bounded by max width.
- **Stability**: node IDs remain stable across edits; color palettes are assigned **per root** and inherited by its descendants.

