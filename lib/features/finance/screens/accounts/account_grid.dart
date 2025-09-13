import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/profile_card.dart';
import 'package:ppv_components/core/utils/account_status_colors.dart';
import 'package:ppv_components/core/utils/responsive.dart';
import 'package:ppv_components/features/finance/data/mock_account_db.dart';

class AccountGridView extends StatefulWidget {
  const AccountGridView({super.key});

  @override
  State<AccountGridView> createState() => _AccountGridViewState();
}

class _AccountGridViewState extends State<AccountGridView> {
  int? _hoveredCardIndex; //  track the hovered card index
  int toggleIndex = 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = getResponsiveCrossAxisCount(screenWidth);

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: mockAccounts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                final account = mockAccounts[index];
                final isHovered = _hoveredCardIndex == index; // Determine if current card is hovered

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredCardIndex = index), // Set hovered index on enter
                  onExit: (_) => setState(() => _hoveredCardIndex = null), // Clear hovered index on exit
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 4),
                    decoration: BoxDecoration(
                      border: isHovered
                          ? Border(
                        top: BorderSide(
                          color: getAccountTypeColor(account.type), // Use account type color for the border
                          width: 6,
                        ),
                        left: BorderSide(
                          color: getAccountTypeColor(account.type), // Use account type color for the border
                          width: 6,
                        ),
                      )
                          :null, // Transparent border when not hovered
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                    child: ProfileInfoCard(
                      title: account.code,
                      company: account.name,
                      email: account.type,
                      phone: account.balance,
                      source: account.balance,
                      topBarColor: getAccountTypeColor(account.type),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}