import 'dart:io';

import 'package:flutter/material.dart';

import '../models/card_image_placement.dart';

class CardCustomImage extends StatefulWidget {
  const CardCustomImage({
    super.key,
    required this.path,
    required this.placement,
    required this.cacheWidth,
  });

  final String path;
  final CardImagePlacement placement;
  final int? cacheWidth;

  @override
  State<CardCustomImage> createState() => _CardCustomImageState();
}

class _CardCustomImageState extends State<CardCustomImage> {
  ImageStream? _stream;
  Size? _imageSize;
  late final ImageStreamListener _listener = ImageStreamListener((info, _) {
    if (mounted) {
      setState(
        () => _imageSize = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ),
      );
    }
    info.dispose();
  }, onError: (_, _) {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(CardCustomImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.path != oldWidget.path ||
        widget.cacheWidth != oldWidget.cacheWidth) {
      _imageSize = null;
      _resolveImage();
    }
  }

  ImageProvider get _provider => ResizeImage.resizeIfNeeded(
    widget.cacheWidth,
    null,
    FileImage(File(widget.path)),
  );

  void _resolveImage() {
    _stream?.removeListener(_listener);
    _stream = _provider.resolve(createLocalImageConfiguration(context));
    _stream!.addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = _imageSize;
        if (size == null) {
          return Image(
            image: _provider,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          );
        }
        final rect = widget.placement.imageRect(size, constraints.biggest);
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fromRect(
              rect: rect,
              child: Image(
                image: _provider,
                fit: BoxFit.fill,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}
