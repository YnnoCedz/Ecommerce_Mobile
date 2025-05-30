class Config {
  static const String baseUrl = "http://192.168.1.14/bbb_api";
  // static const String baseUrl = "http://172.20.10.3/bbb_api";

  static const String imageBaseUrl = "$baseUrl/static/uploads";

  // Flask backend (for forgot password only)
  static const String flaskBaseUrl = "http://192.168.1.14:5000";
  static const String forgotPasswordEndpoint = "$flaskBaseUrl/forgot_password";

  // Product-related
  static const String productsEndpoint = "$baseUrl/products.php";
  static const String getProductsByCategory = "$baseUrl/get_products.php";
  static const String topProductsEndpoint = "$baseUrl/top_products.php";

  static const String bestSellersEndpoint = "$baseUrl/best_sellers.php";
  static const String newArrivalsEndpoint = "$baseUrl/new_arrivals.php";
  static const String vouchersListEndpoint =
      "$baseUrl/get_vouchers_display.php";

  // Content types
  static const String booksEndpoint = "$baseUrl/books.php";
  static const String moviesEndpoint = "$baseUrl/movies.php";
  static const String gamesEndpoint = "$baseUrl/games.php";

  // Reviews and sellers
  static const String reviewsEndpoint = "$baseUrl/reviews.php";
  static const String sellersEndpoint = "$baseUrl/sellers.php";

  // Auth
  static const String registerEndpoint = "$baseUrl/register_user.php";
  static const String loginEndpoint = "$baseUrl/login_user.php";

  // Cart
  static const String addToCartEndpoint = "$baseUrl/add_to_cart.php";
  static const String updateCartQuantityEndpoint =
      "$baseUrl/update_cart_quantity.php";
  static const String productStockEndpoint = "$baseUrl/get_product_stock.php";
  static const String getCartEndpoint = "$baseUrl/get_cart.php";

  //Checkout
  static const String getUserAddressesEndpoint =
      "$baseUrl/get_user_addresses.php";
  static const String getVouchersEndpoint = "$baseUrl/get_vouchers.php";
  static const String checkoutPostEndpoint = "$baseUrl/checkout_post.php";
  static const String buyNowCheckoutEndpoint = "$baseUrl/buy_now_checkout.php";

  //get by order status
  static const String getReturnsEndpoint = "$baseUrl/get_returns.php";
  // Addresses
  static const String getMainAddressEndpoint = "$baseUrl/get_user_address.php";
  static const String additionalAddresses = "$baseUrl/get_user_address.php";
  static const String getAdditionalAddressesEndpoint =
      "$baseUrl/get_user_additional_addresses.php";
  static const String updateAdditionalAddressEndpoint =
      "$baseUrl/update_additional_user_address.php";
  static const String updateUserAddressEndpoint =
      "$baseUrl/update_user_address.php";

  // Chats
  static const String sendChatMessage = "$baseUrl/chat_with_admin.php";
  static const String getChatMessages = "$baseUrl/get_chat_with_admin.php";
  static const String getUserChatInboxEndpoint = "$baseUrl/get_chat_inbox.php";

  // Seller chat endpoints
  static const String getMessagesWithSellerEndpoint =
      "$baseUrl/get_messages_with_seller.php";
  static const String sendMessageToSellerEndpoint =
      "$baseUrl/send_message_to_seller.php";
  // Seller products
  static const String getProductsBySellerEndpoint =
      "$baseUrl/get_seller_products.php";
}
