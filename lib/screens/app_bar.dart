import 'dart:ui';
import 'package:flutter/material.dart';
// Relative imports based on folder structure
import 'app_bar_menu/premium_dropdown.dart';
import 'button_buldge.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const PremiumAppBar({
    Key? key,
    this.title = 'QUANTMESSAGE',
    this.actions,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            child: Container(
              height: preferredSize.height,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- 1. LEFT SECTION: LOGO ---
                  leading ??
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.white.withOpacity(0.4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.blur_on, color: Colors.black, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: '__copernicus_669e4a',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              shadows: [Shadow(color: Colors.white30, blurRadius: 12)],
                            ),
                          ),
                        ],
                      ),

                  // --- 2. CENTER SECTION: PREMIUM DROPDOWNS ---
                  if (!isMobile)
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ButtonBulge(
                              child: PremiumDropdown(
                                label: "ABOUT", // FIXED: Added named parameter
                                columns: _getAboutColumns(), // FIXED: Added named parameter
                              ),
                            ),
                            const SizedBox(width: 12),
                            ButtonBulge(
                              child: PremiumDropdown(
                                label: "Platform", // FIXED: Added named parameter
                                columns: _getPlatformColumns(), // FIXED: Added named parameter
                              ),
                            ),
                            const SizedBox(width: 12),
                            ButtonBulge(
                              child: PremiumDropdown(
                                label: "Pricing", // FIXED: Added named parameter
                                columns: _getPricingColumns(), // FIXED: Added named parameter
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // --- 3. RIGHT SECTION: VERSION + HAMBURGER ---
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (screenWidth > 400)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.03),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              const Text('v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                      if (screenWidth > 400) const SizedBox(width: 12),

                      if (isMobile)
                        ButtonBulge(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.menu, color: Colors.white, size: 20),
                                  onPressed: () => Scaffold.of(context).openDrawer(),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for dropdown data
  List<DropdownColumn> _getAboutColumns() {
    return [
      DropdownColumn(title: "PRODUCTS", items: [DropdownItem(title: "QuantMessage", onTap: () {}), DropdownItem(title: "QuantSync", onTap: () {}), DropdownItem(title: "Windcrest", onTap: () {}),]),
      DropdownColumn(title: "FEATURES", items: [DropdownItem(title: "Chrome Extension", onTap: () {}, hasExternalLink: true), DropdownItem(title: "Slack Integration", onTap: () {}), DropdownItem(title: "Microsoft 365", onTap: () {}),]),
      DropdownColumn(title: "MODELS", items: [DropdownItem(title: "Opus", onTap: () {}), DropdownItem(title: "Sonnet", onTap: () {}), DropdownItem(title: "Haiku", onTap: () {}),]),
    ];
  }

  List<DropdownColumn> _getPlatformColumns() {
    return [DropdownColumn(title: "ECOSYSTEM", items: [DropdownItem(title: "API", onTap: () {}, hasExternalLink: true), DropdownItem(title: "Cluster", onTap: () {}), DropdownItem(title: "Documentation", onTap: () {}),])];
  }

  List<DropdownColumn> _getPricingColumns() {
    return [DropdownColumn(title: "PLANS", items: [DropdownItem(title: "Free Tier", onTap: () {}), DropdownItem(title: "Pro Plan", onTap: () {}), DropdownItem(title: "Enterprise", onTap: () {}),])];
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
