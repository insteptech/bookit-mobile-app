import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/back_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StickyHeaderScaffold extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool showBackButton;
  final bool showTitle;
  final Widget? headerWidget;
  final bool placeHeaderWidgetAfterSubtitle;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final bool? isButtonDisabled;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomSheet;
  final double? titleToContentSpacing;
  final ScrollPhysics? physics;
  final Widget? progressBar;

  const StickyHeaderScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.buttonText,
    this.onButtonPressed,
    this.showBackButton = true,
    this.showTitle = true,
    this.headerWidget,
    this.placeHeaderWidgetAfterSubtitle = true,
    this.onBackPressed,
    this.contentPadding,
    this.backgroundColor,
    this.isButtonDisabled,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomSheet,
    this.titleToContentSpacing,
    this.physics,
    this.progressBar,
  });

  @override
  State<StickyHeaderScaffold> createState() => _StickyHeaderScaffoldState();
}

class _StickyHeaderScaffoldState extends State<StickyHeaderScaffold>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _titleSlideAnimation;
  
  static const double _titleAnimationThreshold = 100.0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _titleSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scrollController.addListener(_handleScroll);
  }
  
  void _handleScroll() {
    final scrollOffset = _scrollController.offset;
    final animationValue = (scrollOffset / _titleAnimationThreshold).clamp(0.0, 1.0);
    
    _animationController.animateTo(animationValue);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomSheet: widget.bottomSheet,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar (if provided)
            if (widget.progressBar != null) ...[
              Padding(
                padding: widget.contentPadding ?? AppConstants.defaultScaffoldPadding,
                child: Column(
                  children: [
                    const SizedBox(height: AppConstants.scaffoldTopSpacing),
                    widget.progressBar!,
                    const SizedBox(height: 24), // Spacing between progress bar and header
                  ],
                ),
              ),
            ],
            
            // Animated sticky header
            AnimatedBuilder(
              animation: _titleSlideAnimation,
              builder: (context, child) {
                return Container(
                  color: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
                  child: Padding(
                    padding: widget.contentPadding ?? AppConstants.defaultScaffoldPadding,
                    child: SizedBox(
                      height: AppConstants.scaffoldTopSpacing + AppConstants.backButtonIconSize,
                      child: Stack(
                        children: [
                          // Back button (always in same position)
                          if (widget.showBackButton)
                            Positioned(
                              top: AppConstants.scaffoldTopSpacing,
                              left: 0,
                              child: BackIcon(
                                size: AppConstants.backButtonIconSize,
                                onPressed: widget.onBackPressed ?? () => context.pop(),
                              ),
                            ),
                          
                          // Animated title that slides horizontally
                          if (widget.showTitle && _titleSlideAnimation.value > 0)
                            Positioned(
                              top: AppConstants.scaffoldTopSpacing + 2, // slight adjustment for alignment
                              left: _titleSlideAnimation.value * 
                                    (AppConstants.backButtonIconSize + 16), // 16 for spacing
                              child: Opacity(
                                opacity: _titleSlideAnimation.value,
                                child: Text(
                                  widget.title,
                                  style: AppTypography.headingLg.copyWith(
                                    fontSize: 20, // Smaller size for sticky header
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: widget.physics ?? const BouncingScrollPhysics(),
                child: Padding(
                  padding: widget.contentPadding ?? AppConstants.defaultScaffoldPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title in content area (only show when not in sticky mode)
                      AnimatedBuilder(
                        animation: _titleSlideAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: 1.0 - _titleSlideAnimation.value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.showTitle)
                                  Text(
                                    widget.title,
                                    style: AppTypography.headingLg,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      // Subtitle
                      if (widget.showTitle && widget.subtitle != null) ...[
                        SizedBox(height: AppConstants.titleToSubtitleSpacing),
                        Text(
                          widget.subtitle!,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],

                      // Optional header widget placement
                      if (widget.headerWidget != null) ...[
                        SizedBox(
                          height: (widget.showTitle && widget.subtitle != null && widget.placeHeaderWidgetAfterSubtitle)
                              ? AppConstants.contentSpacing
                              : (widget.showTitle && (widget.subtitle == null || !widget.placeHeaderWidgetAfterSubtitle))
                                  ? AppConstants.contentSpacing
                                  : 0,
                        ),
                        widget.headerWidget!,
                      ],
                      
                      SizedBox(
                        height: widget.showTitle
                            ? (widget.titleToContentSpacing ?? AppConstants.headerToContentSpacing)
                            : 0,
                      ),
                      
                      // Main content
                      widget.content,
                      
                      // Add bottom padding to ensure content doesn't get hidden behind fixed button
                      if (widget.buttonText != null && widget.onButtonPressed != null)
                        const SizedBox(height: 80), // Space for fixed button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Fixed bottom button
      bottomNavigationBar: widget.buttonText != null && widget.onButtonPressed != null
          ? Container(
              color: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
              padding: EdgeInsets.only(
                left: (widget.contentPadding ?? AppConstants.defaultScaffoldPadding).horizontal / 2,
                right: (widget.contentPadding ?? AppConstants.defaultScaffoldPadding).horizontal / 2,
                bottom: AppConstants.scaffoldPrimaryButtonBottom,
                top: 8,
              ),
              child: SafeArea(
                child: PrimaryButton(
                  onPressed: widget.onButtonPressed, 
                  isDisabled: widget.isButtonDisabled ?? false, 
                  text: widget.buttonText!
                ),
              ),
            )
          : null,
    );
  }
}