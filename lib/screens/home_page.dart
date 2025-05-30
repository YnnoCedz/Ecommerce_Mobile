import 'package:final_ecommerce/screens/NewArrivalsPage.dart';
import 'package:final_ecommerce/screens/VouchersPage.dart';
import 'package:final_ecommerce/screens/best_sellers_page.dart';
import 'package:flutter/material.dart';
import 'package:final_ecommerce/routes.dart';
import 'package:final_ecommerce/models/product.dart';
import 'package:final_ecommerce/services/product_services.dart';
import 'package:final_ecommerce/screens/product_details.dart';
import '../services/top_products_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config.dart';
import 'package:final_ecommerce/screens/search_results_page.dart';

void main() {
  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.bookPage);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.moviePage);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.gamePage);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.notifications);
        break;
      case 5:
        Navigator.pushNamed(context, AppRoutes.userMiscPage);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildQuickFilters(context),
            const RecommendationsSection(),
            CategorySection(title: 'Books', category: 'books'),
            CategorySection(title: 'Movies', category: 'movies'),
            CategorySection(title: 'Games', category: 'games'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromRGBO(135, 8, 8, 1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notify',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Container(
      padding: EdgeInsets.fromLTRB(22, 35, 12, 10),
      color: const Color.fromRGBO(135, 8, 8, 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 25,
            child: Image.asset('assets/images/logo_1.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => SearchResultsPage(
                                    query: value,
                                    category:
                                        'all', // Replace with 'all', 'movies', 'games' accordingly
                                  ),
                            ),
                          );
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color.fromRGBO(135, 8, 8, 1),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chatInbox),
            icon: const Icon(Icons.chat, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFilterItem(
              context,
              "assets/icons/best_icon.png",
              "Best\nsellers",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BestSellersPage()),
              ),
            ),
            _buildFilterItem(
              context,
              "assets/icons/new_icon.png",
              "New",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NewArrivalsPage()),
              ),
            ),
            _buildFilterItem(
              context,
              "assets/icons/sale_icon.png",
              "Vouchers",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VouchersPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(
    BuildContext context,
    String iconPath,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(iconPath, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class RecommendationsSection extends StatelessWidget {
  const RecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: TopProductService.fetchTopProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No top-rated products found."));
        }

        final topProducts = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                "Recommendations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 230,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.45),
                itemCount: topProducts.length,
                itemBuilder: (context, index) {
                  final product = topProducts[index];
                  final imageUrl =
                      '${Config.imageBaseUrl}/${product.imagePath}';
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProductDetailsPage(
                                sellerId: product.sellerId,
                                productId: product.productId,
                                title: product.name,
                                image: imageUrl,
                                description:
                                    product.description ??
                                    'No description available.',
                                price: '₱ ${product.price.toStringAsFixed(2)}',
                                storeName: product.storeName,
                                quantitySold: product.quantitySold ?? 0,
                                category: product.category ?? '',
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class CategorySection extends StatefulWidget {
  final String title;
  final String category;

  const CategorySection({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = ProductService.fetchProducts(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No products found."));
            }

            final items = snapshot.data!;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    items.map((item) => _buildCard(context, item)).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Product item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ProductDetailsPage(
                  sellerId: item.sellerId,
                  productId: item.productId,
                  title: item.name,
                  image: '${Config.imageBaseUrl}/${item.imagePath}',
                  description: item.description ?? "No description available.",
                  price: '₱ ${item.price.toStringAsFixed(2)}',
                  storeName: item.storeName,
                  quantitySold: item.quantitySold ?? 0,
                  category: item.category ?? '',
                ),
          ),
        );
      },
      child: SizedBox(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: CachedNetworkImage(
                  imageUrl: '${Config.imageBaseUrl}/${item.imagePath}',
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 1),
                      ),
                  errorWidget:
                      (context, url, error) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "by ${item.storeName}",
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '₱ ${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color.fromRGBO(135, 8, 8, 1),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
