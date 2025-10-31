import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
// Final app dependencies
//   geolocator: ^12.0.0
//   geocoding: ^3.0.0
//   http: ^1.2.1
//   supabase_flutter: ^2.0.0
//   panorama_viewer: ^1.0.3 
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:panorama_viewer/panorama_viewer.dart';


// The main entry point for the Flutter application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with your credentials
  await Supabase.initialize(
    url: 'https://sdlsjvqtzzvswnpxzrrh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkbHNqdnF0enp2c3ducHh6cnJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxMzQ2MzksImV4cCI6MjA3MzcxMDYzOX0.vLdrXRzF-VcKCBfNRGgmPbOgsQzHxYT8PKRnpHT1gWQ',
  );

  runApp(const AiTicketingApp());
}

// Helper to get the Supabase client instance
final supabase = Supabase.instance.client;

// --- Main App Theme ---
class AiTicketingApp extends StatelessWidget {
  const AiTicketingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nivi - Travel Planner',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF333333)),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF555555)),
          bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFF777777)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

// --- AuthGate Widget ---
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) {
          return const AuthPage();
        }
        return const LandingPage();
      },
    );
  }
}


// --- Auth Page (Login/Registration) ---
class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: _isLogin ? const LoginForm() : const SignupForm(),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? "Don't have an account?" : "Already have an account?",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin ? 'Signup' : 'Login',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() { _isLoading = true; });
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AuthException ? e.message : 'Login failed')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Welcome back, please login to your account',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 32),
        AuthTextField(
          controller: _emailController,
          hintText: 'Email', 
          icon: Icons.email_outlined
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _passwordController,
          hintText: 'Password', 
          icon: Icons.lock_outline, 
          obscureText: true
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _rememberMe = value;
                  });
                }
              },
              checkColor: Colors.white,
              activeColor: Colors.green,
              side: const BorderSide(color: Colors.white70),
            ),
            const Text('Remember me', style: TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 24),
        AuthButton(
          text: 'Login',
          isLoading: _isLoading,
          onPressed: _login,
        ),
      ],
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() { _isLoading = true; });
    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'username': _usernameController.text.trim()},
      );
      if (response.user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Check your email for confirmation.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AuthException ? e.message : 'Signup failed')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Create Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a new account to get started',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 32),
        AuthTextField(controller: _usernameController, hintText: 'User Name', icon: Icons.person_outline),
        const SizedBox(height: 16),
        AuthTextField(controller: _emailController, hintText: 'Email', icon: Icons.email_outlined),
        const SizedBox(height: 16),
        AuthTextField(controller: _passwordController, hintText: 'Password', icon: Icons.lock_outline, obscureText: true),
        const SizedBox(height: 32),
        AuthButton(
          text: 'Signup',
          isLoading: _isLoading,
          onPressed: _signup,
        ),
      ],
    );
  }
}


// --- Landing Page ---
class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/boat.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Explore Your\nFavorite Journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's make our life so a life",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const AppShell(),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'Go',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
    );
  }
}


// --- Data Models ---
class City {
  final String name;
  final String localName;

  const City({required this.name, required this.localName});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] ?? '',
      localName: json['localName'] ?? '',
    );
  }
}

class Destination {
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final String temperature;
  final String duration;
  final String description;
  final List<City> cities;
  final String category;
  final bool isFeatured;
  final String? arImageUrl;

  const Destination({
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.temperature,
    required this.duration,
    required this.description,
    this.cities = const [],
    required this.category,
    required this.isFeatured,
    this.arImageUrl,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    List<City> cityList = [];
    if (json['cities'] is String) {
      try {
        // Fix for Supabase CSV import escaping quotes
        final citiesString = (json['cities'] as String).replaceAll(r'\"', '"');
        final decoded = jsonDecode(citiesString) as List<dynamic>;
        cityList = decoded.map((cityJson) => City.fromJson(cityJson as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Error decoding cities JSON string: $e');
      }
    } else if (json['cities'] is List) {
       cityList = (json['cities'] as List<dynamic>)
          .map((cityJson) => City.fromJson(cityJson as Map<String, dynamic>))
          .toList();
    }


    return Destination(
      name: json['name'] ?? 'No Name',
      location: json['location'] ?? 'No Location',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      temperature: json['temperature'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      cities: cityList,
      category: json['category'] ?? 'All',
      isFeatured: json['is_featured'] ?? false,
      arImageUrl: json['ar_image_url'],
    );
  }
}


// --- App Shell ---
class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      HomePage(onProfileTap: () => _onItemTapped(3)),
      const MyTripsPage(),
      const AiPlannerPage(),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showNavBar = _selectedIndex != 2;

    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: showNavBar
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Trips'),
                      BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Plan'),
                      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
                    ],
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    selectedItemColor: const Color(0xFF007BFF),
                    unselectedItemColor: Colors.grey[400],
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}


// --- Screens ---

// 1. Home Page Screen
class HomePage extends StatefulWidget {
  final VoidCallback onProfileTap;
  const HomePage({Key? key, required this.onProfileTap}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Beach', 'Mountain', 'Temple', 'City'];
  String _currentAddress = 'Fetching location...';
  bool _isLoadingDestinations = true; // Use a specific loading state
  List<Destination> _allDestinations = [];

  final TextEditingController _searchController = TextEditingController();
  List<Destination> _filteredDestinations = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_filterDestinations);
  }
  
  Future<void> _loadInitialData() async {
    // Run both tasks in parallel, don't wait for location to fetch destinations
    _getCurrentLocation(); 
    await _fetchDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchDestinations() async {
     try {
      final response = await supabase.from('destinations').select();
      final destinations = (response as List<dynamic>)
          .map((json) => Destination.fromJson(json as Map<String, dynamic>))
          .toList();
      if(mounted) {
        setState(() {
          _allDestinations = destinations;
          _filteredDestinations = destinations;
          _isLoadingDestinations = false; // Set loading false here
        });
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch destinations: $e')),
        );
         setState(() {
          _isLoadingDestinations = false; // Also set false on error
        });
      }
    }
  }


  void _filterDestinations() {
    final query = _searchController.text.toLowerCase();
    final selectedCategory = _categories[_selectedCategoryIndex];

    setState(() {
      _filteredDestinations = _allDestinations.where((destination) {
        final matchesQuery = destination.name.toLowerCase().contains(query) ||
                             destination.location.toLowerCase().contains(query);
        final matchesCategory = selectedCategory == 'All' || destination.category == selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }


  Future<void> _getCurrentLocation() async {
     bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) setState(() => _currentAddress = 'Location services disabled');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) setState(() => _currentAddress = 'Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if(mounted) setState(() => _currentAddress = 'Location permanently denied');
      return;
    }

    try {
      // Added a time limit to prevent the function from hanging indefinitely
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10)
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if(mounted) setState(() => _currentAddress = "${place.locality}, ${place.country}");
      } else {
        if(mounted) setState(() => _currentAddress = 'Location not found');
      }
    } catch (e) {
      print(e);
      if(mounted) setState(() => _currentAddress = 'Error fetching location');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = supabase.auth.currentUser;
    final username = user?.userMetadata?['username'] as String?;
    final avatarLetter = (username != null && username.isNotEmpty) ? username[0].toUpperCase() : '?';

    final featured = _filteredDestinations.where((d) => d.isFeatured).toList();
    final popular = _filteredDestinations.where((d) => !d.isFeatured).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 24.0, bottom: 120.0),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(_currentAddress),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Text(avatarLetter, style: const TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('Discover\nNew Destination', style: textTheme.displayLarge),
            ),
            const SizedBox(height: 24),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search places',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.filter_list),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Tabs
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return CategoryTab(
                    text: _categories[index],
                    isSelected: _selectedCategoryIndex == index,
                    onTap: () {
                      setState(() => _selectedCategoryIndex = index);
                      _filterDestinations();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // UPDATED UI Logic
            _isLoadingDestinations
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ))
              : _filteredDestinations.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50.0),
                        child: Text(
                          'No results found',
                          style: textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (featured.isNotEmpty)
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: featured.length,
                              itemBuilder: (context, index) {
                                return DestinationCard(destination: featured[index]);
                              },
                            ),
                          ),
                        const SizedBox(height: 24),
                        
                        if (popular.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Popular', style: textTheme.titleLarge),
                                TextButton(onPressed: () {}, child: const Text('View All')),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        if (popular.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: popular.length,
                            itemBuilder: (context, index) {
                              return PopularDestinationTile(destination: popular[index]);
                            },
                          ),
                      ],
                    )
          ],
        ),
      ),
    );
  }
}

// 2. Destination Detail Page
class DestinationDetailPage extends StatelessWidget {
  final Destination destination;

  const DestinationDetailPage({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool showArButton = destination.arImageUrl != null && destination.arImageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(destination.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'EXPLORE ${destination.name.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  if (showArButton) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera),
                      label: const Text('Preview in AR'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ARPreviewPage(imageUrl: destination.arImageUrl!)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search City',
                      prefixIcon: const Icon(Icons.search, color: Colors.red),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: destination.cities.length,
                    itemBuilder: (context, index) {
                      final city = destination.cities[index];
                      return CityTile(city: city);
                    },
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

// 3. Profile Page
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
         bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 24.0, bottom: 120.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('Profile', style: textTheme.displayLarge),
            ),
            const SizedBox(height: 32),
            // User Info Section
            Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(user?.userMetadata?['username'] ?? 'Guest User', style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(user?.email ?? 'No email', style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 32),

            // Menu Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.payment,
                    title: 'Payment Methods',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.security,
                    title: 'Security',
                    onTap: () {},
                  ),
                  const Divider(height: 32),
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () async {
                      await supabase.auth.signOut();
                      // The AuthGate is listening at the root, so it will
                      // automatically navigate to the AuthPage.
                      // We just need to pop all screens on top of it.
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    textColor: Colors.red,
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

// 4. My Trips Page
class MyTripsPage extends StatefulWidget {
  const MyTripsPage({Key? key}) : super(key: key);

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  late Future<List<Map<String, dynamic>>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = _fetchTrips();
  }

  Future<List<Map<String, dynamic>>> _fetchTrips() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final response = await supabase.from('trips').select().eq('user_id', userId).order('created_at', ascending: false);
    return response;
  }

  void _refreshTrips() {
    setState(() {
      _tripsFuture = _fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 24.0, bottom: 120.0, left: 24.0, right: 24.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Trips', style: textTheme.displayLarge),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshTrips,
                ),
              ],
            ),
            const SizedBox(height: 32),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _tripsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final trips = snapshot.data;
                if (trips == null || trips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Icon(Icons.article_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No Trips Yet',
                          style: textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your booked trips will appear here.',
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return TripCard(
                      destinationName: trip['destination_name'] ?? 'Unnamed Trip',
                      itineraryDetails: trip['itinerary_details'] ?? 'No details.',
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


// 5. AI Planner Page
class AiPlannerPage extends StatefulWidget {
  const AiPlannerPage({Key? key}) : super(key: key);

  @override
  _AiPlannerPageState createState() => _AiPlannerPageState();
}

class _AiPlannerPageState extends State<AiPlannerPage> {
  final List<Widget> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _lastItinerary = '';
  String _lastDestination = '';
  bool _isBooking = false;

  final String _apiKey = 'AIzaSyAbl1hUKErmmDYbR6DxlBEQasaib7t4yOM';

  @override
  void initState() {
    super.initState();
    _messages.add(const AiGreetingBubble());
  }
  
  Future<void> _getAiResponse(String prompt) async {
    setState(() {
      _lastItinerary = '';
      _messages.add(const AiTypingBubble());
    });
    _scrollToBottom();

    final String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_apiKey';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': 'You are a travel planning assistant named Nivi. Generate a concise, exciting, and bookable travel itinerary based on the following user request. For the destination, make up a suitable title (e.g., "Romantic Bali Getaway"). For each day, provide a title and a short description. Also, include a dynamic price estimate for the whole trip and suggest 2-3 contextual upsells. Format the entire response nicely, starting with the destination title. User request: "$prompt"'}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      setState(() { _messages.removeLast(); });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        
        setState(() {
          _lastItinerary = generatedText;
          _lastDestination = generatedText.split('\n').first; 
          _messages.add(AiMessageBubble(
            text: generatedText, 
            onBookNow: _showBookingConfirmation,
          ));
        });
      } else {
        setState(() {
          _messages.add(const AiMessageBubble(text: "Sorry, I couldn't generate a plan right now. Please check your API key or try again later."));
        });
        print('API Error: ${response.body}');
      }
    } catch (e) {
       setState(() {
        _messages.removeLast();
        _messages.add(const AiMessageBubble(text: "Sorry, something went wrong. Please check your internet connection."));
      });
      print('Error: $e');
    }

    _scrollToBottom();
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Booking'),
          content: Text('Are you sure you want to book this trip to $_lastDestination?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Book'),
              onPressed: () {
                Navigator.of(context).pop();
                _bookTrip();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _bookTrip() async {
    setState(() { _isBooking = true; });
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || _lastItinerary.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not book trip. User not logged in or no itinerary generated.')),
      );
      setState(() { _isBooking = false; });
      return;
    }

    try {
      await supabase.from('trips').insert({
        'user_id': userId,
        'destination_name': _lastDestination,
        'itinerary_details': _lastItinerary,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip booked successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking trip: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isBooking = false; });
      }
    }
  }


  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(UserMessageBubble(text: text));
    });
     _scrollToBottom();

    _getAiResponse(text);
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('AI Trip Planner'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          if (_isBooking) const LinearProgressIndicator(),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _handleSubmitted,
                    decoration: InputDecoration(
                      hintText: 'e.g., Plan a 5-day trip to Bali...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () => _handleSubmitted(_textController.text),
                  child: const Icon(Icons.send),
                  backgroundColor: const Color(0xFF007BFF),
                  elevation: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// --- Custom Clipper for the Wave Shape ---
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.2, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.2), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- Reusable Widgets ---

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }
}

class CityTile extends StatelessWidget {
  final City city;
  const CityTile({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                city.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                city.localName,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
          const Icon(Icons.check_circle, color: Colors.red),
        ],
      ),
    );
  }
}


class CategoryTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTab({Key? key, required this.text, required this.isSelected, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007BFF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DestinationDetailPage(destination: destination))),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                destination.imageUrl,
                fit: BoxFit.cover,
                // Add error builder for handling failed image loads
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                )),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${destination.name}\n${destination.location}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PopularDestinationTile extends StatelessWidget {
  final Destination destination;
  const PopularDestinationTile({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DestinationDetailPage(destination: destination))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.network(
                  destination.imageUrl,
                  fit: BoxFit.cover,
                  // Add error builder for handling failed image loads
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(destination.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(destination.location, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- AI Planner Widgets ---
class AiGreetingBubble extends StatelessWidget {
  const AiGreetingBubble({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const AiMessageBubble(
      text: "Hello! I'm Nivi. How can I help you plan your next adventure today?",
    );
  }
}

class UserMessageBubble extends StatelessWidget {
  final String text;
  const UserMessageBubble({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF007BFF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

class AiTypingBubble extends StatelessWidget {
  const AiTypingBubble({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text("Nivi is planning...", style: TextStyle(color: Colors.grey)),
    );
  }
}

class AiMessageBubble extends StatelessWidget {
  final String text;
  final VoidCallback? onBookNow;
  const AiMessageBubble({Key? key, required this.text, this.onBookNow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (onBookNow != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onBookNow,
                  child: const Text('Book This Trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}


// --- Reusable Auth Widgets ---

class AuthTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController controller;

  const AuthTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const AuthButton({
    Key? key, 
    required this.text, 
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.transparent, // Important for gradient
        shadowColor: Colors.transparent,
      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 50.0),
          child: isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
        ),
      ),
    );
  }
}

// --- TripCard Widget ---
class TripCard extends StatelessWidget {
  final String destinationName;
  final String itineraryDetails;
  
  const TripCard({
    Key? key,
    required this.destinationName,
    required this.itineraryDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailPage(
            destinationName: destinationName,
            itineraryDetails: itineraryDetails,
          )));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destinationName, // Corrected variable
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(height: 24),
              Text(
                itineraryDetails,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TripDetailPage Widget ---
class TripDetailPage extends StatelessWidget {
  final String destinationName;
  final String itineraryDetails;

  const TripDetailPage({
    Key? key,
    required this.destinationName,
    required this.itineraryDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destinationName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          itineraryDetails,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ),
    );
  }
}

// --- ARPreviewPage Widget ---
class ARPreviewPage extends StatelessWidget {
  final String imageUrl;
  const ARPreviewPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PanoramaViewer( // Corrected widget name
            child: Image.network(imageUrl),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

