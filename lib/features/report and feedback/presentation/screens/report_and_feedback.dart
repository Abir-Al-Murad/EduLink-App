import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';
import 'package:universityclassroommanagement/features/report%20and%20feedback/presentation/controllers/report_and_feedback_controller.dart';

import '../../../shared/presentaion/widgets/ShowSnackBarMessage.dart';

class ReportAndFeedback extends StatefulWidget {
  const ReportAndFeedback({super.key});

  static const name = '/report';

  @override
  State<ReportAndFeedback> createState() => _ReportAndFeedbackState();
}

class _ReportAndFeedbackState extends State<ReportAndFeedback> {
  final TextEditingController _reportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report and feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _reportController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Report",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            GetBuilder<ReportAndFeedBackController>(
                builder: (controller) {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Visibility(
                      visible: controller.isLoading == false,
                      replacement: Center(child: CircularProgressIndicator(),),
                      child: ElevatedButton(
                        onPressed: ()async{
                          if(_reportController.text.isEmpty){
                            ShowSnackBarMessage(context, "Please fill the form");
                          }else{
                            bool result = await controller.addReportAndFeedback(AuthController.user!.email, AuthController.user!.name, _reportController.text.trim());
                            if(result){
                              ShowSnackBarMessage(context, "Report Submitted Successfully");
                              Navigator.pop(context,true);
                            }
                          }

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:Text(
                          "Submit",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }
            ),
          ],
        ),
      ),

    );
  }
}
