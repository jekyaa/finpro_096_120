import 'dart:io';
import 'package:finpro/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ToiletDetailScreen extends StatefulWidget {
  final Toilet toilet;

  const ToiletDetailScreen({Key? key, required this.toilet}) : super(key: key);

  @override
  State<ToiletDetailScreen> createState() => _ToiletDetailScreenState();
}

class _ToiletDetailScreenState extends State<ToiletDetailScreen> {
  GoogleMapController? mapController;
  XFile? _selectedImage; // Menyimpan gambar yang dipilih

  // Fungsi untuk mengambil gambar dari kamera
  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Widget _buildCommentsSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar jika ada
                if (comment.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      comment.image!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (comment.image != null) const SizedBox(height: 8.0),

                // Teks komentar jika ada
                if (comment.text.isNotEmpty)
                  Text(
                    comment.text,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),

                const SizedBox(height: 8.0),

                // Tombol aksi (Edit dan Delete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editComment(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteComment(index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editComment(int index) {
    final comment = _comments[index];
    // Membuka dialog untuk mengedit komentar
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController editController =
            TextEditingController(text: comment.text);

        return AlertDialog(
          title: const Text('Edit Komentar'),
          content: TextFormField(
            controller: editController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Edit komentar Anda...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _comments[index] = Comment(
                    text: editController.text,
                    image: comment.image,
                  );
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(int index) {
    setState(() {
      _comments.removeAt(index);
    });
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  void _submitComment() {
    if (_commentController.text.isNotEmpty || _selectedImage != null) {
      setState(() {
        _comments.add(Comment(
          text: _commentController.text,
          image: _selectedImage != null ? File(_selectedImage!.path) : null,
        ));
        // Bersihkan input
        _commentController.clear();
        _selectedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.toilet.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Container
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: widget.toilet.position,
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(widget.toilet.id),
                    position: widget.toilet.position,
                    infoWindow: InfoWindow(
                      title: widget.toilet.name,
                      snippet: widget.toilet.description,
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi Utama
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.toilet.name,
                                  style: const TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.toilet.price.isEmpty
                                      ? 'Gratis'
                                      : 'Rp ${widget.toilet.price}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            widget.toilet.description,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.toilet.rating}/5',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Fasilitas
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fasilitas',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          FacilityItem(
                            icon: Icons.accessible,
                            title: 'Akses Difabel',
                            isAvailable:
                                widget.toilet.features['handicapAccessible'] ??
                                    false,
                          ),
                          FacilityItem(
                            icon: Icons.child_care,
                            title: 'Baby Station',
                            isAvailable:
                                widget.toilet.features['babyStation'] ?? false,
                          ),
                          FacilityItem(
                            icon: Icons.local_parking,
                            title: 'Parking Available',
                            isAvailable:
                                widget.toilet.features['parkingAvailable'] ??
                                    false,
                          ),
                          FacilityItem(
                            icon: Icons.recommend,
                            title: 'Public Restroom',
                            isAvailable:
                                widget.toilet.features['publicRestroom'] ??
                                    false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //Komentar
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Komentar',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        _buildCommentsSection(),
                        const Text(
                          'Tambah Komentar',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        const SizedBox(height: 12.0),

                        // Tampilkan gambar jika ada
                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Image.file(
                              File(_selectedImage!.path),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        // Kolom input komentar
                        TextFormField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Tulis komentar Anda di sini...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),

                        // Tombol Kamera dan Galeri
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImageFromCamera,
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.white),
                                label: const Text(
                                  'Kamera',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImageFromGallery,
                                icon: const Icon(Icons.photo_library,
                                    color: Colors.white),
                                label: const Text(
                                  'Galeri',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),

                        // Tombol Submit
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0), // Tambahkan jarak jika perlu
                          child: Center(
                            // Posisi tombol di tengah
                            child: SizedBox(
                              width: double
                                  .infinity, // Membuat tombol memenuhi lebar
                              child: ElevatedButton(
                                onPressed: _submitComment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Comment {
  final String text;
  final File? image;

  Comment({required this.text, this.image});
}

// Variabel untuk menyimpan komentar
final TextEditingController _commentController = TextEditingController();
final List<Comment> _comments = [];

class FacilityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isAvailable;

  const FacilityItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: isAvailable ? Colors.deepPurpleAccent : Colors.black,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isAvailable ? Colors.black87 : Colors.black,
            ),
          ),
          const Spacer(),
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.black,
            size: 20,
          ),
        ],
      ),
    );
  }
}
