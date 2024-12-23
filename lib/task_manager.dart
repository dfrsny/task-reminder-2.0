import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaskManagerPage extends StatefulWidget {
  final String username;
  final String phoneNumber; // Tambahkan nomor telepon

  const TaskManagerPage({
    Key? key,
    required this.username,
    required this.phoneNumber, // Tambahkan nomor telepon
  }) : super(key: key);

  @override
  _TaskManagerPageState createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  List<Map<String, dynamic>> tasks = []; // List untuk menyimpan tugas
  int taskLimit = 0; // Task limit yang akan diperiksa

  final TextEditingController taskController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadTaskLimit();
  }

  // Memuat daftar tugas dari API
  Future<void> _loadTasks() async {
    final String apiUrl =
        'http://localhost/otp/api_task/get_task.php?username=${widget.username}';

    print('Fetching tasks for: ${widget.username}'); // Debugging line

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print('Response body: ${response.body}'); // Debugging line

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            tasks = List<Map<String, dynamic>>.from(data['tasks']);
            _sortTasksByCountdown(); // Urutkan tugas berdasarkan countdown
          });
        } else {
          _showError(data['message']);
        }
      } else {
        _showError('Failed to load tasks');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  // Memuat task_limit dari API
  Future<void> _loadTaskLimit() async {
    final String apiUrl =
        'http://localhost/otp/api_task/get_task_limit.php?username=${widget.username}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            taskLimit = int.tryParse(data['task_limit'].toString()) ?? 0;
          });
        } else {
          _showError(data['message']);
        }
      } else {
        _showError('Failed to load task limit');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  // Fungsi untuk mengurutkan tugas berdasarkan countdown
  void _sortTasksByCountdown() {
    tasks.sort((a, b) {
      DateTime deadlineA = DateTime.parse(a['deadline']);
      DateTime deadlineB = DateTime.parse(b['deadline']);
      Duration diffA = deadlineA.difference(DateTime.now());
      Duration diffB = deadlineB.difference(DateTime.now());
      return diffA.inMinutes
          .compareTo(diffB.inMinutes); // Urutkan berdasarkan menit
    });
  }

  // Menambah tugas baru
  Future<void> _addTask(
      String judul, String description, String deadline) async {
    // Cek apakah task limit tercapai
    if (taskLimit <= 0) {
      _showError('Task limit reached. Cannot add more tasks.');
      return;
    }

    final String apiUrl = 'http://localhost/otp/api_task/add_task.php';

    try {
      // Kirim data ke API untuk menambah task
      final response = await http.post(Uri.parse(apiUrl), body: {
        'username': widget.username,
        'judul_task': judul,
        'description': description,
        'deadline': deadline,
      });

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // Perbarui state setelah task berhasil ditambahkan
        setState(() {
          tasks.add({
            'judul_task': judul,
            'description': description,
            'deadline': deadline,
          });
          taskLimit--; // Kurangi task limit
          _sortTasksByCountdown(); // Urutkan ulang tugas
        });

        // Kirimkan detail task ke nomor telepon pengguna
        await _sendTaskToPhone(judul, description, deadline);

        // Tutup dialog setelah berhasil
        Navigator.pop(context);
      } else {
        // Tampilkan pesan error jika gagal menambah task
        _showError(data['message']);
      }
    } catch (e) {
      // Tangani error jika terjadi masalah koneksi atau lainnya
      _showError('Failed to add task. Please try again.');
      print(e);
    }
  }

  // Mengedit tugas yang ada
  Future<void> _editTask(
      int index, String judul, String description, String deadline) async {
    final String apiUrl = 'http://localhost/otp/api_task/edit_task.php';

    final response = await http.post(Uri.parse(apiUrl), body: {
      'username': widget.username,
      'id': tasks[index]['id'].toString(),
      'judul_task': judul,
      'description': description,
      'deadline': deadline,
    });

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      setState(() {
        tasks[index] = {
          'id': tasks[index]['id'],
          'judul_task': judul,
          'description': description,
          'deadline': deadline,
        };
        _sortTasksByCountdown(); // Urutkan ulang setelah edit tugas
      });
      Navigator.pop(context); // Tutup dialog
    } else {
      _showError(data['message']);
    }
  }

  // Menghapus tugas
  Future<void> _deleteTask(int index) async {
    // Menampilkan dialog konfirmasi penghapusan
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Penghapusan"),
        content: Text("Apakah Anda yakin ingin menghapus task ini?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Menutup dialog tanpa menghapus
            },
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Menutup dialog konfirmasi
              final String apiUrl =
                  'http://localhost/otp/api_task/delete_task.php';

              final response = await http.post(Uri.parse(apiUrl), body: {
                'username': widget.username,
                'id': tasks[index]['id'].toString(),
              });

              final data = jsonDecode(response.body);

              if (data['status'] == 'success') {
                setState(() {
                  tasks.removeAt(index);
                  _sortTasksByCountdown(); // Urutkan ulang setelah menghapus tugas
                });
              } else {
                _showError(data['message']);
              }
            },
            child: Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // Menampilkan error
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // Menampilkan dialog untuk menambah/edit tugas
  Future<void> _showTaskDialog({int? index}) async {
    String dialogTitle = index == null ? "Add Task" : "Edit Task";
    if (index != null) {
      taskController.text = tasks[index]['judul_task'];
      descriptionController.text = tasks[index]['description'];
      deadlineController.text = tasks[index]['deadline'];
    } else {
      taskController.clear();
      descriptionController.clear();
      deadlineController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: "Task Title",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 5, // Membatasi tinggi input deskripsi
                minLines: 3, // Memberikan tinggi minimum untuk input deskripsi
              ),
              SizedBox(height: 10),
              TextField(
                controller: deadlineController,
                decoration: InputDecoration(
                  labelText: "Deadline (YYYY-MM-DD HH:MM:SS)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 5),
              Text(
                "Contoh: 2024-12-31 15:30:00",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog tanpa aksi
            },
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              if (taskController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  deadlineController.text.isNotEmpty) {
                if (index == null) {
                  _addTask(
                    taskController.text,
                    descriptionController.text,
                    deadlineController.text,
                  ); // Tambah tugas baru
                } else {
                  _editTask(
                    index,
                    taskController.text,
                    descriptionController.text,
                    deadlineController.text,
                  ); // Edit tugas
                }
              }
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _processTopUp(int taskAmount) async {
    //Future<void> _processTopUp(int taskAmount, int cost) async {
    final String apiUrl = 'http://localhost/otp/topup.php';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'username': widget.username,
        'task_amount': taskAmount.toString(),
        // 'cost': cost.toString(),
      });

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          taskLimit += taskAmount;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Top-up berhasil! Task limit Anda bertambah.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Top-up gagal: ${data['message']}')),
        );
      }
    } catch (e) {
      print('Error processing top-up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat melakukan top-up.')),
      );
    }
  }

  Future<void> _showTopUpDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Top Up Task Limit",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopUpOption("20 Task - Rp. 5.000",
                  20), //_buildTopUpOption("20 Task - Rp. 5.000", 20, 5000),
              Divider(),
              _buildTopUpOption("50 Task - Rp. 10.000", 50),
              Divider(),
              _buildTopUpOption("100 Task - Rp. 15.000", 100),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpOption(String title, int tasks) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            ElevatedButton(
              onPressed: () => _processTopUp(
                  tasks), //            onPressed: () => _processTopUp(tasks, price),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Pilih",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendTaskToPhone(
      String judul, String description, String deadline) async {
    final String apiUrl = 'http://localhost/otp/send_task.php';

    final response = await http.post(Uri.parse(apiUrl), body: {
      'username': widget.username,
      'nomor': widget.phoneNumber, // Ganti dengan nomor pengguna yang tersimpan
      'judul_task': judul,
      'description': description,
      'deadline': deadline,
    });

    final data = jsonDecode(response.body);

    if (data['success'] != null) {
      print('Message sent successfully: ${data['success']}');
    } else {
      print('Error sending message: ${data['error']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager - ${widget.username}"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTasks, // Refresh task list
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                "No tasks available. Click '+' to add a task.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                // Mendapatkan deadline task dan menghitung selisih waktu
                DateTime deadline = DateTime.parse(tasks[index]['deadline']);
                Duration difference = deadline.difference(DateTime.now());

                // Menghitung hari, jam, dan menit
                int days = difference.inDays;
                int hours = difference.inHours % 24;
                int minutes = difference.inMinutes % 60;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        tasks[index]['judul_task'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Description: ${tasks[index]['description']}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Deadline: ${tasks[index]['deadline']}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 8),
                          Text(
                            difference.isNegative
                                ? 'Expired'
                                : 'Countdown: $days hari, $hours jam, $minutes menit',
                            style: TextStyle(
                              color: difference.isNegative
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showTaskDialog(index: index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showTopUpDialog,
            child: Icon(Icons.attach_money),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () => _showTaskDialog(),
            child: Icon(Icons.add),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.grey.shade200,
        child: Text(
          'Sisa limit task Anda: $taskLimit',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
