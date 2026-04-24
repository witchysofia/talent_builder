import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/talent_provider.dart';
import '../models/talent_node.dart';

class TalentCanvas extends StatelessWidget {
  static const double kCellSize = 80.0;
  static const double kSpacing = 40.0;

  const TalentCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TalentProvider>(context);
    final rowCount = provider.rows;
    final colCount = provider.columns;

    final totalWidth = (colCount * kCellSize) + ((colCount - 1) * kSpacing);
    final totalHeight = (rowCount * kCellSize) + ((rowCount - 1) * kSpacing);

    return Container(
      color: const Color(0xFF010409),
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(100),
        scaleEnabled: false, // Disable zoom as requested
        minScale: 1.0,
        maxScale: 1.0,
        child: Center(
          child: Container(
            width: totalWidth,
            height: totalHeight,
            margin: const EdgeInsets.all(40),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Grid Lines
                _buildBackgroundGridLines(rowCount, colCount),

                // Connection Lines Layer
                CustomPaint(
                  painter: ConnectionPainter(
                    nodes: provider.nodes,
                    rowCount: rowCount,
                    colCount: colCount,
                    cellSize: kCellSize,
                    spacing: kSpacing,
                  ),
                  size: Size(totalWidth, totalHeight),
                ),

                // Interactive Grid Nodes
                for (int r = 0; r < rowCount; r++)
                  for (int c = 0; c < colCount; c++)
                    Positioned(
                      left: c * (kCellSize + kSpacing),
                      top: r * (kCellSize + kSpacing),
                      width: kCellSize,
                      height: kCellSize,
                      child: _buildGridCell(context, provider, r, c),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundGridLines(int rows, int cols) {
    return Stack(
      children: [
        for (int i = 0; i < cols; i++)
          Positioned(
            left: i * (kCellSize + kSpacing) + (kCellSize / 2),
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: Colors.white.withOpacity(0.02)),
          ),
        for (int i = 0; i < rows; i++)
          Positioned(
            top: i * (kCellSize + kSpacing) + (kCellSize / 2),
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.white.withOpacity(0.02)),
          ),
      ],
    );
  }

  Widget _buildGridCell(BuildContext context, TalentProvider provider, int row, int col) {
    final id = 'node_${row}_${col}';
    final node = provider.nodes[id];
    final isSelected = provider.selectedNodeId == id;

    return _TalentGridCell(
      row: row,
      col: col,
      node: node,
      isSelected: isSelected,
      onTap: () {
        if (node == null) {
          provider.addNode(row, col);
        } else {
          provider.selectNode(id);
        }
      },
    );
  }

}

class _TalentGridCell extends StatefulWidget {
  final int row;
  final int col;
  final TalentNode? node;
  final bool isSelected;
  final VoidCallback onTap;

  const _TalentGridCell({
    required this.row,
    required this.col,
    this.node,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TalentGridCell> createState() => _TalentGridCellState();
}

class _TalentGridCellState extends State<_TalentGridCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TalentProvider>(context, listen: false);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final isShiftPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) || 
                               HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);
          
          if (isShiftPressed && widget.node != null && provider.selectedNodeId != null && provider.selectedNodeId != widget.node!.id) {
            // Shift + Click Shortcut: Add clicked node as requirement for selected node
            final selectedNode = provider.selectedNode;
            if (selectedNode != null) {
              final reqs = List<String>.from(selectedNode.requirements);
              if (!reqs.contains(widget.node!.id)) {
                reqs.add(widget.node!.id);
                provider.updateSelectedNode(requirements: reqs);
              }
            }
          } else {
            // Normal click
            widget.onTap();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.node != null
                ? Colors.transparent
                : Colors.white.withOpacity(_isHovered ? 0.05 : 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF3B82F6)
                  : (widget.node != null
                      ? Colors.white24
                      : (_isHovered ? Colors.white24 : Colors.white10)),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.node != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    widget.node!.iconPath,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.help_outline, color: Colors.white24),
                  ),
                )
              else
                const Icon(Icons.add, color: Colors.white10, size: 20),
              
              if (widget.node != null)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '${widget.node!.currentRanks}/${widget.node!.maxRanks}',
                      style: TextStyle(
                        color: widget.node!.currentRanks > 0 ? const Color(0xFF4ADE80) : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final Map<String, TalentNode> nodes;
  final int rowCount;
  final int colCount;
  final double cellSize;
  final double spacing;

  ConnectionPainter({
    required this.nodes,
    required this.rowCount,
    required this.colCount,
    required this.cellSize,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFF4B5563)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = const Color(0xFF4B5563)
      ..style = PaintingStyle.fill;

    for (var node in nodes.values) {
      for (var reqId in node.requirements) {
        final reqNode = nodes[reqId];
        if (reqNode != null) {
          final startCenter = Offset(
            (reqNode.column * (cellSize + spacing)) + (cellSize / 2),
            (reqNode.row * (cellSize + spacing)) + (cellSize / 2),
          );
          final endCenter = Offset(
            (node.column * (cellSize + spacing)) + (cellSize / 2),
            (node.row * (cellSize + spacing)) + (cellSize / 2),
          );

          final offset = cellSize / 2;

          _drawSmartConnection(canvas, startCenter, endCenter, offset, offset, linePaint, arrowPaint);
        }
      }
    }
  }

  void _drawSmartConnection(Canvas canvas, Offset start, Offset end, double offsetX, double offsetY, Paint linePaint, Paint arrowPaint) {
    final path = Path();
    
    if (start.dx == end.dx) {
      // Vertical line (Downward)
      path.moveTo(start.dx, start.dy + offsetY);
      path.lineTo(end.dx, end.dy - offsetY -5);
      canvas.drawPath(path, linePaint);
      _drawArrowhead(canvas, Offset(end.dx, end.dy - offsetY), 0, arrowPaint);
    } else if (start.dy == end.dy) {
      // Horizontal line
      final startX = start.dx + (start.dx < end.dx ? offsetX : -offsetX);
      final endX = end.dx - (start.dx < end.dx ? offsetX : -offsetX);
      path.moveTo(startX, start.dy);
      path.lineTo(endX - 5, end.dy);
      canvas.drawPath(path, linePaint);
      final rotation = start.dx < end.dx ? -1.5708 : 1.5708;
      _drawArrowhead(canvas, Offset(endX, end.dy), rotation, arrowPaint);
    } else {
      // Manhattan: Horizontal then Vertical
      final startX = start.dx + (start.dx < end.dx ? offsetX : -offsetX);
      path.moveTo(startX, start.dy);
      path.lineTo(end.dx, start.dy);
      path.lineTo(end.dx, end.dy - offsetY - 5);
      canvas.drawPath(path, linePaint);
      
      _drawArrowhead(canvas, Offset(end.dx, end.dy - offsetY), 0, arrowPaint);
    }
  }

  void _drawArrowhead(Canvas canvas, Offset tip, double rotation, Paint paint) {
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(rotation);
    
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(-8, -12);
    path.lineTo(8, -12);
    path.close();
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) => true;
}
