import 'package:flutter/material.dart';
import '../core/color_manager.dart';

class AppBottomNavMore extends StatelessWidget {
  final List<BottomNavigationBarItem> menus;
  final Function(int index) onSelect;
  final int startIndex;

  const AppBottomNavMore({
    super.key,
    required this.menus,
    required this.onSelect,
    required this.startIndex,
  });

  IconData _extractIcon(BottomNavigationBarItem item) {
    final w = item.icon;
    if (w is Icon) return w.icon!;
    return Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER + CLOSE BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // FIX
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Menu Lainnya",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.textDark,
                    letterSpacing: -0.2,
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: ColorManager.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),


            const SizedBox(height: 18),

            Expanded(
              child: GridView.builder(
                itemCount: menus.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: .95,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (_, i) {
                  final item = menus[i];
                  final iconData = _extractIcon(item);

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();        // <-- FIX
                      onSelect(startIndex + i);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorManager.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ColorManager.cardBorderSoft,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ColorManager.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              iconData,
                              size: 20,
                              color: ColorManager.primary,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            item.label ?? "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.textDark,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // BOTTOM CLOSE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(), // <-- FIX
                child: const Text(
                  "Tutup Menu",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
