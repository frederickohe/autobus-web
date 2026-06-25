import 'dart:io';
import 'dart:typed_data';

import 'package:autobus/features/products/product_chat_image_attachments.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Image gallery section for product create/edit forms (dark theme).
class ProductFormImageSection extends StatelessWidget {
  static const double thumbSize = 96;
  static const int maxImages = 12;

  final List<ProductStagingSlot> slots;
  final ValueChanged<int> onSlotTap;
  final VoidCallback onAddImages;
  final VoidCallback? onRemoveSlot;
  final bool busy;

  const ProductFormImageSection({
    super.key,
    required this.slots,
    required this.onSlotTap,
    required this.onAddImages,
    this.onRemoveSlot,
    this.busy = false,
  });

  int get _filledCount => slots.where((s) => !s.isEmpty).length;

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
            if (_filledCount > 0)
              Text(
                '$_filledCount selected',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Add one or more images. The first photo is used as the cover.',
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
              for (var i = 0; i < slots.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                _FormThumb(
                  slot: slots[i],
                  index: i,
                  isCover: i == 0 && !slots[i].isEmpty,
                  busy: busy,
                  onTap: () => onSlotTap(i),
                ),
              ],
              if (_filledCount < maxImages) ...[
                const SizedBox(width: 10),
                _AddPhotosButton(busy: busy, onTap: onAddImages),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FormThumb extends StatelessWidget {
  final ProductStagingSlot slot;
  final int index;
  final bool isCover;
  final bool busy;
  final VoidCallback onTap;

  const _FormThumb({
    required this.slot,
    required this.index,
    required this.isCover,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final empty = slot.isEmpty;
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: ProductFormImageSection.thumbSize,
            height: ProductFormImageSection.thumbSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCover
                    ? const Color(0xFFA855F7)
                    : const Color(0xFF3F1163).withValues(alpha: 0.85),
                width: isCover ? 1.6 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: empty
                ? Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 28,
                  )
                : _preview(),
          ),
          if (isCover)
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

  Widget _preview() {
    final bytes = slot.previewBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
    }
    final path = slot.localPath;
    if (!kIsWeb && path != null && path.isNotEmpty && File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.cover, gaplessPlayback: true);
    }
    return Icon(
      Icons.broken_image_outlined,
      color: Colors.white.withValues(alpha: 0.35),
      size: 28,
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
        width: ProductFormImageSection.thumbSize,
        height: ProductFormImageSection.thumbSize,
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

/// Pick multiple images and append them to [slots] (up to [maxSlots]).
Future<void> pickMultipleProductImages(
  BuildContext context,
  List<ProductStagingSlot> slots,
  StateSetter setState, {
  int maxSlots = ProductFormImageSection.maxImages,
}) async {
  final remaining = maxSlots - slots.where((s) => !s.isEmpty).length;
  if (remaining <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You can add up to $maxSlots images.')),
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
  final newSlots = <ProductStagingSlot>[];

  for (final file in picked) {
    final name = file.name.trim().isNotEmpty ? file.name : 'image.jpg';
    final slot = ProductStagingSlot()..pickedName = name;

    if (kIsWeb) {
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) continue;
      slot.previewBytes = bytes;
    } else {
      final path = file.path?.trim();
      if (path == null || path.isEmpty) continue;
      slot.localPath = path;
      Uint8List? bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        try {
          bytes = await File(path).readAsBytes();
        } catch (_) {
          bytes = null;
        }
      }
      if (bytes != null && bytes.isNotEmpty) {
        slot.previewBytes = bytes;
      }
    }
    newSlots.add(slot);
  }

  if (newSlots.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to load selected images.')),
    );
    return;
  }

  setState(() {
    slots.removeWhere((s) => s.isEmpty);
    slots.addAll(newSlots);
    if (slots.length < maxSlots) {
      slots.add(ProductStagingSlot());
    }
  });
}

void removeProductStagingSlot(
  List<ProductStagingSlot> slots,
  int index,
  StateSetter setState,
) {
  setState(() {
    if (index < 0 || index >= slots.length) return;
    slots.removeAt(index);
    if (slots.isEmpty) {
      slots.add(ProductStagingSlot());
    } else if (slots.every((s) => !s.isEmpty)) {
      slots.add(ProductStagingSlot());
    }
  });
}
