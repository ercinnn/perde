import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _date = DateFormat('dd.MM.yyyy');
  static final _currency = NumberFormat('#,##0.00', 'tr_TR');

  static String date(DateTime d) => _date.format(d);

  static String currency(num value) => '${_currency.format(value)} TL';

  static String number(num value) => _currency.format(value);
}
