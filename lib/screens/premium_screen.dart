import 'package:chatty/widgets/common_appbar.dart';
import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/material.dart';

class PremiumScreen extends CommonStatefulWidget {
  const PremiumScreen({super.key});

  @override
  String title() => "Premium";

  @override
  State<StatefulWidget> createState() => _PremiumScreen();
}

class _PremiumScreen extends State<CommonStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar('Premium'),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 80,
              color: Colors.amber,
            ),
            SizedBox(height: 16),
            Text(
              'Unlock Premium Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Get access to exclusive content and advanced functionality.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  MembershipOption(
                    title: 'Weekly Membership',
                    price: '\$9.99',
                    benefits: [
                      'Access to all premium content for 7 days',
                      'Priority customer support',
                    ],
                  ),
                  MembershipOption(
                    title: 'Monthly Membership',
                    price: '\$29.99',
                    benefits: [
                      'Access to all premium content for 30 days',
                      'Exclusive monthly newsletters',
                    ],
                  ),
                  MembershipOption(
                    title: 'Annual Membership',
                    price: '\$99.99',
                    benefits: [
                      'Access to all premium content for 1 year',
                      'Discounted pricing for special events',
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MembershipOption extends StatelessWidget {
  final String title;
  final String price;
  final List<String> benefits;

  const MembershipOption({
    required this.title,
    required this.price,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Price: $price',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            // ListView.builder(
            //   scrollDirection: Axis.horizontal,
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: benefits.length,
            //   itemBuilder: (context, index) {
            //     return ListTile(
            //       leading: Icon(Icons.check, color: Colors.green),
            //       title: Text(benefits[index]),
            //     );
            //   },
            // ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement subscription logic
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Subscribe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
