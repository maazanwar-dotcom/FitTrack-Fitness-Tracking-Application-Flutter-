import 'package:fittrack/models/ExcerciseModel.dart';
import 'package:fittrack/services/ExcerciseApiService.dart';
import 'package:flutter/material.dart';

class ExerciseListScreen extends StatefulWidget {
  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Exercise> _exercises = [];

  int _currentOffset = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  Exercise? _selectedExercise; // For selection and returning

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMoreData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Exercise> exercises = await ExcerciseApiService.fetchExercises(
        limit: _limit,
        offset: 0,
      );

      setState(() {
        _exercises.clear();
        _exercises.addAll(exercises);
        _currentOffset = _limit;
        _hasMore = exercises.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Exercise> newExercises = await ExcerciseApiService.fetchExercises(
        limit: _limit,
        offset: _currentOffset,
      );

      setState(() {
        _exercises.addAll(newExercises);
        _currentOffset += _limit;
        _hasMore = newExercises.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more exercises: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    _currentOffset = 0;
    _hasMore = true;
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Database'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_selectedExercise != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text("Add Exercise"),
                onPressed: () {
                  Navigator.pop(context, _selectedExercise);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(48),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading exercises...'),
          ],
        ),
      );
    }

    if (_error != null && _exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Failed to load exercises',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadInitialData, child: Text('Retry')),
          ],
        ),
      );
    }

    if (_exercises.isEmpty) {
      return Center(
        child: Text(
          'No exercises available',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(8),
        itemCount: _exercises.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _exercises.length) {
            return _buildExerciseCard(_exercises[index]);
          } else {
            return Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: _isLoading
                  ? Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Loading more exercises...'),
                      ],
                    )
                  : SizedBox.shrink(),
            );
          }
        },
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    bool isSelected = _selectedExercise?.id == exercise.id;
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedExercise = isSelected
                ? null
                : exercise; // toggle selection
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise GIF/Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  child: exercise.gifUrl.isNotEmpty
                      ? Image.network(
                          exercise.gifUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.fitness_center,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.fitness_center,
                            color: Colors.grey[600],
                            size: 32,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12),
              // Exercise Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    _buildInfoChip('Target: ${exercise.target}', Colors.blue),
                    SizedBox(height: 4),
                    _buildInfoChip(
                      'Body Part: ${exercise.bodyPart}',
                      Colors.green,
                    ),
                    SizedBox(height: 4),
                    _buildInfoChip(
                      'Equipment: ${exercise.equipment}',
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
