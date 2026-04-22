import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/talent_provider.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TalentProvider>(context);

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Talent Tree',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Build and customize your own talent trees.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('My Trees'),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: provider.treeNames.length,
              itemBuilder: (context, index) {
                return _buildTreeItem(
                  context,
                  provider,
                  provider.treeNames[index],
                  index == provider.currentTreeIndex,
                  index,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildNewTreeButton(provider),
          const SizedBox(height: 24),
          _buildImportButton(provider),
          const SizedBox(height: 32),
          _buildSectionHeader('Tree Name'),
          const SizedBox(height: 12),
          _buildTextField(
            initialValue: provider.treeName,
            onChanged: (val) => provider.setTreeName(val),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Rows (1-11)'),
          const SizedBox(height: 12),
          _buildTextField(
            initialValue: provider.rows.toString(),
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final rows = int.tryParse(val);
              if (rows != null) provider.setRows(rows);
            },
          ),
          const Spacer(),
          _buildExportButton(context, provider),
          const SizedBox(height: 12),
          _buildResetButton(provider),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTreeItem(BuildContext context, TalentProvider provider, String name, bool active, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1F2937).withOpacity(0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active ? const Color(0xFF3B82F6).withOpacity(0.5) : Colors.white10,
        ),
      ),
      child: ListTile(
        onTap: () => provider.switchTree(index),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          name,
          style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: active ? null : IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 16),
          onPressed: () => provider.deleteTree(index),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  Widget _buildNewTreeButton(TalentProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.createNewTree();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white10),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white54, size: 16),
            SizedBox(width: 8),
            Text(
              'New Tree',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildResetButton(TalentProvider provider) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => provider.resetTree(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Reset Current Tree',
            style: TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, TalentProvider provider) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final json = provider.exportJson();
          final filename = provider.treeName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
          
          if (kIsWeb) {
            final bytes = utf8.encode(json);
            final blob = html.Blob([bytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor = html.AnchorElement(href: url)
              ..setAttribute("download", "$filename.json")
              ..click();
            html.Url.revokeObjectUrl(url);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Exported $filename.json')),
            );
          } else {
            // Fallback for non-web (though this app is designed for web)
            print(json);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export printed to console (Desktop/Mobile support coming soon)')),
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Export Tree',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportButton(TalentProvider provider) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _showImportDialog(context, provider),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white10),
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, color: Colors.white54, size: 16),
              SizedBox(width: 8),
              Text(
                'Import JSON',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, TalentProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('Import Talent Tree', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste the JSON content here:',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 10,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF161B22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                provider.importJson(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tree imported successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid JSON format')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Import', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
