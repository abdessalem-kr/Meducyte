import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/dashboard/widgets/statistics_mini_card.dart';
import 'package:meducyte_app/features/dashboard/widgets/in_progress_card.dart';
import 'package:meducyte_app/features/dashboard/widgets/medical_suggestion_card.dart';
import 'package:meducyte_app/features/dashboard/widgets/srs_due_card.dart';

class DashboardCardsCarousel extends StatefulWidget {
  const DashboardCardsCarousel({super.key});

  @override
  State<DashboardCardsCarousel> createState() => _DashboardCardsCarouselState();
}

class _DashboardCardsCarouselState extends State<DashboardCardsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          //Render side-by-side on wide screens
          return const SizedBox(
            height: 210,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: StatisticsMiniCard(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: InProgressCard(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: MedicalSuggestionCard(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: SrsDueCard(),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 210, //Fixed height for consistency
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: StatisticsMiniCard(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: InProgressCard(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: MedicalSuggestionCard(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: SrsDueCard(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            //Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentPage == index ? 20 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : Theme.of(context).dividerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
