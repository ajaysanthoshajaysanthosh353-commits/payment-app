import'package:flutter/material.dart';

class SecurityScreen extends StatelessWidget{
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {

    var scaffold = Scaffold(
      appBar: AppBar(
        
        title: const Text('Security'),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.lock, color: Colors.red),
            title: Text('Change Password'),
            subtitle: Text('Update your account password for security.'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.fingerprint, color: Colors.blue),
            title: Text('Biometric Authentication'),
            subtitle: Text('Enable fingerprint or face recognition for login.'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.security, color: Colors.orange),
            title: Text('Two-Factor Authentication'),
            subtitle: Text('Add an extra layer of security to your account.'),
          ),
          ListTile(
            leading: Icon(Icons.security, color: Colors.green),
            title: Text('Password Recovery Options'),
            subtitle: Text('Manage your password recovery preferences.'),
            trailing: Icon(Icons.arrow_forward_ios),
            
          ),
          
        ],
      ),
    );
    return scaffold;
  }
}
