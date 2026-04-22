import 'package:flutter/material.dart';

class TalentNode {
  final String id;
  String name;
  String description;
  String iconPath;
  int maxRanks;
  int currentRanks;
  int row;
  int column;
  List<String> requirements; // IDs of required nodes

  TalentNode({
    required this.id,
    this.name = 'New Talent',
    this.description = 'Enter talent description...',
    this.iconPath = 'icons/inv_misc_questionmark.png',
    this.maxRanks = 1,
    this.currentRanks = 0,
    required this.row,
    required this.column,
    this.requirements = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconPath': iconPath,
        'maxRanks': maxRanks,
        'currentRanks': currentRanks,
        'row': row,
        'column': column,
        'requirements': requirements,
      };

  factory TalentNode.fromJson(Map<String, dynamic> json) => TalentNode(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        iconPath: json['iconPath'],
        maxRanks: json['maxRanks'],
        currentRanks: json['currentRanks'],
        row: json['row'],
        column: json['column'],
        requirements: List<String>.from(json['requirements'] ?? []),
      );

  TalentNode copyWith({
    String? name,
    String? description,
    String? iconPath,
    int? maxRanks,
    int? currentRanks,
    int? row,
    int? column,
    List<String>? requirements,
  }) {
    return TalentNode(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      maxRanks: maxRanks ?? this.maxRanks,
      currentRanks: currentRanks ?? this.currentRanks,
      row: row ?? this.row,
      column: column ?? this.column,
      requirements: requirements ?? this.requirements,
    );
  }
}
