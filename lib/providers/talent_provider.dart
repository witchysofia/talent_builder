import 'package:flutter/material.dart';
import '../models/talent_node.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TalentProvider with ChangeNotifier {
  static const String _storageKey = 'talent_builder_trees';
  
  List<Map<String, dynamic>> _allTrees = [];
  int _currentTreeIndex = 0;
  
  String? _selectedNodeId;

  TalentProvider() {
    _loadFromStorage();
  }

  // Current tree getters
  String get treeName => _allTrees.isEmpty ? 'New Custom Tree' : _allTrees[_currentTreeIndex]['treeName'];
  String get treeIconPath => _allTrees.isEmpty ? 'icons/ability_druid_berserk.png' : (_allTrees[_currentTreeIndex]['treeIconPath'] ?? 'icons/ability_druid_berserk.png');
  int get rows => _allTrees.isEmpty ? 7 : _allTrees[_currentTreeIndex]['rows'];
  int get columns => 4;
  Map<String, TalentNode> get nodes {
    if (_allTrees.isEmpty) return {};
    final nodesJson = _allTrees[_currentTreeIndex]['nodes'] as List;
    final Map<String, TalentNode> nodesMap = {};
    for (var n in nodesJson) {
      final node = TalentNode.fromJson(n);
      nodesMap[node.id] = node;
    }
    return nodesMap;
  }
  
  List<String> get treeNames => _allTrees.map((t) => t['treeName'] as String).toList();
  String getTreeIconPath(int index) {
    if (index >= 0 && index < _allTrees.length) {
      return _allTrees[index]['treeIconPath'] ?? 'icons/ability_druid_berserk.png';
    }
    return 'icons/ability_druid_berserk.png';
  }
  int get currentTreeIndex => _currentTreeIndex;
  String? get selectedNodeId => _selectedNodeId;
  TalentNode? get selectedNode => selectedNodeId != null ? nodes[selectedNodeId] : null;

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      _allTrees = List<Map<String, dynamic>>.from(jsonDecode(data));
      if (_allTrees.isEmpty) {
        _initializeDefaultTree();
      }
    } else {
      _initializeDefaultTree();
    }
    notifyListeners();
  }

  void _initializeDefaultTree() {
    _allTrees = [{
      'treeName': 'New Custom Tree',
      'treeIconPath': 'icons/ability_druid_berserk.png',
      'rows': 7,
      'nodes': [],
    }];
    _currentTreeIndex = 0;
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_allTrees));
  }

  void setTreeName(String name) {
    if (_allTrees.isNotEmpty) {
      _allTrees[_currentTreeIndex]['treeName'] = name;
      _saveToStorage();
      notifyListeners();
    }
  }

  void setTreeIcon(String iconPath) {
    if (_allTrees.isNotEmpty) {
      _allTrees[_currentTreeIndex]['treeIconPath'] = iconPath;
      _saveToStorage();
      notifyListeners();
    }
  }

  void setRows(int rows) {
    if (_allTrees.isNotEmpty) {
      _allTrees[_currentTreeIndex]['rows'] = rows.clamp(1, 11);
      _saveToStorage();
      notifyListeners();
    }
  }

  void switchTree(int index) {
    if (index >= 0 && index < _allTrees.length) {
      _currentTreeIndex = index;
      _selectedNodeId = null;
      notifyListeners();
    }
  }

  void createNewTree() {
    _allTrees.add({
      'treeName': 'Untitled Tree ${_allTrees.length + 1}',
      'treeIconPath': 'icons/ability_druid_berserk.png',
      'rows': 7,
      'nodes': [],
    });
    _currentTreeIndex = _allTrees.length - 1;
    _selectedNodeId = null;
    _saveToStorage();
    notifyListeners();
  }

  void deleteTree(int index) {
    if (_allTrees.length > 1) {
      _allTrees.removeAt(index);
      if (_currentTreeIndex >= _allTrees.length) {
        _currentTreeIndex = _allTrees.length - 1;
      }
      _selectedNodeId = null;
      _saveToStorage();
      notifyListeners();
    }
  }

  void selectNode(String? id) {
    _selectedNodeId = id;
    notifyListeners();
  }

  void addNode(int row, int col) {
    final id = 'node_${row}_${col}';
    final currentNodes = nodes;
    if (!currentNodes.containsKey(id)) {
      final newNode = TalentNode(id: id, row: row, column: col);
      final nodesList = _allTrees[_currentTreeIndex]['nodes'] as List;
      nodesList.add(newNode.toJson());
      _selectedNodeId = id;
      _saveToStorage();
      notifyListeners();
    }
  }

  void updateSelectedNode({
    String? name,
    String? description,
    String? iconPath,
    int? maxRanks,
    List<String>? requirements,
  }) {
    if (_selectedNodeId != null) {
      final nodesList = _allTrees[_currentTreeIndex]['nodes'] as List;
      final nodeIndex = nodesList.indexWhere((n) => n['id'] == _selectedNodeId);
      if (nodeIndex != -1) {
        final currentNode = TalentNode.fromJson(nodesList[nodeIndex]);
        final updatedNode = currentNode.copyWith(
          name: name,
          description: description,
          iconPath: iconPath,
          maxRanks: maxRanks,
          requirements: requirements,
        );
        nodesList[nodeIndex] = updatedNode.toJson();
        _saveToStorage();
        notifyListeners();
      }
    }
  }

  void deleteNode(String id) {
    final nodesList = _allTrees[_currentTreeIndex]['nodes'] as List;
    nodesList.removeWhere((n) => n['id'] == id);
    
    // Remove as requirement from others
    for (var n in nodesList) {
      final reqs = List<String>.from(n['requirements'] ?? []);
      if (reqs.contains(id)) {
        reqs.remove(id);
        n['requirements'] = reqs;
      }
    }

    if (_selectedNodeId == id) _selectedNodeId = null;
    _saveToStorage();
    notifyListeners();
  }

  void resetTree() {
    _allTrees[_currentTreeIndex]['nodes'] = [];
    _selectedNodeId = null;
    _saveToStorage();
    notifyListeners();
  }

  String exportJson() {
    return jsonEncode(_allTrees[_currentTreeIndex]);
  }

  void importJson(String jsonStr) {
    final data = jsonDecode(jsonStr);
    _allTrees.add(data);
    _currentTreeIndex = _allTrees.length - 1;
    _selectedNodeId = null;
    _saveToStorage();
    notifyListeners();
  }
}
