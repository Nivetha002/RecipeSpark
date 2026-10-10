/// Serving-size maths and quantity formatting.
class ServingScaler {
  ServingScaler._();

  static double scale(double quantity, int baseServings, int targetServings) {
    if (baseServings <= 0 || targetServings <= 0) return quantity;
    return quantity * targetServings / baseServings;
  }

  /// "200 g", "½ cup", "To taste".
  static String format(double? quantity, String unit) {
    if (quantity == null) return 'To taste';
    final n = _number(quantity);
    return unit.isEmpty ? n : '$n $unit';
  }

  /// Scale then format in one go.
  static String scaledText(
      double? quantity, String unit, int baseServings, int targetServings) {
    if (quantity == null) return format(null, unit);
    return format(scale(quantity, baseServings, targetServings), unit);
  }

  static String _number(double v) {
    if (v >= 20) return v.round().toString();
    var q = (v * 4).round() / 4; // nearest quarter
    if (q == 0 && v > 0) q = 0.25;
    final whole = q.floor();
    final frac = q - whole;
    String f = '';
    if (frac == 0.25) {
      f = '¼';
    } else if (frac == 0.5) {
      f = '½';
    } else if (frac == 0.75) {
      f = '¾';
    }
    if (whole == 0) return f.isEmpty ? '0' : f;
    return '$whole$f';
  }
}
