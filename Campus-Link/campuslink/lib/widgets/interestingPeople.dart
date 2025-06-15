import 'package:flutter/material.dart';
import 'package:campuslink/widgets/account_card.dart';

class InterestingPeople extends StatefulWidget {
  const InterestingPeople({super.key});

  @override
  State<InterestingPeople> createState() => _InterestingPeopleState();
}

class _InterestingPeopleState extends State<InterestingPeople> {
  List<dynamic> accounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAccounts(); // ⬅️ Fetch data when the widget loads
  }

  Future<void> fetchAccounts() async {
    // final response = await Supabase.instance.client
    //     .from('posts')
    //     .select()
    //     .order('created_at', ascending: false); // optional sorting

    // Simulating a network request with dummy data
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    final response = [
      {
        'accountImage': 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg',
        'accountName': 'Joe Doe',
        'accountCountry': 'Netherlands',
        'favouriteActivities': 'Reading, Hiking, Gaming',

      },
      {
        'accountImage': 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg',
        'accountName': 'Joe Doe',
        'accountCountry': 'Netherlands',
        'favouriteActivities': 'Reading, Hiking, Gaming',
      },

      {
        'accountImage': 'https://static.wikia.nocookie.net/zelda_gamepedia_en/images/9/9d/Link_TotK.png',
        'accountName': 'Joe Doe',
        'accountCountry': 'Netherlands',
        'favouriteActivities': 'Reading, Hiking, Gaming',
      },
      {
        'accountImage': 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg',
        'accountName': 'Anna P.',
        'accountCountry': 'Germany',
        'favouriteActivities': 'Photography, Cycling',
      },

      {
        'accountImage': 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg',
        'accountName': 'Anna P.',
        'accountCountry': 'Germany',
        'favouriteActivities': 'Photography, Cycling',
      },

      {
        'accountImage': 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg',
        'accountName': 'Anna P.',
        'accountCountry': 'Germany',
        'favouriteActivities': 'Photography, Cycling',
      },

    ];
    // Update the state with the fetched posts
    // Uncomment the above line and comment the below line when using Supabase

    setState(() {
      accounts = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: fetchAccounts, // ⬅️ Called when user pulls down
      child: Scaffold(
        body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            mainAxisExtent: 240.0,

          ),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            return AccountCard(
              accountImage: account['accountImage'],
              accountName: account['accountName'],
              accountCountry: account["accountCountry"] ?? "",
              favouriteActivities: account['favouriteActivities'] ?? "",
            );
          },
        ),
      ),
      )
    );
  }
}
