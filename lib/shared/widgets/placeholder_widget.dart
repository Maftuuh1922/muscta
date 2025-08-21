import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';

class PlaceholderWidget extends StatelessWidget {
  final double size;
  final String icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isCircle;

  const PlaceholderWidget({
    super.key,
    this.size = 100,
    this.icon = '👤',
    this.backgroundColor,
    this.iconColor,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: size * 0.4,
            color: iconColor ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class ProfilePlaceholder extends StatelessWidget {
  final double size;
  final String? imageUrl;

  const ProfilePlaceholder({
    super.key,
    this.size = 100,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Check if imageUrl exists and is not empty
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Handle HTTP URLs (Firebase Storage)
      if (imageUrl!.startsWith('http')) {
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipOval(
            child: Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return PlaceholderWidget(size: size, icon: '👤');
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return PlaceholderWidget(size: size, icon: '⏳');
              },
            ),
          ),
        );
      }
      // Handle local file paths
      else if (imageUrl!.startsWith('/')) {
        final file = File(imageUrl!);
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipOval(
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading local image: $error');
                return PlaceholderWidget(size: size, icon: '👤');
              },
            ),
          ),
        );
      }
    }
    
    // Default: gunakan placeholder widget
    return PlaceholderWidget(size: size, icon: '👤');
  }
}

class AlbumPlaceholder extends StatelessWidget {
  final double size;
  final String? imageUrl;

  const AlbumPlaceholder({
    super.key,
    this.size = 100,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Jika ada imageUrl dan tidak kosong, coba load network image
    if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return PlaceholderWidget(size: size, icon: '🎵', isCircle: false);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return PlaceholderWidget(size: size, icon: '⏳', isCircle: false);
            },
          ),
        ),
      );
    }
    
    // Default: gunakan placeholder widget
    return PlaceholderWidget(size: size, icon: '🎵', isCircle: false);
  }
}
