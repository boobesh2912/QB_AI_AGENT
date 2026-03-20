QB_AGENT_SYSTEM_PROMPT = """You are an expert English language question bank generator.
Generate high-quality MCQ questions. Return ONLY valid JSON.

Format:
{
  "questions": [
    {
      "topic": "string",
      "difficulty": "string",
      "passage": null,
      "question": "string",
      "options": {"a": "string", "b": "string", "c": "string", "d": "string"},
      "correct_answer": "a|b|c|d",
      "explanation": "string"
    }
  ]
}

TOOL ROUTING:
- type=grammar       -> call generate_grammar_questions ONCE
- type=comprehension -> call generate_passage_with_questions ONCE
- Never call a tool more than once
- No markdown, no preamble, return JSON only
"""

EVALUATION_AGENT_SYSTEM_PROMPT = """You are an expert English language assessment evaluator.
Evaluate candidate text and provide structured feedback.
Always respond with valid JSON only.
"""

GRAMMAR_QUESTION_TOOL_PROMPT = """Generate {count} grammar MCQ questions.
Topic: {topic}
Difficulty: {difficulty}

Return ONLY valid JSON:
{{
  "questions": [
    {{
      "topic": "{topic}",
      "difficulty": "{difficulty}",
      "passage": null,
      "question": "string",
      "options": {{"a": "string", "b": "string", "c": "string", "d": "string"}},
      "correct_answer": "a|b|c|d",
      "explanation": "string"
    }}
  ]
}}
"""

PASSAGE_TOOL_PROMPT = """Generate one reading passage (120-180 words) and {count} MCQ questions based on it.
Topic: {topic}
Difficulty: {difficulty}

Return ONLY valid JSON:
{{
  "questions": [
    {{
      "topic": "{topic}",
      "difficulty": "{difficulty}",
      "passage": "full passage text here",
      "question": "string",
      "options": {{"a": "string", "b": "string", "c": "string", "d": "string"}},
      "correct_answer": "a|b|c|d",
      "explanation": "string"
    }}
  ]
}}
"""

GRAMMAR_TOOL_PROMPT = """Compare candidate text against original for grammar errors.
Original:  {original}
Candidate: {candidate}

Return ONLY valid JSON:
{{
  "accuracy_score": 0.0,
  "error_count": 0,
  "error_types": [],
  "corrected_text": "string",
  "feedback": "string"
}}
"""

READING_TOOL_PROMPT = """Evaluate reading performance.
Original: {original}
Transcribed: {transcribed}
WPM: {wpm}
Expected range: {min_wpm}-{max_wpm}

Classify as Good (WPM in range AND accuracy>=85%), Average (70-84%), Bad (<70% or far outside range).

Return ONLY valid JSON:
{{
  "classification": "Good|Average|Bad",
  "overall_score": 0.0,
  "feedback": "string",
  "recommendations": "string"
}}
"""

VOCABULARY_TOOL_PROMPT = """Analyze vocabulary richness.
Text: {text}
Pre-calculated TTR: {ttr}

Return ONLY valid JSON:
{{
  "richness_score": 0.0,
  "unique_word_ratio": {ttr},
  "advanced_word_count": 0,
  "common_word_count": 0,
  "vocabulary_level": "Basic|Intermediate|Advanced",
  "suggestions": []
}}
"""

STRUCTURE_TOOL_PROMPT = """Validate sentence and paragraph structure.
Text: {text}
Sentence count: {sentence_count}
Avg length: {avg_len}

Return ONLY valid JSON:
{{
  "structure_score": 0.0,
  "sentence_count": {sentence_count},
  "avg_sentence_length": {avg_len},
  "issues": [],
  "is_coherent": true,
  "feedback": "string"
}}
"""

PRONUNCIATION_TOOL_PROMPT = """Evaluate pronunciation from transcription differences.
Original: {original}
Transcribed: {transcribed}
Duration: {duration}s

Return ONLY valid JSON:
{{
  "pronunciation_score": 0.0,
  "fluency_score": 0.0,
  "mispronounced_words": [],
  "feedback": "string"
}}
"""
