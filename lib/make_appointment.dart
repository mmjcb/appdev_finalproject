import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MakeAppointmentPage extends StatefulWidget {
  const MakeAppointmentPage({super.key});

  @override
  State<MakeAppointmentPage> createState() => _MakeAppointmentPageState();
}

class _MakeAppointmentPageState extends State<MakeAppointmentPage> {
  String? selectedInstitution;
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top gradient header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(162, 234, 189, 230),
                      Color(0xFFD69ADE),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back, 
                        color: Colors.white),
                    ),
                    Image.asset('assets/skipq-logo.png', height: 42),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none,
                              color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.settings, 
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title and "Next" button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Schedule an Appointment',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    
                    TextButton(
                      onPressed: selectedInstitution != null
                          ? () {
                              Navigator.of(context).pushNamed(
                                '/institution_details',
                                arguments: {
                                  'institutionName': selectedInstitution,
                                  'institutionType': selectedType,
                                },
                              );
                            }
                          : null,

                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                          'Next',
                          style: GoogleFonts.poppins(
                          color: selectedInstitution != null
                              ? Colors.purple
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
            
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.purple.shade300,
                        fontSize: 14,
                      ),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.purple),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.purple.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.purple.shade400),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Banks row
              _buildCategorySection(
                context,
                'Banks',
                [
                  {'name': 'LandBank', 'image': 'assets/banks/landbank.png'},
                  {'name': 'BPI', 'image': 'assets/banks/bpi.png'},
                  {'name': 'BDO', 'image': 'assets/banks/bdo.png'},
                  {'name': 'CitySavings', 'image': 'assets/banks/citysavings.png'},
                ],
              ),
              const SizedBox(height: 24),

              // Hospitals row
              _buildCategorySection(
                context,
                'Hospitals',
                [
                  {'name': 'WVSU Medical Center', 'image': 'assets/hospitals/wvsumed.png'},
                  {'name': 'Western Visayas Medical Center', 'image': 'assets/hospitals/wvmed.png'},
                  {'name': 'Iloilo Doctors\' Hospital', 'image': 'assets/hospitals/iloilodoctors.png'},
                  {'name': 'Iloilo Mission Hospital', 'image': 'assets/hospitals/iloilomission.png'},
                ],
              ),
              const SizedBox(height: 24),

              // Universities row
              _buildCategorySection(
                context,
                'Universities',
                [
                  {'name': 'West Visayas State University', 'image': 'assets/universities/wvsu.png'},
                  {'name': 'Central Philippine University', 'image': 'assets/universities/cpu.png'},
                  {'name': 'University of San Agustin', 'image': 'assets/universities/usa.png'},
                  {'name': 'Iloilo Doctor\'s College', 'image': 'assets/universities/idc.png'},
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String categoryTitle,
    List<Map<String, dynamic>> institutions,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryTitle,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: institutions.length,
              itemBuilder: (context, index) {
                final institution = institutions[index];
                final isSelected = selectedInstitution == institution['name'] &&
                    selectedType == categoryTitle;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildInstitutionBox(
                    institution['name'],
                    institution['image'],
                    categoryTitle,
                    isSelected,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionBox(
    String name,
    String imagePath,
    String type,
    bool isSelected,
) {
    const double boxWidth = 100.0;
    const double boxPadding = 12.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedInstitution = name;
          selectedType = type;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Container(
            width: boxWidth,
            padding: const EdgeInsets.all(boxPadding),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple[100] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.purple : Colors.purple[200]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Label 
          SizedBox(
            width: boxWidth,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,           
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}