import 'package:final_ecommerce/screens/NewArrivalsPage.dart';
import 'package:flutter/material.dart';
import 'package:final_ecommerce/screens/delivered.dart';
import 'package:final_ecommerce/screens/privacy_settings.dart';
import 'routes.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/books.dart';
import 'screens/games.dart';
import 'screens/movies.dart';
import 'screens/signup_page.dart';
// import 'screens/chats.dart';
import 'screens/chat_with_seller.dart';
import 'screens/chat_inbox.dart';
import 'screens/cart.dart';
import 'screens/in_chat.dart';
import 'screens/user_misc.dart';
import 'screens/user_settings.dart';
import 'screens/user_edit_profile.dart';
// import 'screens/edit_address.dart';
import 'screens/chat_with_admin_page.dart';
import 'screens/toPay.dart';
import 'screens/toShip.dart';
import 'screens/toReceive.dart';
import 'screens/completed.dart';
import 'screens/forgot_password.dart';
import 'package:final_ecommerce/screens/checkout.dart';
import 'package:final_ecommerce/models/cart_item.dart';
import 'screens/cancelled.dart';
import 'screens/return_refunded.dart';
import 'screens/user_addresses.dart';
import 'package:final_ecommerce/screens/add_address.dart';
import 'screens/notifications_page.dart';
import 'screens/visit_store.dart';

import 'screens/best_sellers_page.dart';
import 'screens/VouchersPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      theme: ThemeData(primarySwatch: Colors.red, fontFamily: 'Alexandria'),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordPage(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.signup: (context) => const SignupPage(),
        AppRoutes.chatInbox: (context) => const ChatInboxPage(),
        AppRoutes.cart: (context) => const CartPage(),
        AppRoutes.userMiscPage: (context) => const UserMiscPage(),
        AppRoutes.settings: (context) => const UserSettingsPage(),
        AppRoutes.privacySettings: (context) => const PrivacySettingsPage(),
        AppRoutes.bookPage: (context) => const BooksPage(),
        AppRoutes.gamePage: (context) => const GamesPage(),
        AppRoutes.moviePage: (context) => const MoviesPage(),
        AppRoutes.toPayPage: (context) => const ToPayPage(),
        AppRoutes.toShipPage: (context) => const ToShipPage(),
        AppRoutes.toReceivePage: (context) => const ToReceivePage(),
        AppRoutes.completedPage: (context) => const CompletedPage(),
        AppRoutes.deliveredPage: (context) => const DeliveredPage(),
        AppRoutes.returnRefundPage: (context) => const ReturnRefundPage(),
        AppRoutes.cancelledPage: (context) => const CancelledPage(),
        AppRoutes.userAddresses: (context) => const AddressesPage(),
        AppRoutes.addAddress: (context) => const AddAddressPage(),
        AppRoutes.editProfile: (context) => const EditProfilePage(),
        AppRoutes.chatWithAdminPage: (context) => const ChatWithAdminPage(),
        AppRoutes.bestSellers: (context) => const BestSellersPage(),
        AppRoutes.newArrivals: (context) => const NewArrivalsPage(),
        AppRoutes.vouchers: (context) => const VouchersPage(),
        AppRoutes.notifications: (context) => const NotificationsPage(),

        AppRoutes.visitStore: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return VisitStorePage(
            sellerId: args['sellerId'],
            storeName: args['storeName'],
          );
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.inChat) {
          final contactName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => InChatPage(contactName: contactName),
          );
        }

        if (settings.name == AppRoutes.checkout) {
          final args = settings.arguments as Map<String, dynamic>;
          final itemList = args['items'] as List<CartItem>;

          return MaterialPageRoute(
            builder:
                (_) => CheckoutPage(
                  selectedItems: itemList,
                  productId: args['productId'],
                ),
          );
        }
        if (settings.name == AppRoutes.messages) {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder:
                (context) => ChatWithSellerPage(
                  storeName: args['storeName'],
                  sellerId: args['sellerId'],
                ),
          );
        }

        return _errorRoute("Route not found.");
      },
    );
  }

  /// ⛔ Error route fallback handler
  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text(message)),
          ),
    );
  }
}
