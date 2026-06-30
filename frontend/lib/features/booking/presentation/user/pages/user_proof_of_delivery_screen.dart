import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/route_names.dart';

class UserProofOfDeliveryScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const UserProofOfDeliveryScreen({
    super.key,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath =
        bookingData['proofOfDeliveryImage']?.toString() ?? '';

    final imageUrl =
        '${dotenv.env['API_BASE_URL']}$imagePath';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              70,
              16,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Image.asset(
                  'assets/images/confirm.png',
                  width: 95,
                  height: 95,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Your goods have been\ndelivered.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D8EA5),
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Thank you for using our service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 80),

                Center(
                  child: SizedBox(
                    width: 359.8,
                    height: 202.39,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: imagePath.isEmpty
                          ? Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text(
                            'No proof image available',
                          ),
                        ),
                      )
                          : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 108),

                Container(
                  width: 230,
                  height: 57,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black.withOpacity(0.12),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF2255E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      context.go(
                        RouteNames.userHome,
                      );
                    },
                    child: const Text(
                      'Confirm received',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: 230,
                  height: 57,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF2255E5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Material(
                    elevation: 0,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(10),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor:
                            const Color(0xFFF4F6FA),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.all(
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  const CircleAvatar(
                                    radius: 28,
                                    backgroundColor:
                                    Color(0xFFF44336,),
                                    child: Icon(Icons.close, color: Colors.white, size: 32,),
                                  ),

                                  const SizedBox(height: 18,),

                                  const Text(
                                    'Report Delivery?',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF44336,),
                                    ),
                                  ),

                                  const SizedBox(height: 10,),

                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF4D4D4D,),
                                      ),
                                      children: [
                                        TextSpan(text: 'Email us at ',),
                                        TextSpan(text: 'movemate@gmail.com',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontStyle: FontStyle.italic,),
                                        ),
                                        TextSpan(
                                          text: '\nand we\'ll get back to you within 24 hours.',
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24,),

                                  Row(
                                    children: [
                                      Expanded(
                                        child:
                                        SizedBox(
                                          height: 48,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFF44336,),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10,),
                                                side: const BorderSide(
                                                  color: Color(0xFFFF8A3D,),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);

                                              context.go(
                                                RouteNames.userHome,
                                              );
                                            },
                                            child: const Text(
                                              'OK',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 16,),

                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: OutlinedButton(
                                            style:
                                            OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color:
                                                Colors.black,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed:
                                                () {
                                              Navigator.pop(
                                                  context);
                                            },
                                            child:
                                            const Text(
                                              'Cancel',
                                              style:
                                              TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Center(
                        child: Text(
                          'Report',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.w500,
                            color: Colors.black,
                          ),
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
}