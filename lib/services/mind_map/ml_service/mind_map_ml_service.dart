import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:mindmap_ai/utility/utility.dart';

abstract class IAiPromptService {
  Future<Map<String, dynamic>> generateFromPrompt(String prompt);
}

class AiPromptService extends IAiPromptService {
  static const _endpoint = 'https://api.openai.com/v1/responses';
  static const _model = 'gpt-4.1-mini';

  @override
  Future<Map<String, dynamic>> generateFromPrompt(String prompt) async {
    final input = _buildFlexibleInput(prompt);

    final first = await _callOpenAI(input, _flexForestSchema);

    if (_looksLikeItShouldBeSplit(first)) {
      final retryInput = _buildForceMultiInput(prompt);
      final second = await _callOpenAI(retryInput, _strictMultiForestSchema);
      return second;
    }

    return first;
  }

  String _buildFlexibleInput(String topic) => '''
Create a **mind-map forest** for the user's topic.

RULES
- Choose **1–5 separate trees** (top-level roots).
- If the topic naturally decomposes into sub-domains, prefer **3–4 roots**.
- If the topic is truly singular, **1 root** is acceptable.
- **Do not** place everything under a single umbrella root if meaningful sub-domains exist.
- Root labels must be short and concrete (e.g., “Planning”, “Execution”).
- Each root should have **3–6 direct children** (deeper nesting only if it helps).
- Keep ids short string tokens.
- Return **only** JSON that validates against the provided schema.

TOPIC: $topic
''';

  String _buildForceMultiInput(String topic) => '''
You returned one tree previously. This topic has distinct sub-domains.
**Split into 3–4 separate trees** (top-level roots) with 3–6 children each.
Return only JSON that validates against the schema.

TOPIC: $topic
''';

  Future<Map<String, dynamic>> _callOpenAI(
    String input,
    Map<String, dynamic> schema,
  ) async {
    final body = {
      "model": _model,
      "instructions":
          "You are a strict JSON generator. Only return JSON that validates against the provided schema.",
      "input": input,
      "text": {
        "format": {
          "type": "json_schema",
          "name": "ForestDto",
          "strict": true,
          "schema": schema,
        }
      },
      "max_output_tokens": 2000,
      "temperature": 0.2
    };

    final res = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            "Authorization": "Bearer ${Utility.openAiKey}",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
          "OpenAI error ${res.statusCode}: ${res.body.isNotEmpty ? res.body : '(no body)'}");
    }

    final Map<String, dynamic> resp = jsonDecode(res.body);

    final List output = (resp["output"] as List?) ?? const [];
    final Map msg = output.firstWhere(
      (o) => o is Map && o["type"] == "message",
      orElse: () => const {},
    );
    final List content = (msg["content"] as List?) ?? const [];
    final Map textPart = content.firstWhere(
      (c) => c is Map && c["type"] == "output_text",
      orElse: () => const {},
    );

    final String jsonString = (textPart["text"] as String? ?? "").trim();
    if (jsonString.isEmpty) {
      throw Exception("OpenAI returned no JSON text payload.");
    }

    try {
      final Map<String, dynamic> forest = jsonDecode(jsonString);
      return forest;
    } catch (e) {
      throw Exception(
          "Failed to parse model JSON: $e\n--- Raw ---\n$jsonString");
    }
  }

  bool _looksLikeItShouldBeSplit(Map<String, dynamic> forest) {
    final trees = (forest['trees'] as List?) ?? const [];
    if (trees.length != 1) return false;
    final root = (trees.first as Map)['root'] as Map?;
    if (root == null) return false;
    final children = (root['children'] as List?) ?? const [];
    return children.length >= 6;
  }
}

const Map<String, dynamic> _flexForestSchema = {
  "type": "object",
  "additionalProperties": false,
  "required": ["mapId", "title", "version", "trees"],
  "properties": {
    "mapId": {"type": "string"},
    "title": {"type": "string"},
    "version": {"type": "integer"},
    "trees": {
      "type": "array",
      "minItems": 1,
      "maxItems": 5,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["root"],
        "properties": {
          "root": {
            "type": "object",
            "additionalProperties": false,
            "required": ["id", "label", "children"],
            "properties": {
              "id": {"type": "string"},
              "label": {"type": "string"},
              "children": {
                "type": "array",
                "items": {"\$ref": "#/\$defs/NodeDto"}
              }
            }
          }
        }
      }
    }
  },
  "\$defs": {
    "NodeDto": {
      "type": "object",
      "additionalProperties": false,
      "required": ["id", "label", "children"],
      "properties": {
        "id": {"type": "string"},
        "label": {"type": "string"},
        "children": {
          "type": "array",
          "items": {"\$ref": "#/\$defs/NodeDto"}
        }
      }
    }
  }
};

/// Strict “split into multiple roots” schema: 3–4 trees.
/// Used only on the retry path when the first result is one big tree.
const Map<String, dynamic> _strictMultiForestSchema = {
  "type": "object",
  "additionalProperties": false,
  "required": ["mapId", "title", "version", "trees"],
  "properties": {
    "mapId": {"type": "string"},
    "title": {"type": "string"},
    "version": {"type": "integer"},
    "trees": {
      "type": "array",
      "minItems": 3,
      "maxItems": 4,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["root"],
        "properties": {
          "root": {
            "type": "object",
            "additionalProperties": false,
            "required": ["id", "label", "children"],
            "properties": {
              "id": {"type": "string"},
              "label": {"type": "string"},
              "children": {
                "type": "array",
                "items": {"\$ref": "#/\$defs/NodeDto"}
              }
            }
          }
        }
      }
    }
  },
  "\$defs": {
    "NodeDto": {
      "type": "object",
      "additionalProperties": false,
      "required": ["id", "label", "children"],
      "properties": {
        "id": {"type": "string"},
        "label": {"type": "string"},
        "children": {
          "type": "array",
          "items": {"\$ref": "#/\$defs/NodeDto"}
        }
      }
    }
  }
};
