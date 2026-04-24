import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/talent_provider.dart';
import '../models/talent_node.dart';
import '../utils/icon_constants.dart';

class RightEditorPanel extends StatelessWidget {
  const RightEditorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TalentProvider>(context);
    final node = provider.selectedNode;

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(left: BorderSide(color: Colors.white10)),
      ),
      child: node == null
          ? _buildEmptyState()
          : _buildEditor(context, provider, node),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, color: Colors.white10, size: 48),
          SizedBox(height: 16),
          Text(
            'Select a node to edit',
            style: TextStyle(color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context, TalentProvider provider, TalentNode node) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Edit Talent',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => provider.selectNode(null),
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Icon'),
          const SizedBox(height: 12),
          _IconPicker(provider: provider, currentNode: node),
          const SizedBox(height: 24),
          _buildLabel('Name'),
          const SizedBox(height: 12),
          _buildTextField(
            node: node,
            fieldName: 'name',
            initialValue: node.name,
            onChanged: (val) => provider.updateSelectedNode(name: val),
          ),
          const SizedBox(height: 24),
          _buildLabel('Max Ranks'),
          const SizedBox(height: 12),
          _buildTextField(
            node: node,
            fieldName: 'ranks',
            initialValue: node.maxRanks.toString(),
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final ranks = int.tryParse(val);
              if (ranks != null) provider.updateSelectedNode(maxRanks: ranks);
            },
          ),
          const SizedBox(height: 24),
          _buildLabel('Description'),
          const SizedBox(height: 12),
          _buildTextField(
            node: node,
            fieldName: 'description',
            initialValue: node.description,
            maxLines: 4,
            onChanged: (val) => provider.updateSelectedNode(description: val),
          ),
          const SizedBox(height: 24),
          _buildLabel('Requires'),
          const SizedBox(height: 12),
          _buildCurrentRequirements(provider, node),
          const SizedBox(height: 8),
          _buildRequirementDropdown(provider, node),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _buildDeleteButton(provider, node.id),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCloseButton(provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TalentNode node,
    required String fieldName,
    required String initialValue,
    required Function(String) onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: TextFormField(
        key: ValueKey('${node.id}_$fieldName'),
        initialValue: initialValue,
        onChanged: onChanged,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildRequirementDropdown(TalentProvider provider, TalentNode node) {
    final otherNodes = provider.nodes.values
        .where((n) => n.id != node.id)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: null,
          hint: const Text('Add requirement...', style: TextStyle(color: Colors.white24, fontSize: 14)),
          dropdownColor: const Color(0xFF161B22),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white24),
          items: otherNodes.map((n) {
            return DropdownMenuItem(
              value: n.id,
              child: Text(n.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              final reqs = List<String>.from(node.requirements);
              if (!reqs.contains(val)) {
                reqs.add(val);
                provider.updateSelectedNode(requirements: reqs);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildCurrentRequirements(TalentProvider provider, TalentNode node) {
    if (node.requirements.isEmpty) return const SizedBox.shrink();

    return Column(
      children: node.requirements.map((reqId) {
        final reqNode = provider.nodes[reqId];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              if (reqNode != null)
                Image.asset(reqNode.iconPath, width: 20, height: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reqNode?.name ?? 'Unknown Node',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: () {
                  final reqs = List<String>.from(node.requirements);
                  reqs.remove(reqId);
                  provider.updateSelectedNode(requirements: reqs);
                },
                icon: const Icon(Icons.close, color: Colors.redAccent, size: 14),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeleteButton(TalentProvider provider, String id) {
    return GestureDetector(
      onTap: () => provider.deleteNode(id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
            SizedBox(width: 4),
            Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(TalentProvider provider) {
    return GestureDetector(
      onTap: () => provider.selectNode(null),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Close',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }
}

class _IconPicker extends StatefulWidget {
  final TalentProvider provider;
  final TalentNode currentNode;

  const _IconPicker({required this.provider, required this.currentNode});

  @override
  State<_IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<_IconPicker> {
  String _searchQuery = '';
  late List<String> _filteredIcons;

  @override
  void initState() {
    super.initState();
    _filteredIcons = IconConstants.allIcons;
  }

  void _filterIcons(String query) {
    setState(() {
      _searchQuery = query;
      _filteredIcons = IconConstants.allIcons
          .where((icon) => icon.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            onChanged: _filterIcons,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Search icons...',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              border: InputBorder.none,
              isDense: true,
              icon: Icon(Icons.search, color: Colors.white24, size: 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white10),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _filteredIcons.length,
            itemBuilder: (context, index) {
              final iconName = _filteredIcons[index];
              final path = 'icons/$iconName';

              return GestureDetector(
                onTap: () => widget.provider.updateSelectedNode(iconPath: path),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.currentNode.iconPath == path
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Tooltip(
                      message: iconName,
                      child: Image.asset(path, fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
