import 'dart:io';

import 'package:autobus/features/home/services/api_service.dart';
import 'package:autobus/features/products/product_form_images.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductGalleryPhoto {
  final String imageId;
  final String url;
  final bool isPrimary;

  const ProductGalleryPhoto({
    required this.imageId,
    required this.url,
    required this.isPrimary,
  });

  factory ProductGalleryPhoto.fromJson(Map<String, dynamic> json) {
    return ProductGalleryPhoto(
      imageId: (json['image_id'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      isPrimary: json['is_primary'] == true,
    );
  }
}

/// Manage uploaded product photos on the edit screen.
class ProductExistingGallery extends StatelessWidget {
  static const double thumbSize = 96;

  final List<ProductGalleryPhoto> photos;
  final bool busy;
  final VoidCallback onAddPhotos;
  final ValueChanged<ProductGalleryPhoto> onPhotoTap;

  const ProductExistingGallery({
    super.key,
    required this.photos,
    required this.busy,
    required this.onAddPhotos,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Product photos',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (photos.isNotEmpty)
              Text(
                '${photos.length} image${photos.length == 1 ? '' : 's'}',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tap a photo to set cover or remove it. Add multiple images at once.',
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: thumbSize + 8,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final photo in photos) ...[
                if (photo != photos.first) const SizedBox(width: 10),
                _ExistingThumb(
                  photo: photo,
                  busy: busy,
                  onTap: () => onPhotoTap(photo),
                ),
              ],
              const SizedBox(width: 10),
              _AddPhotosButton(busy: busy, onTap: onAddPhotos),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExistingThumb extends StatelessWidget {
  final ProductGalleryPhoto photo;
  final bool busy;
  final VoidCallback onTap;

  const _ExistingThumb({
    required this.photo,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: ProductExistingGallery.thumbSize,
            height: ProductExistingGallery.thumbSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: photo.isPrimary
                    ? const Color(0xFFA855F7)
                    : const Color(0xFF3F1163).withValues(alpha: 0.85),
                width: photo.isPrimary ? 1.6 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              photo.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1E0A32),
                alignment: Alignment.center,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          if (photo.isPrimary)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Cover',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPhotosButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;

  const _AddPhotosButton({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: ProductExistingGallery.thumbSize,
        height: ProductExistingGallery.thumbSize,
        decoration: BoxDecoration(
          color: const Color(0xFFA855F7).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFA855F7).withValues(alpha: 0.55),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: const Color(0xFFA855F7).withValues(alpha: 0.9),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              'Add photos',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFFA855F7).withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> showProductPhotoActionsSheet(
  BuildContext context,
  ProductGalleryPhoto photo, {
  required bool canDelete,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: const Color(0xFF1E0A32),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!photo.isPrimary)
            ListTile(
              leading: const Icon(Icons.star_outline, color: Colors.white70),
              title: Text(
                'Set as cover',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              onTap: () => Navigator.pop(ctx, 'primary'),
            ),
          if (canDelete)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: Text(
                'Remove',
                style: GoogleFonts.outfit(color: Colors.redAccent),
              ),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
        ],
      ),
    ),
  );
}

/// Pick and upload multiple photos for an existing product.
Future<void> pickAndUploadProductPhotos({
  required BuildContext context,
  required ApiService api,
  required String productId,
  int maxImages = ProductFormImageSection.maxImages,
  required int currentCount,
}) async {
  final remaining = maxImages - currentCount;
  if (remaining <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You can add up to $maxImages images.')),
    );
    return;
  }

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'],
    allowMultiple: true,
    withData: kIsWeb,
  );
  if (!context.mounted || result == null || result.files.isEmpty) return;

  final picked = result.files.take(remaining).toList();
  if (kIsWeb) {
    final bytesList = <({List<int> bytes, String filename})>[];
    for (final file in picked) {
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) continue;
      final name = file.name.trim().isNotEmpty ? file.name : 'image.jpg';
      bytesList.add((bytes: bytes, filename: name));
    }
    if (bytesList.isEmpty) {
      throw Exception('Unable to load selected images');
    }
    await api.uploadProductPhotos(productId, fileBytes: bytesList);
    return;
  }

  final files = <File>[];
  for (final file in picked) {
    final path = file.path?.trim();
    if (path == null || path.isEmpty) continue;
    final f = File(path);
    if (await f.exists()) files.add(f);
  }
  if (files.isEmpty) {
    throw Exception('Unable to open selected images');
  }
  await api.uploadProductPhotos(productId, files: files);
}
