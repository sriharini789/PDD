import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/api_config.dart';
import '../../../core/router.dart';
import '../../../core/auth_service.dart';
import '../../../core/theme.dart';
import '../../../models/paper_model.dart';

class PaperFullScreen extends StatefulWidget {
  const PaperFullScreen({super.key});

  @override
  State<PaperFullScreen> createState() => _PaperFullScreenState();
}

class _PaperFullScreenState extends State<PaperFullScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PaperModel? _paper;
  bool _isLoading = true;
  String _summaryLevel = 'detailed'; // short, medium, detailed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(() => _loadPaper());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPaper() async {
    final paper = ModalRoute.of(context)?.settings.arguments as PaperModel?;
    if (paper == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _paper = paper;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/papers/${paper.id}'),
        headers: {
          if (authService.token != null) 'Authorization': 'Bearer ${authService.token}',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['paper'] != null) {
          setState(() {
            _paper = PaperModel.fromJson(data['paper']);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading paper: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _launchExport(String format) async {
    if (_paper == null) return;
    final token = authService.token;
    final url = Uri.parse('${ApiConfig.baseUrl}/api/export/${_paper!.id}/$format?token=$token');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch export URL')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = _paper?.title ?? 'Paper';

    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            displayTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark 
                    ? Icons.light_mode_rounded 
                    : Icons.dark_mode_rounded,
                size: 20,
              ),
              onPressed: () {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                themeController.toggleTheme(!isDark);
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Content'),
              Tab(text: 'Citations'),
              Tab(text: 'References'),
              Tab(text: 'Export'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildContentTab(),
                  _buildCitationsTab(),
                  _buildReferencesTab(),
                  _buildExportTab(),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.chatPaper, arguments: _paper),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
          label: const Text('AI Chat', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final verification = _paper?.verification ?? {};
    final summaries = _paper?.summaries ?? {};
    final insights = _paper?.insights ?? {};
    final metrics = _paper?.metrics ?? {};
    final topics = List<String>.from(_paper?.topicsExt['main'] ?? []);
    
    final isVerified = verification['isResearchPaper'] == true;
    final confScore = verification['confidenceScore'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verification
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isVerified ? Colors.green : Colors.orange),
            ),
            child: Row(
              children: [
                Icon(isVerified ? Icons.check_circle : Icons.warning_amber_rounded, 
                  color: isVerified ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isVerified ? 'Verified Research Paper (Confidence: $confScore%)' : 'Not firmly verified as a research paper.',
                    style: TextStyle(color: isVerified ? Colors.green[700] : Colors.orange[800], fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Pages', '${metrics['totalPages'] ?? '-'}'),
              _buildMetric('Words', '${metrics['totalWords'] ?? '-'}'),
              _buildMetric('Read Time', '${metrics['readingTime'] ?? '-'}'),
              _buildMetric('Refs', '${metrics['totalReferences'] ?? '-'}'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Summaries
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _summaryLevel,
                items: const [
                  DropdownMenuItem(value: 'short', child: Text('Short')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'detailed', child: Text('Detailed')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _summaryLevel = val);
                },
              ),
            ],
          ),
          Builder(builder: (context) {
            final summary = summaries[_summaryLevel] ?? _paper?.summary;
            final summaryDisplay = (summary == null || summary.toString().trim().isEmpty) 
                ? 'No summary available.' 
                : summary.toString();
            return SelectableText(
              summaryDisplay,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 15, 
                height: 1.8, // Improved line spacing for neat matter
                letterSpacing: 0.3,
              ),
            );
          }),
          
          if (topics.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            const Text('Main Topics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topics.map((t) => _buildTopicChip(t)).toList(),
            ),
          ],

          if (insights.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            const Text('Key Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            _buildInsight('Problem', insights['researchProblem']),
            _buildInsight('Objective', insights['researchObjective']),
            _buildInsight('Methodology', insights['methodology']),
            _buildInsight('Findings', insights['findings']),
            _buildInsight('Limitations', insights['limitations']),
          ],
          
          const SizedBox(height: 80), // Fab spacing
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInsight(String title, dynamic content) {
    if (content == null || content.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(content.toString(), style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildContentTab() {
    final extracted = _paper?.extractedContent ?? {};
    final hasContent = extracted.isNotEmpty && extracted.values.any((v) => v != null && v.toString().trim().isNotEmpty);
    
    if (!hasContent) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No structured content extracted from this PDF.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildContentSection('Abstract', extracted['abstract']),
        _buildContentSection('Introduction', extracted['introduction']),
        _buildContentSection('Literature Review', extracted['literatureReview']),
        _buildContentSection('Methodology', extracted['methodology']),
        _buildContentSection('Dataset', extracted['dataset']),
        _buildContentSection('Results', extracted['results']),
        _buildContentSection('Discussion', extracted['discussion']),
        _buildContentSection('Conclusion', extracted['conclusion']),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildContentSection(String title, dynamic content) {
    if (content == null || content.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title.toUpperCase(), 
              style: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            content.toString(),
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 15, 
              height: 1.8, // Neat line spacing
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.textDarkPrimary 
                  : AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitationsTab() {
    final citations = _paper?.citations ?? {};
    if (citations.isEmpty) {
      return const Center(child: Text('No citations available.'));
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildCitationCard('APA', citations['apa']),
        _buildCitationCard('MLA', citations['mla']),
        _buildCitationCard('IEEE', citations['ieee']),
        _buildCitationCard('Chicago', citations['chicago']),
        _buildCitationCard('Harvard', citations['harvard']),
        _buildCitationCard('BibTeX', citations['bibtex']),
      ],
    );
  }

  Widget _buildCitationCard(String label, dynamic text) {
    if (text == null || text.toString().isEmpty) return const SizedBox();
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        title: Text('$label Citation', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SelectableText(text.toString(), style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildReferencesTab() {
    final refs = _paper?.references ?? [];
    if (refs.isEmpty) return const Center(child: Text('No references extracted from this document.'));

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: refs.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final ref = refs[index] as Map<String, dynamic>? ?? {};
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[${index + 1}] ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            Expanded(
              child: SelectableText(
                ref['title']?.toString() ?? 'Reference',
                style: const TextStyle(
                  fontSize: 14, 
                  height: 1.6,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportTab() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_rounded, size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Export Summaries & Metadata', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Download the AI-generated insights in your preferred format.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildSmallExportButton('PDF', Icons.picture_as_pdf, Colors.red, () => _launchExport('pdf')),
                _buildSmallExportButton('DOCX', Icons.description, Colors.blue, () => _launchExport('docx')),
                _buildSmallExportButton('TXT', Icons.text_snippet, Colors.grey, () => _launchExport('txt')),
                _buildSmallExportButton('Markdown', Icons.code, Colors.orange, () => _launchExport('md')),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallExportButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ActionChip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text('Export $label'),
      onPressed: onPressed,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
