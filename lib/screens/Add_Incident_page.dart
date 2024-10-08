import 'package:civic_1/services/incident_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../components/incident_select_map.dart';

class AddIncidentScreen extends StatefulWidget {
  const AddIncidentScreen({super.key});

  @override
  _AddIncidentScreenState createState() => _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _images = [];
  LatLng? _selectedLocation;

  final IncidentService _incidentService = IncidentService();

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      for (var file in pickedFiles) {
        _images.add(File(file.path));
      }
      setState(() {});
    }
  }

  Future<void> _selectLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          onLocationSelected: (LatLng location) {
            setState(() {
              _selectedLocation = location;
            });
          },
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_titleController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Upload images and get their URLs
    List<String> imageUrls = [];
    for (var image in _images) {
      String imageUrl = await _incidentService.uploadImage(image.path);
      imageUrls.add(imageUrl);
    }

    // Add incident
    await _incidentService.addIncident(
      title: _titleController.text,
      organization: _addressController.text,
      description: _descriptionController.text,
      location:
          '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
      imageUrls: imageUrls,
    );

    // Clear fields after submission
    _titleController.clear();
    _addressController.clear();
    _descriptionController.clear();
    _images.clear();
    _selectedLocation = null;
    setState(() {});

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Incident added successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Incident',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controller: _titleController, labelText: 'Title'),
              SizedBox(height: 16.0),
              _buildTextField(
                  controller: _addressController,
                  labelText: 'Address / Organization'),
              SizedBox(height: 16.0),
              _buildAddImagesButton(),
              SizedBox(height: 16.0),
              _buildTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  maxLines: 3),
              SizedBox(height: 16.0),
              _buildLocationButton(),
              SizedBox(height: 30.0),
              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Color(0xFFEAFEF1),
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16.0),
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(115, 138, 123, 123),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: padding,
          ),
          style: TextStyle(color: Colors.white),
          maxLines: maxLines,
        ),
      ),
    );
  }

  Widget _buildAddImagesButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _pickImages,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          'ADD IMAGES',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectLocation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          _selectedLocation == null
              ? 'SELECT LOCATION'
              : 'Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
