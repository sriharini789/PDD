import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

          // Summaries Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _summaryLevel,
                items: const [
                  DropdownMenuItem(value: 'short', child: Text('Short Summary')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium Summary')),
                  DropdownMenuItem(value: 'detailed', child: Text('Detailed Summary')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _summaryLevel = val);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Builder(builder: (context) {
            final summary = summaries[_summaryLevel] ?? _paper?.summary;
            final summaryDisplay = (summary == null || summary.toString().trim().isEmpty) 
                ? 'No summary available.' 
                : summary.toString();

            // Format Short and Medium as bullet points
            if (_summaryLevel == 'short' || _summaryLevel == 'medium' || summaryDisplay.trim().startsWith('-')) {
              final bullets = summaryDisplay
                  .split('\n')
                  .map((e) => e.trim().replaceFirst(RegExp(r'^[-*•]\s*'), ''))
                  .where((e) => e.isNotEmpty)
                  .toList();
                  
              if (bullets.isNotEmpty) {
                return Column(
                  children: bullets.map((bullet) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6.0, right: 8.0, left: 4.0),
                          child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                        ),
                        Expanded(
                          child: SelectableText(
                            bullet,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                );
              }
            }

            // Paragraph layout for detailed summaries
            return SelectableText(
              summaryDisplay,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 14, 
                height: 1.6,
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
            _buildInsightCard('Research Problem', Icons.help_outline_rounded, insights['researchProblem'] ?? insights['problem']),
            _buildInsightCard('Objective', Icons.track_changes_rounded, insights['objective'] ?? insights['researchObjective']),
            _buildInsightCard('Dataset Used', Icons.storage_rounded, insights['datasetUsed']),
            _buildInsightCard('Algorithms Used', Icons.psychology_rounded, insights['algorithmsUsed']),
            _buildInsightCard('Experimental Results', Icons.science_outlined, insights['experimentalResults']),
            _buildInsightCard('Accuracy / Performance Metrics', Icons.query_stats_rounded, insights['performanceMetrics']),
            _buildInsightCard('Findings', Icons.lightbulb_outline_rounded, insights['findings']),
            _buildInsightCard('Limitations', Icons.block_rounded, insights['limitations']),
            _buildInsightCard('Future Scope', Icons.explore_outlined, insights['futureScope']),
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

  Widget _buildInsightCard(String title, IconData icon, dynamic content) {
    if (content == null || content.toString().trim().isEmpty) return const SizedBox();
    
    final text = content.toString();
    final bullets = text
        .split('\n')
        .map((e) => e.trim().replaceFirst(RegExp(r'^[-*•]\s*'), ''))
        .where((e) => e.isNotEmpty)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary, size: 20),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bullets.isNotEmpty)
            ...bullets.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0, right: 8.0),
                    child: Icon(Icons.circle, size: 5, color: Colors.grey),
                  ),
                  Expanded(
                    child: SelectableText(
                      b,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            )).toList()
          else
            SelectableText(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
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
        // Metadata Core Card
        Card(
          margin: const EdgeInsets.only(bottom: 20),
          color: AppColors.primary.withOpacity(0.04),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('METADATA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                SelectableText('Title: ${_paper?.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                SelectableText('Authors: ${_paper?.authors}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                if (extracted['keywords'] != null) ...[
                  const SizedBox(height: 12),
                  SelectableText('Keywords: ${extracted['keywords']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        ),

        _buildContentCard('Abstract', Icons.notes_rounded, extracted['abstract']),
        _buildContentCard('Introduction', Icons.menu_book_rounded, extracted['introduction'], isBulletSection: true),
        _buildContentCard('Literature Review', Icons.rate_review_outlined, extracted['literatureReview']),
        _buildContentCard('Methodology', Icons.architecture_rounded, extracted['methodology'], isBulletSection: true),
        _buildContentCard('Dataset', Icons.analytics_rounded, extracted['dataset']),
        _buildContentCard('Results', Icons.fact_check_outlined, extracted['results'], isBulletSection: true),
        _buildContentCard('Conclusion', Icons.task_alt_rounded, extracted['conclusion'], isBulletSection: true),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildContentCard(String title, IconData icon, dynamic content, {bool isBulletSection = false}) {
    if (content == null || content.toString().trim().isEmpty) return const SizedBox();

    final text = content.toString();
    final bullets = text
        .split('\n')
        .map((e) => e.trim().replaceFirst(RegExp(r'^[-*•]\s*'), ''))
        .where((e) => e.isNotEmpty)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            if (isBulletSection && bullets.isNotEmpty)
              ...bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6.0, right: 8.0, left: 4.0),
                      child: Icon(Icons.circle, size: 5, color: AppColors.primary),
                    ),
                    Expanded(
                      child: SelectableText(
                        b,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList()
            else
              SelectableText(
                text,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
          ],
        ),
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
    final citationText = text.toString();
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
          child: SelectableText(citationText, style: const TextStyle(fontSize: 13)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: citationText));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label Citation copied to clipboard!'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReferencesTab() {
    final refs = _paper?.references ?? [];
    if (refs.isEmpty) return const Center(child: Text('No references extracted from this document.'));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: refs.length,
      itemBuilder: (context, index) {
        final ref = refs[index] as Map<String, dynamic>? ?? {};
        
        final rTitle = ref['title']?.toString() ?? 'Unknown Title';
        final rAuthors = ref['authors']?.toString() ?? 'Unknown Authors';
        final rJournal = ref['journal']?.toString() ?? 'Academic Proceeding';
        final rYear = ref['year']?.toString() ?? '';
        final rDoi = ref['doi']?.toString() ?? '';
        final rUrl = ref['url']?.toString() ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(
                        rTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people_outline_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rAuthors,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.article_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$rJournal${rYear.isNotEmpty ? " ($rYear)" : ""}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if ((rDoi.isNotEmpty && rDoi != 'N/A') || rUrl.isNotEmpty) ...[
                  const Divider(height: 16),
                  Row(
                    children: [
                      if (rDoi.isNotEmpty && rDoi != 'N/A') ...[
                        ActionChip(
                          label: const Text('Copy DOI', style: TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: rDoi));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('DOI copied to clipboard!'), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (rUrl.isNotEmpty)
                        ActionChip(
                          avatar: const Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.primary),
                          label: const Text('Open URL', style: TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onPressed: () async {
                            final uri = Uri.parse(rUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
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
