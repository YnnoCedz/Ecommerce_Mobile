import 'package:flutter/material.dart';
import 'package:final_ecommerce/models/cart_item.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/signup_page.dart';
import 'screens/chats.dart';
import 'screens/chat_inbox.dart';
import 'screens/cart.dart';
import 'screens/in_chat.dart';
import 'screens/product_details.dart';
import 'screens/user_misc.dart';
import 'screens/user_settings.dart';
import 'screens/user_edit_profile.dart';
import 'screens/privacy_settings.dart';
import 'screens/books.dart';
import 'screens/movies.dart';
import 'screens/games.dart';
import 'screens/toShip.dart';
import 'screens/toReceive.dart';
import 'screens/delivered.dart';
import 'screens/completed.dart';
import 'screens/chat_with_admin_page.dart';
import 'screens/forgot_password.dart';
import 'package:final_ecommerce/screens/checkout.dart';
import 'package:final_ecommerce/screens/add_address.dart';
import 'screens/visit_store.dart';

import 'screens/best_sellers_page.dart';
import 'screens/NewArrivalsPage.dart';
import 'screens/VouchersPage.dart';
import 'screens/notifications_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String signup = '/signup';
  static const String chats = '/chats';
  static const String chatInbox = '/chatInbox';
  static const String cart = '/cart';
  static const String inChat = '/in_chat';
  static const String messages = '/messages';
  static const String productDetails = '/product_details';
  static const String userMiscPage = '/user_misc';
  static const String settings = '/settings';
  static const String editProfile = '/edit_profile';
  static const String editAddress = '/edit_address';
  static const String privacySettings = '/privacy_settings';
  static const String bookPage = '/books_page';
  static const String gamePage = '/games_page';
  static const String moviePage = '/movies_page';
  static const String toPayPage = '/toPay';
  static const String toShipPage = '/toShip';
  static const String toReceivePage = '/toReceive';
  static const String deliveredPage = '/deliveredPage';
  static const String completedPage = '/completedPage';
  static const String forgotPassword = '/forgotPassword';
  static const String checkout = '/checkout';
  static const String returnRefundPage = '/returnRefund';
  static const String cancelledPage = '/cancelled';
  static const String userAddresses = '/userAddresses';
  static const String userAddAddresses = '/userAddresses';
  static const String addAddress = '/addAddress';
  static const String chatWithAdminPage = '/ChatWithAdminPage';
  static const String visitStore = '/visitStore';
  static const String bestSellers = '/bestSellers';
  static const String newArrivals = '/newArrivals';
  static const String vouchers = '/vouchers';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    forgotPassword: (context) => const ForgotPasswordPage(),
    home: (context) => const HomePage(),
    signup: (context) => const SignupPage(),
    chats: (context) => const ChatsPage(),
    chatInbox: (context) => const ChatInboxPage(),

    cart: (context) => const CartPage(),
    userMiscPage: (context) => const UserMiscPage(),
    settings: (context) => const UserSettingsPage(),
    editProfile: (context) => const EditProfilePage(),
    privacySettings: (context) => const PrivacySettingsPage(),
    bookPage: (context) => const BooksPage(),
    moviePage: (context) => const MoviesPage(),
    gamePage: (context) => const GamesPage(),
    toShipPage: (context) => const ToShipPage(),
    toReceivePage: (context) => const ToReceivePage(),
    deliveredPage: (context) => const DeliveredPage(),
    completedPage: (context) => const CompletedPage(),

    addAddress: (context) => const AddAddressPage(),
    chatWithAdminPage: (context) => const ChatWithAdminPage(),

    bestSellers: (context) => const BestSellersPage(),
    newArrivals: (context) => const NewArrivalsPage(),
    vouchers: (context) => const VouchersPage(),
    notifications: (context) => const NotificationsPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case inChat:
        final contactName = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => InChatPage(contactName: contactName),
        );

      case productDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => ProductDetailsPage(
                sellerId: args['sellerId'],
                productId: args['productId'],
                title: args['title'],
                image: args['image'],
                description: args['description'],
                price: args['price'],
                storeName: args['storeName'],
                quantitySold: args['quantitySold'] ?? 0,
                category: args['category'],
              ),
        );

      case checkout:
        final args = settings.arguments;
        if (args is List<CartItem>) {
          return MaterialPageRoute(
            builder: (_) => CheckoutPage(selectedItems: args),
          );
        }
        return _errorRoute("Invalid arguments for checkout");

      case AppRoutes.visitStore:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => VisitStorePage(
                sellerId: args['sellerId'] ?? 0,
                productId: args['productId'],
                storeName: args['storeName'] ?? 'Store',
              ),
        );

      default:
        return _errorRoute("Route not found: ${settings.name}");
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text(message)),
          ),
    );
  }
}
