import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_details.dart';

class VisitStorePage extends StatefulWidget {
  final int? sellerId;
  final int? productId;
  final String storeName;

  const VisitStorePage({
    super.key,
    this.sellerId,
    this.productId,
    required this.storeName,
  });

  @override
  State<VisitStorePage> createState() => _VisitStorePageState();
}

class _VisitStorePageState extends State<VisitStorePage> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSellerProducts();
  }

  Future<void> _loadSellerProducts() async {
    try {
      final products = await ProductService.fetchProductsBySeller(
        sellerId: widget.sellerId,
        productId: widget.productId,
      );
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print("Error fetching products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? const Center(child: Text("No products available."))
              : GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final product = _products[index];
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
                                image: product.imagePath,
                                description: product.description ?? '',
                                price: '₱${product.price.toStringAsFixed(2)}',
                                storeName: product.storeName,
                                quantitySold: product.quantitySold ?? 0,
                                category: product.category ?? 'General',
                              ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: product.imagePath,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.broken_image),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "₱${product.price.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
