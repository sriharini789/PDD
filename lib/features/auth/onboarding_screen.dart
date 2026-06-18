import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingData> _pages = [
    const OnboardingData(
      title: 'Understand Research Better with AI',
      description: 'Summarize, analyze and extract insights from research papers instantly.',
      icon: Icons.auto_stories,
      gradientColors: [Color(0xFFE8E0FF), Color(0xFFC7B3FF)],
    ),
    const OnboardingData(
      title: 'Get Context-Aware Citations',
      description: 'Find the right papers and citations based on your research context.',
      icon: Icons.format_quote,
      gradientColors: [Color(0xFFFFE3F0), Color(0xFFFFB3D9)],
    ),
    const OnboardingData(
      title: 'Save Time, Enhance Quality',
      description: 'AI-powered assistance to streamline your research workflow.',
      icon: Icons.speed,
      gradientColors: [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: isDark ? AppColors.primaryDarkAccent : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // PageView Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Container
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: page.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: page.gradientColors[1].withAlpha(60),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 100,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        
                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        // Description
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              // Indicators & Action Button
              Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? (isDark ? AppColors.primaryDarkAccent : AppColors.primary)
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Buttons
                  CustomButton(
                    text: _currentIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentIndex < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}
