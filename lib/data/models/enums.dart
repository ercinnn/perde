enum PricingCategory { tulFon, storZebra, pliseliJaluzi, guneslikBlackout, kornis, dikeyPerde }

enum ProductType {
  tul('Tül', PricingCategory.tulFon),
  fon('Fon', PricingCategory.tulFon),
  guneslik('Güneşlik', PricingCategory.guneslikBlackout),
  blackout('Blackout', PricingCategory.guneslikBlackout),
  karartma('Karartma', PricingCategory.guneslikBlackout),
  stor('Stor', PricingCategory.storZebra),
  zebra('Zebra', PricingCategory.storZebra),
  pliseli('Pliseli', PricingCategory.pliseliJaluzi),
  ahsapJaluzi('Ahşap Jaluzi', PricingCategory.pliseliJaluzi),
  aluminyumJaluzi('Alüminyum Jaluzi', PricingCategory.pliseliJaluzi),
  kornis('Korniş', PricingCategory.kornis),
  dikeyPerde('Dikey Perde', PricingCategory.dikeyPerde);

  const ProductType(this.label, this.category);
  final String label;
  final PricingCategory category;
}

enum RoomType {
  salon('Salon'),
  oturmaOdasi('Oturma Odası'),
  yatakOdasi('Yatak Odası'),
  mutfak('Mutfak'),
  cocukOdasi('Çocuk Odası'),
  arkaOda('Arka Oda'),
  balkon('Balkon'),
  calismaOdasi('Çalışma Odası'),
  koridor('Koridor/Antre');

  const RoomType(this.label);
  final String label;
}

enum DeliveryType {
  montaj('Montaj'),
  eldenTeslim('Elden Teslim'),
  kargo('Kargo');

  const DeliveryType(this.label);
  final String label;
}

enum OrderStatus {
  bekliyor('Bekliyor'),
  hazirlaniyor('Hazırlanıyor'),
  teslimEdildi('Teslim Edildi'),
  iptal('İptal');

  const OrderStatus(this.label);
  final String label;
}

enum PaymentStatus {
  bekliyor('Bekliyor'),
  odendi('Ödendi');

  const PaymentStatus(this.label);
  final String label;
}

enum CashType {
  gelir('Gelir'),
  gider('Gider');

  const CashType(this.label);
  final String label;
}

enum FeatureCalcType {
  sabit('Sabit (tane başı)'),
  yuzde('Yüzde');

  const FeatureCalcType(this.label);
  final String label;
}
