import 'package:flutter/material.dart';

class AuthFailedPage extends StatelessWidget {
  final VoidCallback onRetry;

  const AuthFailedPage({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.security_outlined,
                color: colorScheme.error),
            const SizedBox(width: 8),
            Text(
              'Authentication Failed',
              style: TextStyle(color: colorScheme.error),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Animation
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.errorContainer.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 100,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 32),

              // Error Message
              Text(
                'Authentication Failed',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Please try again!",
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 48),

              // Retry Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
