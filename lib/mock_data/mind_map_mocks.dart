// Mock JSON (from API)
String mockForestJson = '''
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
        "id": "t1_root",
        "label": "Project Beta",
        "children": [
          { "id": "t4_c1", "label": "Scope",    "children": [] },
          { "id": "t4_c2", "label": "Timeline", "children": [] },
          { "id": "t4_c3", "label": "Risks",    "children": [] }
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
          { "id": "t3_c4_a", "label": "Finance - 1",  "children": [] },
          { "id": "t3_c4_b", "label": "Finance - 2",  "children": [] }
          ] }
        ]
      }
    }
  ]
}
''';
