import 'package:flutter/material.dart';
import 'package:final_ecommerce/models/product.dart';
import 'package:final_ecommerce/services/product_services.dart';
import 'package:final_ecommerce/screens/product_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config.dart';

class BestSellersPage extends StatelessWidget {
  const BestSellersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Best Sellers'),
        backgroundColor: Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Product>>(
        future: ProductService.fetchBestSellers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No best sellers found.'));
          }

          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3 / 5.4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              final imageUrl = '${Config.imageBaseUrl}/${item.imagePath}';

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
                            image: imageUrl,
                            description:
                                item.description ?? "No description available.",
                            price: '₱ ${item.price.toStringAsFixed(2)}',
                            storeName: item.storeName,
                            quantitySold: item.quantitySold ?? 0,
                            category: item.category ?? '',
                          ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
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
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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
                    const SizedBox(height: 2),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Sold: ${item.quantitySold ?? 0} sold',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
