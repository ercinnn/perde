import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes.dart';
import '../supabase/supabase_config.dart';
import '../../shared/widgets/app_shell.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/orders/order_form_screen.dart';
import '../../features/customers/customer_list_screen.dart';
import '../../features/stock/stock_screen.dart';
import '../../features/finance/finance_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/license/license_screen.dart';
import '../../features/business_tools/price_comparison_screen.dart';
import '../../features/business_tools/customer_profit_screen.dart';
import '../../features/business_tools/debt_tracking_screen.dart';
import '../../features/business_tools/weekly_plan_screen.dart';
import '../../features/business_tools/extra_price_list_screen.dart';
import '../../features/business_tools/delivery_calc_screen.dart';
import '../../features/business_tools/calc_note_screen.dart';

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable() {
    _sub = supabase.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: Routes.dashboard,
  refreshListenable: _AuthRefreshListenable(),
  redirect: (context, state) {
    final loggedIn = supabase.auth.currentSession != null;
    final loggingIn = state.matchedLocation == Routes.login;

    if (!loggedIn && !loggingIn) return Routes.login;
    if (loggedIn && loggingIn) return Routes.dashboard;
    return null;
  },
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(currentPath: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: Routes.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: Routes.orderForm,
          builder: (context, state) => const OrderFormScreen(),
        ),
        GoRoute(
          path: Routes.customers,
          builder: (context, state) => const CustomerListScreen(),
        ),
        GoRoute(
          path: Routes.stock,
          builder: (context, state) => const StockScreen(),
        ),
        GoRoute(
          path: Routes.finance,
          builder: (context, state) => const FinanceScreen(),
        ),
        GoRoute(
          path: Routes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: Routes.license,
          builder: (context, state) => const LicenseScreen(),
        ),
        GoRoute(
          path: Routes.priceComparison,
          builder: (context, state) => const PriceComparisonScreen(),
        ),
        GoRoute(
          path: Routes.customerProfit,
          builder: (context, state) => const CustomerProfitScreen(),
        ),
        GoRoute(
          path: Routes.debtTracking,
          builder: (context, state) => const DebtTrackingScreen(),
        ),
        GoRoute(
          path: Routes.weeklyPlan,
          builder: (context, state) => const WeeklyPlanScreen(),
        ),
        GoRoute(
          path: Routes.extraPrices,
          builder: (context, state) => const ExtraPriceListScreen(),
        ),
        GoRoute(
          path: Routes.deliveryCalc,
          builder: (context, state) => const DeliveryCalcScreen(),
        ),
        GoRoute(
          path: Routes.calcNote,
          builder: (context, state) => const CalcNoteScreen(),
        ),
      ],
    ),
  ],
);
