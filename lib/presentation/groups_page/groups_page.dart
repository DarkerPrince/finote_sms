import 'package:finote_sms/logic/sms_bloc.dart';
import 'package:finote_sms/logic/sms_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'group_detail_page.dart';

class GroupsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmsBloc, SmsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text("Groups")),
          body: GridView.builder(
            padding: EdgeInsets.all(12),
            itemCount: state.groups.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailPage(group: group),
                    ),
                  );
                },
                child: Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(group.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("${group.contacts.length} contacts"),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
