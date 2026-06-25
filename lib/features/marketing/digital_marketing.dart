import 'dart:io';
import 'dart:typed_data';

import 'package:autobus/barrel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

const _kPrimary = Color(0xFF1A1A2E);
const _kHeaderPurple = Color(0xFF2A1447);
const _kHeaderBorder = Color(0xFFA92FEB);
const _kNextButtonPurple = Color(0xFF2A1447);
const _kPurple = Color(0xFF6C63FF);
const _kRed = Color(0xFFE63946);

enum MarketingContentType { pictures, videos, text }

enum MediaGenState { idle, generating, ready }

class MarketingContent {
  final MarketingContentType type;
  String? prompt;
  String? manualText;
  String? generatedResult;
  Uint8List? generatedBytes;
  String? localFilePath;
  MediaGenState genState = MediaGenState.idle;

  MarketingContent(this.type);

  String get label {
    switch (type) {
      case MarketingContentType.pictures:
        return 'Pictures';
      case MarketingContentType.videos:
        return 'Videos';
      case MarketingContentType.text:
        return 'Text';
    }
  }

  String get pageTitle {
    switch (type) {
      case MarketingContentType.pictures:
        return 'Generate or Add Image';
      case MarketingContentType.videos:
        return 'Generate or Add Video';
      case MarketingContentType.text:
        return 'Generate or Add Text';
    }
  }

  String get promptHint {
    switch (type) {
      case MarketingContentType.pictures:
        return 'Describe the image content to generate';
      case MarketingContentType.videos:
        return 'Describe the video content to generate';
      case MarketingContentType.text:
        return 'Describe the text content to generate';
    }
  }
}

class DigitalMarketingCampaign {
  final List<MarketingContent> contents;
  DateTime? scheduledDate;
  bool postRightAway = false;
  final Set<String> selectedOutlets = {};

  DigitalMarketingCampaign(this.contents);
}

class _MarketingScaffold extends StatelessWidget {
  final Widget child;
  final double contentHorizontalPadding;

  const _MarketingScaffold({
    required this.child,
    this.contentHorizontalPadding = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 42),

            /// Header to match Chatbot / Orders
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: SizedBox(
                height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kHeaderPurple,
                            border: Border.all(
                              color: _kHeaderBorder,
                              width: 0.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Digital Marketing',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: _kHeaderPurple,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: const UserAvatar(onLightBackground: true),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: contentHorizontalPadding),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  /// Narrower pill used on the generate-media step.
  final bool compact;

  const _DarkButton({
    required this.label,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final height = compact ? 48.0 : 74.0;
    final fontSize = compact ? 14.0 : 16.0;
    final arrowSize = compact ? 11.0 : 14.0;
    final arrowGap = compact ? 7.0 : 10.0;
    final labelArrowGap = compact ? 8.0 : 12.0;
    final hPad = compact ? 18.0 : 22.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: BoxDecoration(
          color: enabled ? _kNextButtonPurple : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(compact ? 36 : 50),
          border: Border.all(
            color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.0),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: enabled ? Colors.white : Colors.white70,
              ),
            ),
            SizedBox(width: labelArrowGap),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  size: arrowSize,
                  color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.7),
                ),
                SizedBox(width: arrowGap),
                Icon(
                  Icons.arrow_forward_ios,
                  size: arrowSize,
                  color: Colors.white.withValues(alpha: enabled ? 0.8 : 0.55),
                ),
                SizedBox(width: arrowGap),
                Icon(
                  Icons.arrow_forward_ios,
                  size: arrowSize,
                  color: Colors.white.withValues(alpha: enabled ? 0.6 : 0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onAttach;
  final VoidCallback? onGenerate;
  final IconData generateIcon;

  const _PromptBar({
    required this.controller,
    required this.hint,
    this.onAttach,
    this.onGenerate,
    this.generateIcon = Icons.auto_awesome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 6,
            onSubmitted: (_) => onGenerate?.call(),
            style: GoogleFonts.montserrat(fontSize: 14, height: 1.45),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black38,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onAttach != null)
                GestureDetector(
                  onTap: onAttach,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CustColors.logodeep.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: CustColors.logodeep,
                      size: 22,
                    ),
                  ),
                )
              else
                const SizedBox(width: 38),
              GestureDetector(
                onTap: onGenerate,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: onGenerate != null
                        ? CustColors.logodeep.withValues(alpha: 0.14)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    generateIcon,
                    color: onGenerate != null ? CustColors.logodeep : Colors.black38,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DigitalMarketingPage extends StatefulWidget {
  final Set<MarketingContentType> initialSelected;

  const DigitalMarketingPage({
    super.key,
    Set<MarketingContentType>? initialSelected,
  }) : initialSelected = initialSelected ?? const <MarketingContentType>{};

  @override
  State<DigitalMarketingPage> createState() => _DigitalMarketingPageState();
}

class _DigitalMarketingPageState extends State<DigitalMarketingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final selected = widget.initialSelected.isNotEmpty
          ? widget.initialSelected
          : <MarketingContentType>{MarketingContentType.pictures};

      final contents = MarketingContentType.values
          .where(selected.contains)
          .map((t) => MarketingContent(t))
          .toList();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _GenerateMediaPage(
            campaign: DigitalMarketingCampaign(contents),
            segmentStartIndex: 0,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MarketingScaffold(
      child: const Center(child: AutobusLoadingIndicator()),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final MarketingContentType type;
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.type,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 148,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _kPrimary : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateMediaPage extends StatefulWidget {
  final DigitalMarketingCampaign campaign;
  /// Index of the first item in this step’s contiguous block (pictures, videos, or text).
  final int segmentStartIndex;

  const _GenerateMediaPage({
    required this.campaign,
    required this.segmentStartIndex,
  });

  @override
  State<_GenerateMediaPage> createState() => _GenerateMediaPageState();
}

class _GenerateMediaPageState extends State<_GenerateMediaPage> {
  final TextEditingController _promptCtrl = TextEditingController();
  final TextEditingController _textBodyCtrl = TextEditingController();

  final ApiService _apiService = ApiService(
    httpClient: SessionAwareHttpClient(tokenService: TokenService()),
  );

  late int _selectedSlotIndex;

  MarketingContentType get _segmentType =>
      widget.campaign.contents[widget.segmentStartIndex].type;

  MarketingContent get _activeContent =>
      widget.campaign.contents[_selectedSlotIndex];

  bool get _isText => _segmentType == MarketingContentType.text;

  List<int> _segmentIndices() {
    final t = _segmentType;
    final out = <int>[];
    for (var i = widget.segmentStartIndex;
        i < widget.campaign.contents.length &&
            widget.campaign.contents[i].type == t;
        i++) {
      out.add(i);
    }
    return out;
  }

  /// First index after this segment’s block (pictures / videos / text).
  int _segmentEndExclusive() {
    return widget.segmentStartIndex + _segmentIndices().length;
  }

  bool get _isMultiSlotMedia =>
      !_isText &&
      (_segmentType == MarketingContentType.pictures ||
          _segmentType == MarketingContentType.videos);

  /// Text step: unchanged. Picture/video: every slot in this segment must have
  /// uploaded or generated media, and nothing may still be generating.
  bool get _canGoNext {
    if (_isText) return true;
    final indices = _segmentIndices();
    final anyGenerating = indices.any(
      (i) =>
          widget.campaign.contents[i].genState == MediaGenState.generating,
    );
    if (anyGenerating) return false;
    for (final i in indices) {
      if (!_slotHasViewableMedia(widget.campaign.contents[i])) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _selectedSlotIndex = widget.segmentStartIndex;
    _promptCtrl.addListener(() => setState(() {}));
    _textBodyCtrl.addListener(() {
      if (_isText) _activeContent.manualText = _textBodyCtrl.text;
    });

    if (_activeContent.manualText != null) {
      _textBodyCtrl.text = _activeContent.manualText!;
    }
    if (_promptCtrl.text.isEmpty && (_activeContent.prompt?.isNotEmpty ?? false)) {
      _promptCtrl.text = _activeContent.prompt!;
    }
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    _textBodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptCtrl.text.trim();
    if (prompt.isEmpty) return;

    final slot = _activeContent;
    setState(() {
      slot.prompt = prompt;
      slot.genState = MediaGenState.generating;
      slot.generatedBytes = null;
      slot.localFilePath = null;
      if (!_isText) slot.generatedResult = null;
    });
    _promptCtrl.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      String userId = '';
      if (userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        userId = (user['id'] ?? user['phone'] ?? '').toString();
      }

      String result = '';

      if (slot.type == MarketingContentType.pictures) {
        final response = await _apiService.generateImageMedia(
          userId: userId,
          prompt: prompt,
        );
        final rawBase64 = (response['image_base64'] ?? '').toString().trim();
        if (rawBase64.isEmpty) {
          throw Exception('Image generation returned no image data');
        }
        final cleanedBase64 = rawBase64.contains(',')
            ? rawBase64.substring(rawBase64.indexOf(',') + 1)
            : rawBase64;
        slot.generatedBytes = await compute(base64Decode, cleanedBase64);
        slot.generatedResult = response['mime_type']?.toString();
      } else if (slot.type == MarketingContentType.videos) {
        // store=true: server saves MP4 to object storage so ExoPlayer can stream it.
        // Raw Google Veo URLs often fail on Android (ExoPlaybackException / source error).
        final response = await _apiService.generateVideoMedia(
          userId: userId,
          prompt: prompt,
          store: true,
        );
        result = (response['stored_url'] ?? response['video_url'] ?? '')
            .toString()
            .trim();
        if (result.isEmpty) {
          throw Exception('Video generation returned no video URL');
        }
        slot.generatedResult = result;
      } else {
        result = await _apiService.generateAgentContent(
          userId: userId,
          prompt: prompt,
          agentName: 'marketing',
        );
        slot.generatedResult = result;
        _textBodyCtrl.text = result;
      }

      if (!mounted) return;
      setState(() {
        slot.genState = MediaGenState.ready;
        if (_isText) _textBodyCtrl.text = result;
      });
      if (slot.type == MarketingContentType.videos) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showMediaPreview(_selectedSlotIndex);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => slot.genState = MediaGenState.idle);

      final message = e is Exception ? e.toString() : 'Media generation failed';

      // Show a friendly snackbar explaining the backend limitation.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.contains('GOOGLE_API_KEY')
                ? 'Image/Video generation is unavailable: server missing configuration.'
                : 'Media generation failed: $message',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _pickAndAttachMedia() async {
    if (_isText) return;

    final allowedExtensions = _activeContent.type == MarketingContentType.pictures
        ? <String>['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp']
        : <String>['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'];

    final isPicture = _activeContent.type == MarketingContentType.pictures;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
      withData: isPicture && kIsWeb,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final path = file.path?.trim();

    if (isPicture) {
      Uint8List? bytes = file.bytes;
      if ((bytes == null || bytes.isEmpty) &&
          !kIsWeb &&
          path != null &&
          path.isNotEmpty) {
        try {
          bytes = await File(path).readAsBytes();
        } catch (_) {
          bytes = null;
        }
      }

      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load selected image. Please try again.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _activeContent.generatedBytes = bytes;
        _activeContent.localFilePath = path;
        _activeContent.generatedResult = file.name;
        _activeContent.genState = MediaGenState.ready;
      });
      return;
    }

    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open selected video. Please try again.'),
        ),
      );
      return;
    }

    setState(() {
      _activeContent.generatedBytes = null;
      _activeContent.localFilePath = path;
      _activeContent.generatedResult = path;
      _activeContent.genState = MediaGenState.ready;
    });
  }

  void _selectSlot(int index) {
    if (!_isMultiSlotMedia) return;
    final busy = _segmentIndices().any(
      (i) =>
          widget.campaign.contents[i].genState == MediaGenState.generating,
    );
    if (busy) return;
    setState(() {
      _selectedSlotIndex = index;
      _promptCtrl.text = _activeContent.prompt ?? '';
    });
  }

  bool _isSlotEmpty(MarketingContent content) {
    if (content.genState == MediaGenState.idle) return true;
    if (content.genState == MediaGenState.ready && !_slotHasViewableMedia(content)) {
      return true;
    }
    return false;
  }

  int? _firstEmptySlotIndex() {
    for (final i in _segmentIndices()) {
      if (_isSlotEmpty(widget.campaign.contents[i])) return i;
    }
    return null;
  }

  void _addAnotherMediaSlot() {
    if (!_isMultiSlotMedia) return;
    final busy = _segmentIndices().any(
      (i) =>
          widget.campaign.contents[i].genState == MediaGenState.generating,
    );
    if (busy) return;

    final emptyIndex = _firstEmptySlotIndex();
    if (emptyIndex != null) {
      setState(() {
        _selectedSlotIndex = emptyIndex;
        _promptCtrl.text = _activeContent.prompt ?? '';
      });
      return;
    }

    setState(() {
      final insertAt = _segmentEndExclusive();
      widget.campaign.contents.insert(
        insertAt,
        MarketingContent(_segmentType),
      );
      _selectedSlotIndex = insertAt;
      _promptCtrl.clear();
    });
  }

  bool _slotHasViewableMedia(MarketingContent content) {
    if (content.genState != MediaGenState.ready) return false;
    if (content.type == MarketingContentType.pictures) {
      final hasBytes = content.generatedBytes != null;
      final localPath = content.localFilePath;
      final hasLocalFile = !kIsWeb &&
          localPath != null &&
          localPath.isNotEmpty &&
          File(localPath).existsSync();
      return hasBytes || hasLocalFile;
    }
    if (content.type == MarketingContentType.videos) {
      final hasRemote = content.generatedResult?.isNotEmpty ?? false;
      final localPath = content.localFilePath;
      final hasLocalFile = !kIsWeb &&
          localPath != null &&
          localPath.isNotEmpty &&
          File(localPath).existsSync();
      return hasRemote || hasLocalFile;
    }
    return false;
  }

  void _onSlotTap(int index) {
    _selectSlot(index);
    if (_slotHasViewableMedia(widget.campaign.contents[index])) {
      _showMediaPreview(index);
    }
  }

  Future<void> _showMediaPreview(int index) async {
    final content = widget.campaign.contents[index];
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) => _MediaSlotPreviewDialog(
        content: content,
        onDelete: () {
          Navigator.of(dialogContext).pop();
          _deleteSlot(index);
        },
      ),
    );
  }

  void _clearSlotMedia(MarketingContent slot) {
    slot.genState = MediaGenState.idle;
    slot.generatedBytes = null;
    slot.localFilePath = null;
    slot.generatedResult = null;
    slot.prompt = null;
  }

  void _deleteSlot(int index) {
    if (!_isMultiSlotMedia) return;
    final busy = _segmentIndices().any(
      (i) =>
          widget.campaign.contents[i].genState == MediaGenState.generating,
    );
    if (busy) return;

    final indices = _segmentIndices();
    if (!indices.contains(index)) return;

    setState(() {
      final slot = widget.campaign.contents[index];
      if (indices.length == 1 || slot.genState == MediaGenState.idle) {
        _clearSlotMedia(slot);
        if (_selectedSlotIndex == index) {
          _promptCtrl.clear();
        }
        return;
      }

      widget.campaign.contents.removeAt(index);
      final newIndices = _segmentIndices();
      if (newIndices.isEmpty) {
        _selectedSlotIndex = widget.segmentStartIndex;
      } else if (!newIndices.contains(_selectedSlotIndex)) {
        final fallback = index < _selectedSlotIndex
            ? _selectedSlotIndex - 1
            : newIndices.last;
        _selectedSlotIndex =
            newIndices.contains(fallback) ? fallback : newIndices.first;
      }
      _promptCtrl.text = _activeContent.prompt ?? '';
    });
  }

  void _goNext() {
    if (_isText) {
      _activeContent.manualText = _textBodyCtrl.text;
    }

    final nextStart = _segmentEndExclusive();
    if (nextStart < widget.campaign.contents.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _GenerateMediaPage(
            campaign: widget.campaign,
            segmentStartIndex: nextStart,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _SchedulePage(campaign: widget.campaign),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGenerate =
        _promptCtrl.text.trim().isNotEmpty &&
        _activeContent.genState != MediaGenState.generating;

    return _MarketingScaffold(
      contentHorizontalPadding: 10,
      child: Column(
        children: [
          Text(
            widget.campaign.contents[widget.segmentStartIndex].pageTitle,
            style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          if (_isText)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildPreviewBox(),
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: _buildMediaSlotsRow(),
                ),
              ),
            ),

          _PromptBar(
            controller: _promptCtrl,
            hint: _activeContent.promptHint,
            onAttach: _isText ? null : _pickAndAttachMedia,
            onGenerate: canGenerate ? _generate : null,
            generateIcon: Icons.auto_awesome,
          ),

          const SizedBox(height: 16),
          _DarkButton(
            label: 'Next',
            compact: true,
            onTap: _canGoNext ? _goNext : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPreviewBox() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _textBodyCtrl,
            maxLines: null,
            expands: true,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Type Text Here...',
              hintStyle: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black38,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_activeContent.genState == MediaGenState.generating)
          _GeneratingOverlay(label: _activeContent.label),
      ],
    );
  }

  Widget _buildMediaSlotsRow() {
    final indices = _segmentIndices();
    final hasEmptySlot = indices.any(
      (i) => _isSlotEmpty(widget.campaign.contents[i]),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _segmentType == MarketingContentType.pictures
              ? 'Tap a slot to select. Tap an image to view or delete it.'
              : 'Tap a slot to select. Tap a video to view or delete it.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 11, color: Colors.black38),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < indices.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    _MediaSlotThumbCard(
                      content: widget.campaign.contents[indices[i]],
                      selected: indices[i] == _selectedSlotIndex,
                      onTap: () => _onSlotTap(indices[i]),
                    ),
                  ],
                  if (!hasEmptySlot) ...[
                    if (indices.isNotEmpty) const SizedBox(width: 10),
                    _AddAnotherMediaSlotCard(
                      type: _segmentType,
                      onTap: _addAnotherMediaSlot,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaSlotThumbCard extends StatelessWidget {
  final MarketingContent content;
  final bool selected;
  final VoidCallback onTap;

  static const _w = 96.0;
  static const _h = 112.0;

  const _MediaSlotThumbCard({
    required this.content,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _w,
        height: _h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kHeaderBorder : CustColors.mainCol.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CustColors.mainCol.withValues(alpha: selected ? 0.12 : 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _thumbFill(),
      ),
    );
  }

  Widget _thumbFill() {
    final isPicture = content.type == MarketingContentType.pictures;
    switch (content.genState) {
      case MediaGenState.idle:
        return ColoredBox(
          color: CustColors.mainCol.withValues(alpha: 0.06),
          child: Center(
            child: Icon(
              isPicture
                  ? Icons.add_photo_alternate_outlined
                  : Icons.video_call_outlined,
              color: CustColors.logodeep.withValues(alpha: 0.7),
              size: 34,
            ),
          ),
        );
      case MediaGenState.generating:
        return ColoredBox(
          color: CustColors.mainCol.withValues(alpha: 0.08),
          child: Center(
            child: const AutobusLoadingIndicator(size: 26),
          ),
        );
      case MediaGenState.ready:
        if (isPicture) {
          final hasBytes = content.generatedBytes != null;
          final localPath = content.localFilePath;
          final hasLocalFile =
              !kIsWeb &&
              localPath != null &&
              localPath.isNotEmpty &&
              File(localPath).existsSync();
          if (hasBytes || hasLocalFile) {
            return hasBytes
                ? Image.memory(
                    content.generatedBytes!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : Image.file(
                    File(localPath!),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  );
          }
        }
        if (!isPicture && (content.generatedResult?.isNotEmpty ?? false)) {
          return ColoredBox(
            color: CustColors.logodeep.withValues(alpha: 0.1),
            child: Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 40,
                color: CustColors.logodeep,
              ),
            ),
          );
        }
        return ColoredBox(
          color: CustColors.logodeep.withValues(alpha: 0.1),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: CustColors.logodeep,
              size: 34,
            ),
          ),
        );
    }
  }
}

/// Plays a generated (remote) or uploaded (local) video inside the app.
class _MarketingInlineVideoPlayer extends StatefulWidget {
  final String videoRef;

  const _MarketingInlineVideoPlayer({required this.videoRef});

  @override
  State<_MarketingInlineVideoPlayer> createState() =>
      _MarketingInlineVideoPlayerState();
}

class _MarketingInlineVideoPlayerState extends State<_MarketingInlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _failed = false;
  String _errorDetail = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ref = widget.videoRef.trim();
    if (ref.isEmpty) {
      if (mounted) {
        setState(() {
          _failed = true;
          _errorDetail = 'No video reference.';
        });
      }
      return;
    }

    final isNetwork =
        ref.startsWith('http://') || ref.startsWith('https://');

    late final VideoPlayerController c;
    if (isNetwork) {
      c = VideoPlayerController.networkUrl(
        Uri.parse(ref),
        httpHeaders: const {
          // Some CDNs / storage endpoints reject requests with no User-Agent.
          'User-Agent': 'Autobus/1.0',
        },
      );
    } else {
      if (kIsWeb) {
        if (mounted) {
          setState(() {
            _failed = true;
            _errorDetail = 'Local file playback is not supported on web.';
          });
        }
        return;
      }
      c = VideoPlayerController.file(File(ref));
    }

    try {
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _controller = c);
      await c.setLooping(true);
      await c.play();
    } catch (e) {
      await c.dispose();
      if (!mounted) return;
      setState(() {
        _failed = true;
        _errorDetail = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Could not load video.\n$_errorDetail',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      );
    }

    final ar = c.value.aspectRatio;
    final ratio = ar > 0 ? ar : 16 / 9;

    return LayoutBuilder(
      builder: (context, constraints) {
        var maxW = constraints.maxWidth;
        var maxH = constraints.maxHeight;
        if (!maxW.isFinite || maxW <= 0) maxW = 320;
        final hasBoundedH = maxH.isFinite && maxH > 0 && maxH < double.infinity;
        if (!hasBoundedH) maxH = maxW / ratio;

        var w = maxW;
        var h = w / ratio;
        if (h > maxH) {
          h = maxH;
          w = h * ratio;
        }

        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(c),
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: c,
                  builder: (context, value, _) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (value.isPlaying) {
                          c.pause();
                        } else {
                          c.play();
                        }
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: value.isPlaying ? 0.0 : 0.35),
                              Colors.black.withValues(alpha: value.isPlaying ? 0.0 : 0.45),
                            ],
                          ),
                        ),
                        child: value.isPlaying
                            ? const SizedBox.expand()
                            : const Icon(
                                Icons.play_circle_fill_rounded,
                                size: 72,
                                color: Colors.white,
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MediaSlotPreviewDialog extends StatelessWidget {
  final MarketingContent content;
  final VoidCallback onDelete;

  const _MediaSlotPreviewDialog({
    required this.content,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPicture = content.type == MarketingContentType.pictures;
    final deleteLabel = isPicture ? 'Delete image' : 'Delete video';

    final maxPreviewHeight = MediaQuery.sizeOf(context).height * 0.55;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxPreviewHeight),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.black,
                child: isPicture ? _buildImagePreview() : _buildVideoPreview(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: CustColors.accentRed),
              label: Text(
                deleteLabel,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: CustColors.accentRed,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: CustColors.accentRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final hasBytes = content.generatedBytes != null;
    final localPath = content.localFilePath;
    final hasLocalFile = !kIsWeb &&
        localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync();

    final image = hasBytes
        ? Image.memory(content.generatedBytes!, fit: BoxFit.contain)
        : Image.file(File(localPath!), fit: BoxFit.contain);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420),
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: hasBytes || hasLocalFile
            ? image
            : const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
              ),
      ),
    );
  }

  Widget _buildVideoPreview(BuildContext context) {
    final videoRef = content.localFilePath ?? content.generatedResult ?? '';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420, minWidth: 280),
      child: _MarketingInlineVideoPlayer(videoRef: videoRef),
    );
  }
}

class _AddAnotherMediaSlotCard extends StatelessWidget {
  final MarketingContentType type;
  final VoidCallback onTap;

  const _AddAnotherMediaSlotCard({
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPicture = type == MarketingContentType.pictures;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _MediaSlotThumbCard._w,
        height: _MediaSlotThumbCard._h,
        decoration: BoxDecoration(
          color: CustColors.mainCol.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CustColors.mainCol.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 36,
              color: CustColors.logodeep,
            ),
            const SizedBox(height: 6),
            Text(
              isPicture ? 'Add image' : 'Add video',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CustColors.mainCol.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdlePreview extends StatelessWidget {
  final MarketingContent content;
  final VoidCallback? onUpload;
  final bool compact;

  const _IdlePreview({
    required this.content,
    this.onUpload,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPicture = content.type == MarketingContentType.pictures;
    final iconSize = compact ? 48.0 : 80.0;
    return GestureDetector(
      onTap: onUpload,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPicture ? Icons.image_rounded : Icons.movie_rounded,
            size: iconSize,
            color: _kPurple,
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            content.label,
            style: GoogleFonts.montserrat(
              fontSize: compact ? 12 : 13,
              color: _kPurple,
            ),
          ),
          if (onUpload != null) ...[
            SizedBox(height: compact ? 6 : 10),
            Text(
              isPicture ? 'Tap to upload your image' : 'Tap to upload your video',
              style: GoogleFonts.montserrat(
                fontSize: compact ? 11 : 12,
                color: Colors.black45,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              Text(
                'or use + below',
                style: GoogleFonts.montserrat(fontSize: 11, color: Colors.black26),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GeneratingOverlay extends StatefulWidget {
  final String label;
  final bool compact;

  const _GeneratingOverlay({
    required this.label,
    this.compact = false,
  });

  @override
  State<_GeneratingOverlay> createState() => _GeneratingOverlayState();
}

class _GeneratingOverlayState extends State<_GeneratingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _fade = Tween<double>(
    begin: 0.35,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.compact;
    return Container(
      color: Colors.white.withOpacity(0.93),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fade,
              child: Container(
                padding: EdgeInsets.all(c ? 14 : 22),
                decoration: BoxDecoration(
                  color: _kPurple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: c ? 30 : 44,
                  color: _kPurple,
                ),
              ),
            ),
            SizedBox(height: c ? 12 : 22),
            FadeTransition(
              opacity: _fade,
              child: Text(
                'Generating...',
                style: GoogleFonts.montserrat(
                  fontSize: c ? 15 : 18,
                  fontWeight: FontWeight.w600,
                  color: _kPrimary,
                ),
              ),
            ),
            SizedBox(height: c ? 4 : 6),
            Text(
              'Creating your ${widget.label.toLowerCase()}',
              style: GoogleFonts.montserrat(
                fontSize: c ? 11 : 13,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyPreview extends StatelessWidget {
  final MarketingContent content;
  final bool compact;

  const _ReadyPreview({
    required this.content,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (content.type == MarketingContentType.pictures) {
      final hasBytes = content.generatedBytes != null;
      final localPath = content.localFilePath;
      final hasLocalFile =
          !kIsWeb && localPath != null && localPath.isNotEmpty && File(localPath).existsSync();

      if (hasBytes || hasLocalFile) {
        final caption = (content.prompt?.trim().isNotEmpty ?? false)
            ? content.prompt!
            : (content.generatedResult ?? 'Uploaded image');

        if (compact) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: hasBytes
                            ? Image.memory(
                                content.generatedBytes!,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              )
                            : Image.file(
                                File(localPath!),
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: hasBytes
                    ? Image.memory(
                        content.generatedBytes!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : Image.file(
                        File(localPath!),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        );
      }
    }

    if (content.type == MarketingContentType.videos &&
        (content.generatedResult?.isNotEmpty ?? false)) {
      final videoRef = content.localFilePath ?? content.generatedResult!;
      final caption = (content.prompt?.trim().isNotEmpty ?? false)
          ? content.prompt!
          : 'Generated video';

      if (compact) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: ColoredBox(
                      color: Colors.black,
                      child: _MarketingInlineVideoPlayer(videoRef: videoRef),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: _MarketingInlineVideoPlayer(videoRef: videoRef),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      );
    }

    if (compact) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 32,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${content.label} ready',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              content.prompt ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 11, color: Colors.black45),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 44,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${content.label} Ready!',
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _kPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            content.prompt ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black45),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SchedulePage extends StatefulWidget {
  final DigitalMarketingCampaign campaign;
  const _SchedulePage({required this.campaign});

  @override
  State<_SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<_SchedulePage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  void _proceed({bool rightAway = false}) {
    widget.campaign.postRightAway = rightAway;
    widget.campaign.scheduledDate = rightAway ? null : _selectedDay;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SelectOutletPage(campaign: widget.campaign),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _MarketingScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Schedule Your Post',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),

          _InlineCalendar(
            focusedMonth: _focusedMonth,
            selectedDay: _selectedDay,
            onDaySelected: (d) => setState(() => _selectedDay = d),
            onMonthChanged: (m) => setState(() => _focusedMonth = m),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () => _proceed(rightAway: true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  'Post Right Away',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _DarkButton(label: 'Next', onTap: () => _proceed()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InlineCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  const _InlineCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  static const _months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    final y = focusedMonth.year;
    final m = focusedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(y, m);
    final firstWeekday = DateTime(y, m, 1).weekday % 7;
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_months[m]} $y',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const TextSpan(
                    text: '  ›',
                    style: TextStyle(
                      color: _kRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => onMonthChanged(DateTime(y, m - 1)),
              child: const Icon(Icons.chevron_left, color: _kRed, size: 28),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onMonthChanged(DateTime(y, m + 1)),
              child: const Icon(Icons.chevron_right, color: _kRed, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _days
              .map(
                (d) => SizedBox(
                  width: 36,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black38,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (_, i) {
            if (i < firstWeekday) return const SizedBox();
            final day = i - firstWeekday + 1;
            final date = DateTime(y, m, day);
            final isToday = DateUtils.isSameDay(date, today);
            final isSel =
                selectedDay != null && DateUtils.isSameDay(date, selectedDay!);

            return GestureDetector(
              onTap: () => onDaySelected(date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSel
                      ? _kRed
                      : isToday
                      ? _kRed.withOpacity(0.12)
                      : null,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: isToday || isSel
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isSel
                        ? Colors.white
                        : isToday
                        ? _kRed
                        : Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SelectOutletPage extends StatefulWidget {
  final DigitalMarketingCampaign campaign;
  const _SelectOutletPage({required this.campaign});

  @override
  State<_SelectOutletPage> createState() => _SelectOutletPageState();
}

class _SelectOutletPageState extends State<_SelectOutletPage> {
  final ApiService _apiService = ApiService(
    httpClient: SessionAwareHttpClient(tokenService: TokenService()),
  );

  /// Blotato-backed accounts from `GET /social/accounts`.
  List<Map<String, dynamic>> _blotatoAccounts = [];

  /// Postiz channels from `GET /social/postiz/integrations`.
  List<PostizIntegration> _postizIntegrations = [];
  bool _loadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    List<PostizIntegration> postiz = [];
    List<Map<String, dynamic>> blotato = [];
    try {
      postiz = await _apiService.listPostizIntegrations();
    } catch (_) {
      // Postiz-only flow: do not fail the whole screen if this call errors.
    }
    try {
      blotato = await _apiService.getSocialAccounts();
    } catch (_) {
      // Blotato is optional when Postiz channels exist.
    }
    if (mounted) {
      setState(() {
        _postizIntegrations = postiz;
        _blotatoAccounts = blotato;
        _loadingAccounts = false;
      });
    }
  }

  bool get _usePostiz => _postizIntegrations.isNotEmpty;

  bool get _useBlotato => !_usePostiz && _blotatoAccounts.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // Prefer Postiz-linked channels (same flow as Link Social Media), then Blotato accounts.
    final useConnected = !_loadingAccounts && (_usePostiz || _useBlotato);
    final gridCount =
        _usePostiz ? _postizIntegrations.length : _blotatoAccounts.length;

    return _MarketingScaffold(
      child: Column(
        children: [
          Text(
            'Select Your Digital Outlet',
            style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),

          if (_loadingAccounts)
            const Expanded(child: Center(child: AutobusLoadingIndicator()))
          else if (!useConnected)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link_off, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No outlets linked yet. Use Link Social Media to connect your social channels in Postiz; they will appear here for publishing.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _DarkButton(
                        label: 'Open Link Social Media',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ManageOutlets(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: gridCount,
                itemBuilder: (_, i) {
                  final String id;
                  final String label;
                  final IconData icon;
                  final Color color;
                  final Widget? avatar;

                  if (_usePostiz) {
                    final p = _postizIntegrations[i];
                    id = p.id;
                    label = p.name.trim().isNotEmpty ? p.name : p.identifier;
                    icon = Icons.public;
                    color = _kPurple;
                    final pic = p.picture?.trim();
                    avatar = pic != null &&
                            (pic.startsWith('http://') || pic.startsWith('https://'))
                        ? CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(pic),
                            onBackgroundImageError: (_, __) {},
                          )
                        : null;
                  } else {
                    final acct = _blotatoAccounts[i];
                    id = acct['id'] as String? ?? '';
                    label =
                        (acct['account_name'] ?? acct['platform'] ?? 'Account')
                            .toString();
                    icon = Icons.link;
                    color = _kPurple;
                    avatar = null;
                  }

                  final sel = widget.campaign.selectedOutlets.contains(id);

                  return GestureDetector(
                    onTap: () => setState(
                      () => sel
                          ? widget.campaign.selectedOutlets.remove(id)
                          : widget.campaign.selectedOutlets.add(id),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: sel ? _kPrimary : Colors.grey.shade200,
                          width: sel ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          avatar ?? Icon(icon, size: 30, color: color),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          _DarkButton(
            label: 'Publish',
            onTap: widget.campaign.selectedOutlets.isNotEmpty ? _publish : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    final selectedIds = widget.campaign.selectedOutlets.toList();
    final textContent = widget.campaign.contents
        .where((c) => c.type == MarketingContentType.text)
        .map((c) => c.manualText ?? c.generatedResult ?? '')
        .where((s) => s.isNotEmpty)
        .join('\n\n');

    final mediaUrls = <String>[];
    for (final c in widget.campaign.contents) {
      if (c.type == MarketingContentType.text) continue;

      final existing = c.generatedResult?.trim();
      if (existing != null &&
          existing.isNotEmpty &&
          (existing.startsWith('http://') || existing.startsWith('https://'))) {
        mediaUrls.add(existing);
        continue;
      }

      final localPath = c.localFilePath?.trim();
      if (!kIsWeb && localPath != null && localPath.isNotEmpty) {
        try {
          final file = File(localPath);
          if (await file.exists()) {
            final url = await _apiService.uploadFile(
              file: file,
              filename: file.uri.pathSegments.isNotEmpty
                  ? file.uri.pathSegments.last
                  : null,
            );
            mediaUrls.add(url);
          }
        } catch (_) {
          // Skip media that could not be uploaded.
        }
      }
    }

    final scheduleTime = widget.campaign.scheduledDate
        ?.toUtc()
        .toIso8601String();

    final canPostiz = _usePostiz;
    final canBlotato = _useBlotato;

    try {
      if (canPostiz) {
        final selected = _postizIntegrations
            .where((p) => selectedIds.contains(p.id))
            .toList();
        if (selected.isEmpty) {
          throw Exception('No matching Postiz channels for the selection.');
        }
        final payload = buildPostizCreatePostPayload(
          selectedIntegrations: selected,
          content: textContent,
          mediaUrls: mediaUrls,
          postRightAway: widget.campaign.postRightAway,
          scheduledUtc: widget.campaign.scheduledDate,
        );
        await _apiService.createPostizPost(
          payload,
          agentName: 'digital_marketing',
        );
      } else if (canBlotato) {
        await _apiService.publishSocialPost(
          accountIds: selectedIds,
          content: textContent,
          mediaUrls: mediaUrls,
          scheduleTime: scheduleTime,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connect an outlet in Marketing → Link Social Media (Postiz) or link a social account, then try again.',
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            canPostiz
                ? (widget.campaign.postRightAway
                    ? 'Posted via Postiz to ${selectedIds.length} channel(s)'
                    : 'Scheduled in Postiz for ${selectedIds.length} channel(s)')
                : 'Published successfully to ${selectedIds.length} account(s)',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Publish failed: $e',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
