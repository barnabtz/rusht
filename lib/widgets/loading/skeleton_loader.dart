import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool isCircle;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceVariant,
        highlightColor: Theme.of(context).colorScheme.surface,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: isCircle
                ? BorderRadius.circular(width / 2)
                : BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
            width: double.infinity,
            height: 200,
            borderRadius: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(
                  width: 200,
                  height: 24,
                  margin: EdgeInsets.only(bottom: 8),
                ),
                const SkeletonLoader(
                  width: 100,
                  height: 16,
                  margin: EdgeInsets.only(bottom: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonLoader(
                      width: 80,
                      height: 16,
                    ),
                    SkeletonLoader(
                      width: 40,
                      height: 40,
                      isCircle: true,
                      borderRadius: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessageSkeleton extends StatelessWidget {
  final bool isMe;

  const ChatMessageSkeleton({
    super.key,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          bottom: 8,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            SkeletonLoader(
              width: 200,
              height: 40,
              borderRadius: 16,
              margin: EdgeInsets.only(
                bottom: 4,
              ),
            ),
            const SkeletonLoader(
              width: 80,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonLoader(
                  width: 100,
                  height: 100,
                  borderRadius: 12,
                  margin: EdgeInsets.only(right: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoader(
                        width: 150,
                        height: 24,
                        margin: EdgeInsets.only(bottom: 8),
                      ),
                      SkeletonLoader(
                        width: 100,
                        height: 16,
                        margin: EdgeInsets.only(bottom: 8),
                      ),
                      SkeletonLoader(
                        width: 120,
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonLoader(
                  width: 80,
                  height: 32,
                  borderRadius: 16,
                ),
                SkeletonLoader(
                  width: 100,
                  height: 32,
                  borderRadius: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
