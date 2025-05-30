import 'package:flutter/material.dart';
import 'dart:async';
import 'package:final_ecommerce/routes.dart';
import 'package:final_ecommerce/screens/product_details.dart';
import 'package:final_ecommerce/models/game_product.dart';
import 'package:final_ecommerce/services/game_service.dart';
import '../config.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  late PageController _pageController;
  int _currentPage = 0;
  int _selectedIndex = 3;
  bool _showFilters = false;
  final Set<String> _selectedGenres = {};

  Future<bool> _handleWillPop() async {
    if (_showFilters) {
      setState(() {
        _showFilters = false;
      });
      return false; // prevent popping the page
    }
    return true; // allow normal back navigation
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % 5;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

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
      case 5:
        Navigator.pushNamed(context, AppRoutes.userMiscPage);
        break;
      default:
        // Handle other tabs if routes exist
        break;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildQuickFilters(),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            "Recommended Games",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.25,
                          child: FutureBuilder<List<GameProduct>>(
                            future: GameService.fetchGames(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text("Error: ${snapshot.error}"),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text("No recommended Games found."),
                                );
                              }

                              final Games = snapshot.data!;

                              return PageView.builder(
                                controller: _pageController,
                                itemCount: Games.length < 5 ? Games.length : 5,
                                itemBuilder: (context, index) {
                                  final Game = Games[index % Games.length];
                                  final imageUrl =
                                      '${Config.imageBaseUrl}/${Game.imagePath}';
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ProductDetailsPage(
                                                sellerId: Game.sellerId,
                                                productId: Game.productId,
                                                title: Game.name,
                                                image: imageUrl,
                                                description: Game.description,
                                                price:
                                                    "₱ ${Game.price.toStringAsFixed(2)}",
                                                storeName: Game.author,
                                                quantitySold:
                                                    Game.quantitySold ?? 0,
                                                category: Game.category,
                                              ),
                                        ),
                                      );
                                    },
                                    child: AnimatedBuilder(
                                      animation: _pageController,
                                      builder: (context, child) {
                                        double scale = 1.0;
                                        if (_pageController
                                            .position
                                            .haveDimensions) {
                                          scale = _pageController.page! - index;
                                          scale = (1 - (scale.abs() * 0.2))
                                              .clamp(0.8, 1.0);
                                        }
                                        return Transform.scale(
                                          scale: scale,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.broken_image,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        _buildCategorySection(
                          "Games",
                          "Game",
                          MediaQuery.of(context).size.width,
                          context,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_showFilters)
              Positioned(
                top: kToolbarHeight + 45,
                right: 0,
                bottom: 0,
                child: Container(
                  width: 220,
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: _buildGameFilterOptions(),
                  ),
                ),
              ),
          ],
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 35, 12, 10),
      color: const Color.fromRGBO(135, 8, 8, 1),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Image.asset('assets/images/logo_1.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color.fromRGBO(135, 8, 8, 1),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: const Icon(Icons.filter_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFilterItem("assets/icons/best_icon.png", "Best\nsellers"),
            _buildFilterItem("assets/icons/new_icon.png", "New"),
            _buildFilterItem("assets/icons/sale_icon.png", "Sale\nItems"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(String iconPath, String label) {
    return Column(
      children: [
        Image.asset(iconPath, width: 32, height: 32, fit: BoxFit.contain),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGameFilterOptions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fiction",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            _buildGenreCheckboxes([
              "Adventure",
              "Sci-Fi",
              "Romance",
              "Horror",
              "Action",
              "Sports",
            ]),
            const SizedBox(height: 12),
            const Text(
              "Non-Fiction",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            _buildGenreCheckboxes([
              "Autobiography",
              "Documentation",
              "Literature",
              "History",
              "Biography",
            ]),
          ],
        ),

        // Button pinned to bottom
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final filters = _selectedGenres.join(', ');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Applied filters: $filters")),
                );
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                _selectedGenres.isEmpty
                    ? "Apply Filters"
                    : "Apply Filters (${_selectedGenres.length})",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenreCheckboxes(List<String> genres) {
    return Column(
      children:
          genres.map((genre) {
            return CheckboxListTile(
              title: Text(genre, style: const TextStyle(fontSize: 13)),
              value: _selectedGenres.contains(genre),
              activeColor: const Color.fromRGBO(135, 8, 8, 1),
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedGenres.add(genre);
                  } else {
                    _selectedGenres.remove(genre);
                  }
                });
              },
            );
          }).toList(),
    );
  }

  Widget _buildCategorySection(
    String title,
    String prefix,
    double screenWidth,
    BuildContext context,
  ) {
    return FutureBuilder<List<GameProduct>>(
      future: GameService.fetchGames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Games available.'));
        }

        final Games = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: Games.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.50,
                  ),
                  itemBuilder: (context, index) {
                    final Game = Games[index];
                    final imageUrl = '${Config.imageBaseUrl}/${Game.imagePath}';
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailsPage(
                                  sellerId: Game.sellerId,
                                  productId: Game.productId,
                                  title: Game.name,
                                  image: imageUrl,
                                  description: Game.description,
                                  price: "₱ ${Game.price.toStringAsFixed(2)}",
                                  storeName: Game.author,
                                  quantitySold: Game.quantitySold ?? 0,
                                  category: Game.category,
                                ),
                          ),
                        );
                      },
                      child: _buildItem(
                        image: imageUrl,
                        title: Game.name,
                        author: Game.author,
                        price: "₱ ${Game.price.toStringAsFixed(2)}",
                        width: screenWidth * 0.25,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem({
    required String image,
    required String title,
    required String author,
    required String price,
    required double width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            image,
            width: width,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => const Icon(Icons.broken_image),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: width,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            author,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(135, 8, 8, 1),
            ),
          ),
        ),
      ],
    );
  }
}
