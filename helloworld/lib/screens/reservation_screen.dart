import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'about_screen.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedStartTime, _selectedEndTime;
  List<String> carList = []; // List to hold fetched car info
  String? _selectedSlot;
  String? _carInfo;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    try {
      final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/cars/')); // Replace with your API URL
      if (response.statusCode == 200) {
        final List<dynamic> carsJson = json.decode(response.body);

        setState(() {
          // Extracting model and vin from the JSON response
          carList = carsJson.map((carData) {
            String model =
                carData['model']; // Assuming 'model' is directly under carData
            String vin =
                carData['vin']; // Assuming 'vin' is directly under carData
            return '$model - $vin'; // Displaying model and vin concatenated
          }).toList();
        });
      } else {
        print('Failed to load cars');
      }
    } catch (e) {
      print('Error fetching cars: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Screen'),
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AboutScreen(userId: 3)),
                );
              }),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Selection Dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Car',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    value: _carInfo,
                    items: carList.map((String carInfo) {
                      return DropdownMenuItem<String>(
                        value: carInfo,
                        child: Text(carInfo),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _carInfo = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a car' : null,
                  ),
                ),
                // Custom Slot Input
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Enter Slot',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSlot = newValue;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a slot'
                        : null,
                  ),
                ),
                // Start Time Picker
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDateTimePicker(context);
                      if (picked != null && picked != _selectedStartTime)
                        setState(() {
                          _selectedStartTime = picked;
                        });
                    },
                    controller: TextEditingController(
                      text: _selectedStartTime != null
                          ? _selectedStartTime!.toLocal().toString()
                          : '',
                    ),
                  ),
                ),
                // End Time Picker
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDateTimePicker(context);
                      if (picked != null && picked != _selectedEndTime)
                        setState(() {
                          _selectedEndTime = picked;
                        });
                    },
                    controller: TextEditingController(
                      text: _selectedEndTime != null
                          ? _selectedEndTime!.toLocal().toString()
                          : '',
                    ),
                  ),
                ),
                // Reserve Button
                Center(
                  child: SizedBox(
                    width: 200, // Set the button width
                    height: 50, // Set the button height
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_carInfo != null && _selectedSlot != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingPage(
                                  slotId: _selectedSlot,
                                  slotName: _selectedSlot,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please select a car and enter a slot')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      child: Text(
                        'Reserve Slot',
                        style: TextStyle(
                          color: Colors.white, // Change the text color to white
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    TimeOfDay initialTime = TimeOfDay.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
    return null;
  }
}

class BookingPage extends StatelessWidget {
  final String? slotId;
  final String? slotName;

  BookingPage({this.slotId, this.slotName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Page'),
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
      ),
      body: Center(
        child: Text('Booking for slot: $slotName'),
      ),
    );
  }
}
