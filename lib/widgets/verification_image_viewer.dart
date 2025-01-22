import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class VerificationImageViewer extends StatelessWidget {
  final String imageUrl;
  final String userName;

  const VerificationImageViewer({
    super.key,
    required this.imageUrl,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verification Photo - $userName'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event?.expectedTotalBytes != null
                  ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
