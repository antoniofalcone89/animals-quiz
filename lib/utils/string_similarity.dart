import 'dart:math';

/// Computes the Levenshtein edit distance between two strings.
int levenshteinDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final prev = List<int>.generate(b.length + 1, (i) => i);
  final curr = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      curr[j] = min(
        min(curr[j - 1] + 1, prev[j] + 1),
        prev[j - 1] + cost,
      );
    }
    prev.setAll(0, curr);
  }

  return curr[b.length];
}

/// Returns true if [guess] is close enough to [correct] to count as a match.
///
/// Rules:
/// - Exact match (case-insensitive) → always true
/// - For words with 4 or fewer characters: allow 1 edit
/// - For words with 5–7 characters: allow 1 edit
/// - For words with 8+ characters: allow 2 edits
bool isFuzzyMatch(String guess, String correct) {
  final g = guess.trim().toLowerCase();
  final c = correct.trim().toLowerCase();

  if (g == c) return true;
  if (g.isEmpty) return false;

  final distance = levenshteinDistance(g, c);
  final maxDistance = c.length <= 7 ? 1 : 2;

  return distance <= maxDistance;
}
