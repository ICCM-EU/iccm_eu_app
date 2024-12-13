import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/full_screen_image.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
  });

  @override
  ImageCarouselState createState() => ImageCarouselState();
}

class ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return SizedBox.shrink();
    } else {
      return Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200, // Adjust height as needed
              viewportFraction: 1.0, // Display one image at a time
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: widget.imageUrls.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                              imageUrl: imageUrl,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        // imageBuilder: (context, imageProvider) => CircleAvatar(
                        //   backgroundImage: imageProvider,
                        //   radius: 50,
                        // ),
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10), // Spacing between carousel and dots
          DotsIndicator(
            dotsCount: widget.imageUrls.length,
            position: _currentIndex,
            decorator: DotsDecorator(
              color: Theme.of(context).colorScheme.secondary, // Inactive dot color
              activeColor: Colors.green, // Active dot color
            ),
          ),
        ],
      );
    }
  }
}