import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';

/// Reusable Authenticated Patient Avatar widget.
///
/// Features:
/// 1. Automatically resolves relative URLs (e.g. `/api/v1/patients/me/photo/file/...`) to full URLs.
/// 2. Injects `Authorization: Bearer <token>` headers for CareID API endpoints.
/// 3. Supports cache-busting keys/timestamps to ensure newly uploaded images render immediately.
/// 4. Provides smooth loading indicators and graceful fallbacks (Asset Avatar or Initials).
class CareIdAvatar extends StatefulWidget {
  final String? photoUrl;
  final double size;
  final String? name;
  final String? fallbackAsset;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final String? cacheBuster;
  final TokenStorage? tokenStorage;

  const CareIdAvatar({
    super.key,
    this.photoUrl,
    this.size = 96.0,
    this.name,
    this.fallbackAsset = 'assets/images/sarah_jenkins_avatar.png',
    this.border,
    this.boxShadow,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.onTap,
    this.cacheBuster,
    this.tokenStorage,
  });

  @override
  State<CareIdAvatar> createState() => _CareIdAvatarState();
}

class _CareIdAvatarState extends State<CareIdAvatar> {
  String? _accessToken;
  bool _isLoadingToken = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void didUpdateWidget(covariant CareIdAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl ||
        oldWidget.cacheBuster != widget.cacheBuster) {
      _loadToken();
    }
  }

  Future<void> _loadToken() async {
    final storage = widget.tokenStorage ?? AppTokenStorage();
    if (storage is AppTokenStorage && storage.cachedAccessToken != null) {
      if (mounted) {
        setState(() {
          _accessToken = storage.cachedAccessToken;
          _isLoadingToken = false;
        });
      }
      return;
    }

    final token = await storage.getAccessToken();
    if (mounted) {
      setState(() {
        _accessToken = token;
        _isLoadingToken = false;
      });
    }
  }

  String? _resolveFullUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    String fullUrl;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      fullUrl = trimmed;
    } else {
      final base = AppConfig.apiBaseUrl.endsWith('/')
          ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
          : AppConfig.apiBaseUrl;
      final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      fullUrl = '$base$path';
    }

    if (widget.cacheBuster != null && widget.cacheBuster!.isNotEmpty) {
      final separator = fullUrl.contains('?') ? '&' : '?';
      fullUrl = '$fullUrl${separator}t=${widget.cacheBuster}';
    }
    return fullUrl;
  }

  bool _isCareIdBackend(String url) {
    return url.contains('360api.vnvision.in') ||
        url.contains('/api/v1/') ||
        url.startsWith(AppConfig.apiBaseUrl);
  }

  String _getInitials() {
    if (widget.name == null || widget.name!.trim().isEmpty) {
      return 'SJ';
    }
    final parts = widget.name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'SJ';
  }

  Widget _buildFallback() {
    if (widget.fallbackAsset != null && widget.fallbackAsset!.isNotEmpty) {
      return Image.asset(
        widget.fallbackAsset!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitialsFallback(),
      );
    }
    return _buildInitialsFallback();
  }

  Widget _buildInitialsFallback() {
    final initials = _getInitials();
    return Container(
      width: widget.size,
      height: widget.size,
      color: const Color(0xFFEDE9FE),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: widget.size * 0.36,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5B14B8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullUrl = _resolveFullUrl(widget.photoUrl);
    final hasUrl = fullUrl != null && fullUrl.isNotEmpty;

    Map<String, String>? headers;
    if (hasUrl && _isCareIdBackend(fullUrl) && _accessToken != null && _accessToken!.isNotEmpty) {
      headers = {
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'image/*, application/octet-stream, */*',
      };
    }

    Widget content;
    if (!hasUrl) {
      content = _buildFallback();
    } else if (_isLoadingToken && _isCareIdBackend(fullUrl) && _accessToken == null) {
      content = _buildFallback();
    } else {
      content = Image.network(
        fullUrl,
        headers: headers,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildFallback(),
              Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B14B8)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    final avatarShape = widget.shape == BoxShape.circle
        ? ClipOval(child: content)
        : ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.size * 0.2),
            child: content,
          );

    final decorated = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: widget.shape,
        borderRadius: widget.shape == BoxShape.rectangle ? widget.borderRadius : null,
        border: widget.border,
        boxShadow: widget.boxShadow,
      ),
      child: avatarShape,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: decorated,
      );
    }

    return decorated;
  }
}

