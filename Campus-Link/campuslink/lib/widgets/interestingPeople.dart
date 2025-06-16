import 'package:flutter/material.dart';
import 'package:campuslink/widgets/account_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InterestingPeople extends StatefulWidget {
  const InterestingPeople({super.key});

  @override
  State<InterestingPeople> createState() => _InterestingPeopleState();
}

class _InterestingPeopleState extends State<InterestingPeople> {
  List<Map<String,dynamic>> accounts = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    try {
      final response = await Supabase.instance.client
          .from('account')
          .select() // Fetches all columns
          .order('accountid', ascending: false);

      print('Supabase response: $response');

      setState(() {
        accounts = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      // Handle the error, e.g., show a message or redirect to login
      print('Error fetching accounts: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }


    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load data'),
            ElevatedButton(
              onPressed: fetchAccounts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchAccounts,
      child: Scaffold(
        body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 240.0,

          ),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];


            return AccountCard(
              accountImage: account['profilepictureurl'] ?? "",
              accountName: account['username'],
              accountCountry: account["nationality"] ?? "",
              favouriteActivities: account['favouriteActivities'] ?? "",
              accountId: account['accountid'],
            );
          },
        ),
      ),
      )
    );
  }
}