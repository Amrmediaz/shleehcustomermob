import '../styles/app_theme.dart';
import 'package:flutter/material.dart';

class ImageLoadingWidget extends StatelessWidget {
  final String imageUrl;
  final double? size;
  ImageLoadingWidget({required this.imageUrl, this.size});
  @override
  Widget build(BuildContext context) {
    return imageUrl.contains("http") ?  Image.network(
      height:size,
      width:size,
      fit:BoxFit.fill,
      imageUrl,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(color: primaryColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
    ) : Image.asset(imageUrl);
  }
}
