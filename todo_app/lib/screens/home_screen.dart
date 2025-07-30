import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late final DocumentReference _userDocRef;
  late final CollectionReference _todosRef;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
      _todosRef = _userDocRef.collection('todos');
      _checkOnboardingStatus();
    }
  }
  
  Future<void> _checkOnboardingStatus() async {
    final snapshot = await _userDocRef.get();
    final data = snapshot.data() as Map<String, dynamic>?;
    
    if (data != null && data['hasCompletedOnboarding'] == false) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => OnboardingCarouselDialog(userDocRef: _userDocRef),
          );
        }
      });
    }
  }

  void _showFeedbackSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green[600]),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _showAddTaskDialog() async {
    final taskController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new task'),
          content: TextField(
            controller: taskController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter task description'),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  _todosRef.add({
                    'title': taskController.text, 'isDone': false, 'createdAt': Timestamp.now(),
                  }).then((_) => _showFeedbackSnackBar('Task added successfully!'));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Not logged in.")));
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: _todosRef.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text("No tasks found.")));
        }

        final tasks = snapshot.data!.docs;
        final completedCount = tasks.where((task) => (task.data() as Map<String, dynamic>)['isDone'] == true).length;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('My To-Do\'s ($completedCount/${tasks.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Log Out')],
          ),
          body: Column(
            children: [
              if (tasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('💡 Swipe left on a task to delete it.', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                ),
              Expanded(
                child: tasks.isEmpty
                  ? const Center(child: Text("No tasks yet. Add one!"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final taskDoc = tasks[index];
                        final taskData = taskDoc.data() as Map<String, dynamic>;
                        
                        return Slidable(
                          key: ValueKey(taskDoc.id),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  _todosRef.doc(taskDoc.id).delete();
                                  _showFeedbackSnackBar('Task deleted.');
                                },
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              leading: Checkbox(
                                value: taskData['isDone'],
                                onChanged: (bool? value) => _todosRef.doc(taskDoc.id).update({'isDone': value}),
                              ),
                              title: Text(
                                taskData['title'],
                                style: TextStyle(
                                  decoration: taskData['isDone'] ? TextDecoration.lineThrough : TextDecoration.none,
                                  color: taskData['isDone'] ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddTaskDialog,
            tooltip: 'Add Task',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class OnboardingCarouselDialog extends StatefulWidget {
  final DocumentReference userDocRef;
  const OnboardingCarouselDialog({super.key, required this.userDocRef});

  @override
  State<OnboardingCarouselDialog> createState() => _OnboardingCarouselDialogState();
}

class _OnboardingCarouselDialogState extends State<OnboardingCarouselDialog> {
  final _controller = PageController();
  bool _isLastPage = false;

  final List<Widget> _pages = [
    const _OnboardingPage(
      icon: Icons.checklist_rtl,
      title: 'Welcome to your To-Do App!',
      description: 'Keep your life organized and never forget a task again.',
    ),
    const _OnboardingPage(
      icon: Icons.add_circle_outline,
      title: 'Add New Tasks',
      description: 'Tap the "+" button at the bottom right to add a new to-do item to your list.',
    ),
    const _OnboardingPage(
      icon: Icons.swipe_left_outlined,
      title: 'Swipe to Delete',
      description: 'Simply swipe any task from right to left to reveal the delete option. It\'s that easy!',
    ),
  ];
  
  void _onDone() {
    widget.userDocRef.update({'hasCompletedOnboarding': true});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: 300,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() { _isLastPage = index == _pages.length - 1; });
                },
                itemBuilder: (_, index) => _pages[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Colors.deepPurple,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLastPage ? _onDone : () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text(_isLastPage ? 'Done' : 'Next'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingPage({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }
}