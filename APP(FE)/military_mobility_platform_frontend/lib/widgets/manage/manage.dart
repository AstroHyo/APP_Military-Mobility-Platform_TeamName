import 'package:flutter/material.dart';
import 'package:military_mobility_platform_frontend/provider/appbar.dart';
import 'package:military_mobility_platform_frontend/widgets/manage/safety_check_list.dart';
import 'package:military_mobility_platform_frontend/widgets/manage/operation_plan.dart';
import 'package:military_mobility_platform_frontend/widgets/manage/accident_report.dart';
import 'package:military_mobility_platform_frontend/widgets/manage/recovery_team_request.dart';
import 'package:military_mobility_platform_frontend/widgets/manage/emergency_evacuation_request.dart';
import 'package:military_mobility_platform_frontend/widgets/manage/vehicle_return.dart';
import 'package:provider/provider.dart';

class ManageTab extends StatelessWidget {
  const ManageTab({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppBarProvider>(context, listen: false).setTitle('차량관리');
    });
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SafetyCheckList(),
              const Padding(
                padding: EdgeInsets.only(left: 15.0)
              ),
              OperationPlan(),
            ]
          ),
          const Padding(
              padding: EdgeInsets.only(bottom: 40.0)
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AccidentReport(),
              const Padding(
                padding: EdgeInsets.only(left: 15.0)
              ),
              RecoveryTeamRequest(),
            ]
          ),
          const Padding(
              padding: EdgeInsets.only(bottom: 15.0)
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              EmergencyEvacuationRequest(),
              const Padding(
                padding: EdgeInsets.only(left: 20.0)
              ),
              VehicleReturn(),
            ]
          ),
        ]
      ),
    );
  }
}