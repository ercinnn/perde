import '../../data/models/enums.dart';

/// Implements the pricing formulas shown on the "Hesaplama Notu" screen.
class PricingCalculator {
  PricingCalculator._();

  static double _roundUpToStep(double value, double step) {
    if (step <= 0 || value <= 0) return value;
    final steps = (value / step - 1e-9).ceil();
    return steps * step;
  }

  /// [width] and [height] are the raw values as typed into the "En (m)" /
  /// "Boy (m)" fields on the order form (interpretation differs by category,
  /// matching the business rules on the Hesaplama Notu screen).
  static double compute({
    required PricingCategory category,
    required double width,
    required double height,
    required double pilePercent,
    required double unitPrice,
  }) {
    switch (category) {
      case PricingCategory.tulFon:
        final widthM = width > 50 ? width / 100 : width;
        final multiplier = pilePercent / 100 + 1;
        return widthM * multiplier * unitPrice;

      case PricingCategory.storZebra:
        final widthM = _roundUpToStep(width < 1.0 ? 1.0 : width, 0.1);
        final heightM = _roundUpToStep(height < 2.0 ? 2.0 : height, 0.1);
        return widthM * heightM * unitPrice;

      case PricingCategory.pliseliJaluzi:
        final widthCm = _roundUpToStep(width, 10);
        final heightCm = _roundUpToStep(height, 10);
        final areaM2 = (widthCm / 100) * (heightCm / 100);
        final billableArea = areaM2 < 1 ? 1 : areaM2;
        return billableArea * unitPrice;

      case PricingCategory.guneslikBlackout:
        return (width + 0.3) * unitPrice;

      case PricingCategory.kornis:
        return width * unitPrice;

      case PricingCategory.dikeyPerde:
        return width * height * unitPrice;
    }
  }
}
