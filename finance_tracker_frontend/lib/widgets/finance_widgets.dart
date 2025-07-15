import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

const kCardRadius = 20.0;

/// PUBLIC_INTERFACE
/// Card widget for displaying a transaction item.
class TransactionListTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Color color;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onDelete,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        openColor: color,
        closedColor: color,
        closedElevation: 8,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
        transitionDuration: const Duration(milliseconds: 380),
        openBuilder: (context, _) {
          return Container(); // to be replaced by editing details
        },
        closedBuilder: (context, openContainer) {
          return InkWell(
            borderRadius: BorderRadius.circular(kCardRadius),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    transaction['amount'] >= 0
                        ? const Color(0xFF273944)
                        : const Color(0xFF3d1b2e),
                    color,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(kCardRadius),
                boxShadow: [
                  BoxShadow(
                    color: transaction['amount'] >= 0
                        ? Colors.greenAccent.withValues(alpha: 0.11 * 255)
                        : Colors.redAccent.withValues(alpha: 0.18 * 255),
                    blurRadius: 8,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  width: 1,
                  color: transaction['amount'] >= 0
                      ? Colors.greenAccent.withValues(alpha: 0.08 * 255)
                      : Colors.redAccent.withValues(alpha: 0.12 * 255),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                leading: CircleAvatar(
                  radius: 22,
                  // Uses backgroundColor for transparent look; no unsupported Paint/shader applied
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    transaction['amount'] >= 0 ? Icons.south_west : Icons.north_east,
                    color: transaction['amount'] >= 0 ? Colors.greenAccent : Colors.redAccent,
                    size: 26,
                  ),
                ),
                title: Text(
                  transaction['description'] ?? 'No Description',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  transaction['category'] ?? '',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Wrap(
                  spacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${transaction['amount'] >= 0 ? '+ ' : '- '}\$${(transaction['amount'] as num).abs().toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        color: transaction['amount'] >= 0
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: "Delete",
                        onPressed: onDelete,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// PUBLIC_INTERFACE
/// Card widget for displaying a budget.
class BudgetCard extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final Color color;

  const BudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double percent = (limit > 0) ? (spent / limit).clamp(0.0, 1.0) : 0;
    final statusColor = percent > 0.8
        ? Colors.redAccent
        : (percent > 0.5 ? Colors.orangeAccent : Colors.greenAccent);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.94 * 255),
            color.withValues(alpha: 0.77 * 255),
            Colors.black12,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.04, 0.9, 1],
        ),
        borderRadius: BorderRadius.circular(kCardRadius),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.13 * 255),
            blurRadius: 10,
            offset: const Offset(3, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 0.18,
              ),
            ),
            const SizedBox(height: 11),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 9.8,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  percent > 1.0
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Text(
                  '\$${spent.toStringAsFixed(2)} / \$${limit.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 17),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
