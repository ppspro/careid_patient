import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// CareID Live Chat & Care Team Messaging Screen
/// Faithfully reproduces Figma frame node 20:31689 ("Live_chat_messeges", 390x1117)
/// Located on canvas "Careid patient app" (node 17:55).
class LiveChatScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String? conversationTitle;
  final String? participantSubtitle;
  final String language;

  const LiveChatScreen({
    super.key,
    this.doctorName = 'Dr. Sarah Jenkins, MD',
    this.specialty = 'Cardiology & Internal Medicine',
    this.conversationTitle,
    this.participantSubtitle,
    this.language = 'en',
  });

  String get effectiveTitle => conversationTitle ?? doctorName;
  String get effectiveSubtitle => participantSubtitle ?? specialty;

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'isMe': false,
        'sender': widget.doctorName,
        'text': 'Hello Sarah, I reviewed your latest cardiology lab panel. Your blood pressure and ECG metrics look steady.',
        'time': '09:41 AM',
      },
      {
        'isMe': true,
        'sender': 'Me',
        'text': "Thank you Dr. Jenkins! I've been taking the prescribed Lisinopril 10mg each morning with breakfast as instructed.",
        'time': '09:43 AM',
      },
      {
        'isMe': false,
        'sender': widget.doctorName,
        'text': "Excellent adherence. Let's continue this regimen for 2 weeks. You can also share your daily systolic log directly through your CareID vault pass.",
        'time': '09:45 AM',
      },
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isEn => widget.language == 'en';

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'isMe': true,
        'sender': 'Me',
        'text': text,
        'time': '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
      });
      _messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.purpleLight,
              child: Text(
                widget.effectiveTitle.replaceAll('Dr. ', '').split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                style: const TextStyle(color: AppColors.purplePrimary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.effectiveTitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isEn ? 'Active in CareID Clinic' : 'En línea en CareID',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppColors.purplePrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEn ? 'Telehealth video room will open at appointment time.' : 'La sala se abrirá a la hora de la cita.'),
                  backgroundColor: AppColors.purplePrimary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppColors.purplePrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEn ? 'Direct audio line connected to clinic desk.' : 'Línea de audio conectada con la clínica.'),
                  backgroundColor: AppColors.purplePrimary,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. End-to-End Encryption Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFEDE9FE),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 16, color: AppColors.purplePrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isEn
                          ? 'Your conversations are end-to-end encrypted and shared only with verified, authorized healthcare participants.'
                          : 'Tus conversaciones están cifradas de extremo a extremo y protegidas por CareID.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF5B14B8), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Chat messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['isMe'] as bool;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.purplePrimary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text'] as String,
                            style: TextStyle(
                              color: isMe ? Colors.white : AppColors.textPrimary,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg['time'] as String,
                            style: TextStyle(
                              color: isMe ? Colors.white70 : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. Message Input Composer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderMedium)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isEn ? 'Select health record to share with care team.' : 'Selecciona un registro médico para compartir.'),
                          backgroundColor: AppColors.purplePrimary,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: _isEn ? 'Message care team...' : 'Mensaje para el médico...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.purplePrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
