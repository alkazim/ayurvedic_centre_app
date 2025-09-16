import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
        
            height: 217,
            color: Colors.green,
            child: Image(image: AssetImage('lib\assets\images\Login_Image.png'),),
          ),
           Container(
            padding: EdgeInsets.all(18),
            width: MediaQuery.of(context).size.width,
            child: Text("Login Or register To Book \nYour Appointments",style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),),
           ),
            
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.all(18),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text("Email",style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),),
                ),
                  SizedBox(height:10),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFf5f5f5),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      border: Border.all(
            
                        color: Color(0xFFdddddd),
                        width: 2
                      )
                    ),
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your email',
                          
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),  



          Container(
            padding: EdgeInsets.all(18),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text("Password",style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),),
                ),
                  SizedBox(height:10),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFf5f5f5),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      border: Border.all(
            
                        color: Color(0xFFdddddd),
                        width: 2
                      )
                    ),
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter password',
                          
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
           SizedBox(height:40),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(onPressed: (){}, 
              child: Text("Login",style: TextStyle(
                color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),),
              
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.52)),
                backgroundColor: Color(0xFF006837)
              ),
              
                    ),

            
            ),
          ) ,
          Expanded(
            child: Container(
              height: 40,
              //color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.only(bottom:25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[ RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black, // default text color
                      ),
                      children: [
                        TextSpan(
                          text: "By creating or logging into an account you are agreeing with our ",
                          style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Poppins',
                    ),
                        ),
                        TextSpan(
                          text: "Terms and Conditions",
                          style: TextStyle(
                            color: Colors.blue, // clickable style
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: " and ",
                        ),
                        TextSpan(
                          text: "Privacy Policy.",
                          style: TextStyle(
                            color: Colors.blue, // clickable style
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                        ]),
              )


          ),),

        ],
      ),
    );
  }
}