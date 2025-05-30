import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_ecommerce/routes.dart';
import '../models/cart_item.dart';

class ProductDetailsPage extends StatefulWidget {
  final int sellerId;
  final int productId;
  final String title;
  final String image;
  final String description;
  final String price;
  final String storeName;
  final int quantitySold;
  final String category;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    required this.title,
    required this.image,
    required this.description,
    required this.price,
    required this.storeName,
    required this.quantitySold,
    required this.category,
    required this.sellerId,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool _showFullDescription = false;
  List<Review> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() async {
    try {
      final reviews = await ReviewService.fetchReviews(widget.productId);
      setState(() {
        _reviews = reviews;
        _loadingReviews = false;
      });
    } catch (e) {
      setState(() => _loadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
          ),

          IconButton(
            icon: const Icon(Icons.home, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.home);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: CachedNetworkImage(
                  imageUrl: widget.image,
                  height: 280,
                  fit: BoxFit.contain,
                  placeholder:
                      (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTitlePriceSection(),
            _buildDescriptionSection(),
            _buildStoreSection(),
            const SizedBox(height: 10),
            _buildReviewSection(),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildTitlePriceSection() => _buildCard(
    children: [
      Text(
        widget.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              widget.price,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(135, 8, 8, 1),
              ),
            ),
          ),
          Text(
            'Sold: ${widget.quantitySold}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildDescriptionSection() => _buildCard(
    children: [
      const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(
        widget.description,
        textAlign: TextAlign.justify,
        style: const TextStyle(fontSize: 14),
        maxLines: _showFullDescription ? null : 2,
        overflow:
            _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
      if (widget.description.length > 100)
        Center(
          child: TextButton(
            onPressed:
                () => setState(
                  () => _showFullDescription = !_showFullDescription,
                ),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(135, 8, 8, 1),
            ),
            child: Text(_showFullDescription ? "Show less" : "Show more"),
          ),
        ),
    ],
  );

  Widget _buildStoreSection() => _buildCard(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.storeName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pushNamed(
              //       context,
              //       AppRoutes.visitStore,
              //       arguments: {
              //         'sellerId': widget.productId,
              //         'storeName': widget.storeName,
              //       },
              //     );
              //   },
              //   style: ElevatedButton.styleFrom(
              //     foregroundColor: const Color.fromARGB(255, 250, 249, 249),
              //     backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     shape: const RoundedRectangleBorder(
              //       borderRadius: BorderRadius.zero,
              //     ),
              //   ),
              //   child: const Text("Visit Store"),
              // ),
            ],
          ),
        ],
      ),
    ],
  );

  bool _showAllReviews = false;
  Widget _buildReviewSection() {
    if (_loadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reviews.isEmpty) return const Text("No reviews yet.");

    // ⭐ Calculate average rating
    double averageRating =
        _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
    int fullStars = averageRating.floor();
    bool hasHalfStar = (averageRating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    // 🔽 Sort and show reviews
    final sortedReviews = [..._reviews]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final displayedReviews =
        _showAllReviews ? sortedReviews : sortedReviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reviews",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        // ⭐ Average Rating with Stars
        Row(
          children: [
            ...List.generate(
              fullStars,
              (_) => const Icon(Icons.star, color: Colors.amber, size: 20),
            ),
            if (hasHalfStar)
              const Icon(Icons.star_half, color: Colors.amber, size: 20),
            ...List.generate(
              emptyStars,
              (_) =>
                  const Icon(Icons.star_border, color: Colors.amber, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              "${averageRating.toStringAsFixed(1)} / 5.0 (${_reviews.length} reviews)",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 💬 Individual Reviews
        ...displayedReviews.map(
          (review) => _buildCard(
            children: [
              Text(
                review.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color:
                        index < review.rating
                            ? Colors.amber
                            : Colors.grey.shade300,
                    size: 16,
                  ),
                ),
              ),
              Text(review.comment),
              const SizedBox(height: 8),
              Text(
                "Posted on ${review.createdAt}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        // 🔽 Show More/Less Button
        if (sortedReviews.length > 3)
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllReviews = !_showAllReviews;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromRGBO(135, 8, 8, 1),
              ),
              child: Text(_showAllReviews ? "Show less" : "Show more"),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color.fromARGB(31, 252, 252, 252), blurRadius: 4),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _showAddToCartModal,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color.fromRGBO(135, 8, 8, 1)),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(color: Color.fromRGBO(135, 8, 8, 1)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _showBuyNowtModal,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text("Buy Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToCartModal() async {
    int? stock = await CartService.fetchProductStock(widget.productId);

    if (stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load product stock.")),
      );
      return;
    }

    int modalQuantity = 1;
    final TextEditingController quantityController = TextEditingController(
      text: modalQuantity.toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: widget.image,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "In stock: $stock",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed:
                                      modalQuantity > 1
                                          ? () {
                                            setModalState(() {
                                              modalQuantity--;
                                              quantityController.text =
                                                  modalQuantity.toString();
                                            });
                                          }
                                          : null,
                                  icon: const Icon(Icons.remove),
                                ),
                                Container(
                                  width: 60,
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: TextFormField(
                                    controller: quantityController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 20),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      final newValue = int.tryParse(value);
                                      if (newValue != null &&
                                          newValue > 0 &&
                                          newValue <= stock) {
                                        setModalState(() {
                                          modalQuantity = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      modalQuantity >= stock
                                          ? null
                                          : () {
                                            setModalState(() {
                                              modalQuantity++;
                                              quantityController.text =
                                                  modalQuantity.toString();
                                            });
                                          },
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getInt('user_id');

                        if (userId == null) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please log in to add to cart."),
                            ),
                          );
                          return;
                        }

                        final response = await CartService.addToCart(
                          userId: userId,
                          productId: widget.productId,
                          quantity: modalQuantity,
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message']),
                            backgroundColor:
                                response['success'] ? Colors.green : Colors.red,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBuyNowtModal() async {
    int? stock = await CartService.fetchProductStock(widget.productId);

    if (stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load product stock.")),
      );
      return;
    }

    int modalQuantity = 1;
    final TextEditingController quantityController = TextEditingController(
      text: modalQuantity.toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: widget.image,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "In stock: $stock",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed:
                                      modalQuantity > 1
                                          ? () {
                                            setModalState(() {
                                              modalQuantity--;
                                              quantityController.text =
                                                  modalQuantity.toString();
                                            });
                                          }
                                          : null,
                                  icon: const Icon(Icons.remove),
                                ),
                                Container(
                                  width: 60,
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: TextFormField(
                                    controller: quantityController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 20),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      final newValue = int.tryParse(value);
                                      if (newValue != null &&
                                          newValue > 0 &&
                                          newValue <= stock) {
                                        setModalState(() {
                                          modalQuantity = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      modalQuantity >= stock
                                          ? null
                                          : () {
                                            setModalState(() {
                                              modalQuantity++;
                                              quantityController.text =
                                                  modalQuantity.toString();
                                            });
                                          },
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getInt('user_id');

                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please log in first."),
                            ),
                          );
                          return;
                        }

                        final response = await CartService.addToCart(
                          userId: userId,
                          productId: widget.productId,
                          quantity: modalQuantity,
                        );

                        if (!response['success'] ||
                            response['cart_id'] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message'] ?? "Failed to add to cart.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final tempItem = CartItem(
                          id: response['cart_id'], // ✅ correct cart_id
                          title: widget.title.trim(),
                          imageUrl: widget.image,
                          price: double.parse(
                            widget.price.replaceAll(RegExp(r'[^\d.]'), ''),
                          ),
                          quantity: modalQuantity,
                          shopName: widget.storeName.trim(),
                          category:
                              widget.category.trim(), // ✅ this is critical
                          stocks: stock,
                          isSelected: true,
                        );

                        Navigator.pushNamed(
                          context,
                          AppRoutes.checkout,
                          arguments: {
                            'items': [tempItem],
                            'productId': widget.productId,
                            'category': widget.category,
                          },
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
