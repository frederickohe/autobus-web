import 'package:autobus/barrel.dart';
import 'package:autobus/features/autochat/models/chat_message.dart';
import 'package:autobus/features/autochat/services/autochat_repository.dart';

enum _PublicChatStep { phone, company, companyPick, chat }

/// Floating chatbot on the public marketing site (no login required).
class PublicSiteChatbot extends StatefulWidget {
  const PublicSiteChatbot({super.key});

  @override
  State<PublicSiteChatbot> createState() => _PublicSiteChatbotState();
}

class _PublicSiteChatbotState extends State<PublicSiteChatbot> {
  static const _brand = Color(0xFF2A1447);
  static const _accent = CustColors.logodeep;

  final _repo = AutoChatRepository();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  var _open = false;
  var _step = _PublicChatStep.phone;
  var _busy = false;
  String? _error;
  String? _companyNumber;
  String? _companyDisplayName;
  List<CompanyLookupOption> _companyOptions = [];
  final List<ChatMessage> _messages = [];

  @override
  void dispose() {
    _phoneController.dispose();
    _companyController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleOpen() {
    setState(() => _open = !_open);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _submitPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 8) {
      setState(() => _error = 'Enter a valid phone number.');
      return;
    }
    setState(() {
      _error = null;
      _step = _PublicChatStep.company;
    });
  }

  void _beginChatWithCompany({
    required String companyNumber,
    required String displayName,
  }) {
    setState(() {
      _busy = false;
      _companyNumber = companyNumber;
      _companyDisplayName = displayName;
      _companyOptions = [];
      _step = _PublicChatStep.chat;
      _messages.add(
        ChatMessage(
          id: 'welcome',
          userId: _phoneController.text.trim(),
          text:
              'Hi! You are chatting with $displayName. Ask anything about their business.',
          timestamp: DateTime.now(),
          sender: Sender.bot,
          status: MessageStatus.sent,
        ),
      );
    });
    _scrollToBottom();
  }

  Future<void> _submitCompany() async {
    final name = _companyController.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'Enter the company name.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final lookup = await _repo.lookupCompany(name);
      if (!lookup.ok) {
        setState(() {
          _busy = false;
          _error = lookup.message?.isNotEmpty == true
              ? lookup.message
              : 'Company not found.';
        });
        return;
      }

      if (lookup.requiresSelection && lookup.matches.isNotEmpty) {
        setState(() {
          _busy = false;
          _companyOptions = lookup.matches;
          _step = _PublicChatStep.companyPick;
          _error = null;
        });
        return;
      }

      final id = lookup.companyNumber?.trim() ?? '';
      final label = lookup.displayName?.trim().isNotEmpty == true
          ? lookup.displayName!.trim()
          : name;
      if (id.isEmpty) {
        setState(() {
          _busy = false;
          _error = 'Company not found.';
        });
        return;
      }

      _beginChatWithCompany(companyNumber: id, displayName: label);
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _sendChatMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _busy) return;

    final phone = _phoneController.text.trim();
    final companyName = _companyDisplayName ?? _companyController.text.trim();

    setState(() {
      _busy = true;
      _error = null;
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: phone,
          text: text,
          timestamp: DateTime.now(),
          sender: Sender.user,
          status: MessageStatus.sent,
        ),
      );
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final reply = await _repo.sendMessage(
        phone,
        text,
        companyNumber: _companyNumber ?? '',
        companyName: companyName,
        context: 'chatbot_agent',
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _messages.add(reply);
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not send message. Please try again.';
        _messages.add(
          ChatMessage(
            id: '${DateTime.now().millisecondsSinceEpoch}-err',
            userId: phone,
            text: 'Sorry, something went wrong. Please try again.',
            timestamp: DateTime.now(),
            sender: Sender.bot,
            status: MessageStatus.sent,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  Widget _buildCompanyPicker() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Text(
            'Several businesses match. Which one do you mean?',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _brand,
            ),
          ),
          const SizedBox(height: 12),
          ..._companyOptions.map((opt) {
            final label = opt.displayName.trim().isNotEmpty
                ? opt.displayName.trim()
                : opt.companyNumber;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _beginChatWithCompany(
                          companyNumber: opt.companyNumber,
                          displayName: label,
                        ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _brand,
                  side: const BorderSide(color: Color(0xFFDCE0EC)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                ),
              ),
            );
          }),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                      _step = _PublicChatStep.company;
                      _companyOptions = [];
                    }),
            child: Text(
              'Try a different name',
              style: GoogleFonts.montserrat(color: _accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupForm() {
    final isPhone = _step == _PublicChatStep.phone;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isPhone
                ? 'Your phone number'
                : 'Which company do you want to chat with?',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _brand,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: isPhone ? _phoneController : _companyController,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => isPhone ? _submitPhone() : _submitCompany(),
            decoration: InputDecoration(
              hintText: isPhone ? '+233...' : 'e.g. GreenBrain Tech',
              filled: true,
              fillColor: const Color(0xFFF3F4F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.red),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy
                ? null
                : (isPhone ? _submitPhone : _submitCompany),
            style: FilledButton.styleFrom(
              backgroundColor: _brand,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isPhone ? 'Continue' : 'Start chat',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m.sender == Sender.user;
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFEBEBEB) : _brand,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      m.text,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        height: 1.35,
                        color: isUser ? _brand : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _error!,
                style: GoogleFonts.montserrat(fontSize: 11, color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_busy,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendChatMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF3F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _busy ? null : _sendChatMessage,
                  icon: Icon(
                    Icons.send_rounded,
                    color: _busy ? Colors.grey : _brand,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = MediaQuery.sizeOf(context).width < 420 ? 320.0 : 360.0;

    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_open)
            Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Container(
                width: panelWidth,
                height: 460,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E7F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: _brand,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.smart_toy_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _step == _PublicChatStep.chat
                                  ? 'Chat with $_companyDisplayName'
                                  : 'Autobus Assistant',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: _toggleOpen,
                            icon: const Icon(Icons.close, color: Colors.white),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                    if (_step == _PublicChatStep.chat)
                      _buildChatArea()
                    else if (_step == _PublicChatStep.companyPick)
                      _buildCompanyPicker()
                    else
                      _buildSetupForm(),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: _toggleOpen,
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            icon: Icon(_open ? Icons.close : Icons.chat_bubble_outline),
            label: Text(
              _open ? 'Close' : 'Chat with us',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
