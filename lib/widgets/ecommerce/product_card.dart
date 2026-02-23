import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class ProductCard extends StatefulWidget {
  final String name;
  final String price;
  final double rating;
  final String imageUrl;   // 🔥 changed from IconData
  final Color color;
  final double sw;
  final double sh;

  const ProductCard({
    Key? key,
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.color,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Product Image Container
          Container(
            height: widget.sh * 0.15,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.sw * 0.04),
                topRight: Radius.circular(widget.sw * 0.04),
              ),
            ),
            child: Stack(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.sw * 0.04),
                    topRight: Radius.circular(widget.sw * 0.04),
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: widget.sw * 0.1,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // Favorite Button
                Positioned(
                  top: widget.sw * 0.02,
                  right: widget.sw * 0.02,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(widget.sw * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: widget.sw * 0.05,
                        color: isFavorite
                            ? AppColors.darkPink
                            : Colors.black38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(widget.sw * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.sw * 0.032,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: widget.sh * 0.005),

                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: widget.sw * 0.04,
                        color: Colors.amber,
                      ),
                      SizedBox(width: widget.sw * 0.01),
                      Text(
                        widget.rating.toString(),
                        style: TextStyle(
                          fontSize: widget.sw * 0.028,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Price + Add Button
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.price,
                        style: TextStyle(
                          fontSize: widget.sw * 0.035,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkPink,
                        ),
                      ),
                      Container(
                        width: widget.sw * 0.08,
                        height: widget.sw * 0.08,
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(
                            widget.sw * 0.02,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: widget.sw * 0.05,
                          color: AppColors.darkPink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}