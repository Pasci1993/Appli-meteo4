import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 


const String API_KEY = '1abf3d1674416de116e95e86dfa252df'; 
const String BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';

void main() {
  runApp(MonApplication());
}

class MonApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application Météo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PrevisionInterface(),
    );
  }
}
class PrevisionInterface extends StatefulWidget {
  @override
  _PrevisionInterfaceState createState() => _PrevisionInterfaceState();
}

class _PrevisionInterfaceState extends State<PrevisionInterface> {

  final TextEditingController _villeController = TextEditingController();
  bool _isLoading = false; 
  Map<String, dynamic>? _DonneesMeteo; 
  String? _erreur; 
  Future<void> _RecupererDonnees() async {
    final ville = _villeController.text.trim();
    if (ville.isEmpty) {
      setState(() {
        _erreur = "Veuillez entrer le nom d'une ville.";
        _DonneesMeteo = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _DonneesMeteo = null;
      _erreur = null;
    });

    try {
      final url = Uri.parse('$BASE_URL?q=$ville&appid=$API_KEY&units=metric&lang=fr');
      
      final reponse = await http.get(url);

      if (reponse.statusCode == 200) {
        final donneesDecodes = json.decode(reponse.body) as Map<String, dynamic>;
        setState(() {
          _DonneesMeteo = donneesDecodes;
        });
      } else if (reponse.statusCode == 404) {
        setState(() {
          _erreur = "Ville non trouvée. Vérifiez le nom de la ville.";
        });
      } else {
        setState(() {
          _erreur = "Erreur de l'API: ${reponse.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _erreur = "Erreur de connexion : impossible d'atteindre le service météo. ($e)";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prévisions météo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _villeController,
              decoration: InputDecoration(
                labelText: "Entrez le nom d'une ville",
                hintText: 'Ex: Lomé',
              ),
              onSubmitted: (_) => _RecupererDonnees(), 
            ),
            
            SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _RecupererDonnees,
              child: Text('Obtenir la météo'),
            ),
            
            SizedBox(height: 30),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_erreur != null)
              Text(
                'Erreur: $_erreur',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              )
            else if (_DonneesMeteo != null)
              Expanded(
                child: DonneesMeteoWidget(donneesMeteo: _DonneesMeteo!),
              )
            else
              Text('Aucune donnée météo disponible.', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
class DonneesMeteoWidget extends StatelessWidget {
  final Map<String, dynamic> donneesMeteo;

  const DonneesMeteoWidget({Key? key, required this.donneesMeteo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String nomVille = donneesMeteo['name'];
    final double temperature = donneesMeteo['main']['temp'];
    final String description = donneesMeteo['weather'][0]['description'];
    final int humidite = donneesMeteo['main']['humidity'];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            nomVille,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '${temperature.toStringAsFixed(1)}°C',
            style: TextStyle(fontSize: 48, color: Colors.blueAccent),
          ),
          SizedBox(height: 10),
          Text(
            description.toUpperCase(),
            style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 20),
          Text(
            'Humidité: $humidite%',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}