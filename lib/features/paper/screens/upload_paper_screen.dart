import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/router.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/api_config.dart';
import '../../../core/auth_service.dart';
import '../../../models/paper_model.dart';

class UploadPaperScreen extends StatelessWidget {
  const UploadPaperScreen({super.key});

  Future<void> _pickPdf(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null) return;

    final file = result.files.single;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uploading ${file.name}'),
      ),
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/papers/upload'),
      );

      if (authService.token != null) {
        request.headers['Authorization'] = 'Bearer ${authService.token}';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

      var response = await request.send();

      var responseBody = await response.stream.bytesToString();
      print(responseBody);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(responseBody);
          if (data['success'] == true) {
            final paper = PaperModel.fromJson(data['paper']);
            Navigator.pushNamed(
              context,
              AppRoutes.uploading,
              arguments: paper,
            );
            return;
          }
        } catch (e) {
          print('Error parsing paper upload response: $e');
        }

        Navigator.pushNamed(
          context,
          AppRoutes.uploading,
        );
      } else {
        print("STATUS CODE: ${response.statusCode}");
        print("RESPONSE: $responseBody");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Upload Paper'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),

              const Text(
                'Upload Research Paper',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              const Text(
                'Add your research paper to start analyzing',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius:
                  BorderRadius.circular(AppBorderRadius.lg),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                      const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color:
                        AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    const Text(
                      'Choose a PDF file',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    const Text(
                      'Upload your own research paper',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    ElevatedButton(
                      onPressed: () => _pickPdf(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Browse Files'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Supported Format: PDF (Max 20MB)',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}