import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
  decoration: BoxDecoration(
    //border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    spacing: 12,
    children: [
      Expanded(
        child: Container(
          height: 45,
          decoration: BoxDecoration(
// color: Colors.red,
borderRadius: BorderRadius.all(Radius.circular(8)),
 border: Border.all(

  color: Color(0xFFb3b3b3)
 )
          ),
         
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search for treatments',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ),
          ),
        ),
      ),
      Container(
        height: 45,
        decoration: const BoxDecoration(
          color: Color(0xFF2E7D32),
          borderRadius: BorderRadius.all(
            Radius.circular(8)
          ),
        ),
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
          
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: const RoundedRectangleBorder(
            
              borderRadius: BorderRadius.all(
                Radius.circular(8)
              ),
            ),
          ),
          child: const Text(
            'Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ],
  ),
),

            
            const SizedBox(height: 16),
            


            Row(
  children: [
    const Text(
      'Sort by :',
      style: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    ),
    const Spacer(),
    Container(
      height: 40,
      width: 169,
      //padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5,right:5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Date',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.green.shade600,
              size: 24,
            ),
          ],
        ),
      ),
    ),
  ],
),

SizedBox(height: 10,),


            Container(
              width: double.infinity,
              height: 2,
              color: Color(0xfff1f1f1),
            ),
            
            const SizedBox(height: 20),
            
            // Booking Cards List
            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Container(
  margin: const EdgeInsets.only(bottom: 16),
  //padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFFf1f1f1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ],
  ),
  child: Column(
    spacing: 2,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left:12,top:12),
        child: Row(
          children: [
            const Text(
              '1.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Vikram Singh',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 6),
      
      Padding(
        padding: const EdgeInsets.only(left:25),
        child: const Text(
          'Couple Combo Package (Rejuven...',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF006837),
          ),
        ),
      ),
      
      const SizedBox(height: 12),
      
      Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Colors.red.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              '31/01/2024',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.red.shade400,
              ),
            ),
            
            const SizedBox(width: 20),
            
            Icon(
              Icons.person_outline,
              size: 16,
              color: Colors.red.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              'Jithesh',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 12),
      Container(
        height:1.5,
        width: double.infinity,
        color: Color(0xFFc1c1c1),
      ),
      
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Row(
              
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'View Booking details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
);

                },
              ),
            ),
            
            // Register Now Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006837),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Register Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
