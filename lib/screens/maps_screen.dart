import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shopnav/models/contact.dart';
import 'package:shopnav/utils/colors.dart';
import 'package:shopnav/main.dart';
import 'package:provider/provider.dart';
import 'package:shopnav/providers/theme_provider.dart';

class MapsScreen extends StatefulWidget {
  final List<Contact> contacts;
  final Function(Screen) onNavigate;

  const MapsScreen({
    super.key,
    required this.contacts,
    required this.onNavigate,
  });

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? _mapController;
  Contact? _selectedContact;
  bool _showSettings = false;
  bool _showShoppingModal = false;
  String _selectedShoppingName = 'Todos os Shoppings';
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isTracingRoute = false;
  
  static const LatLng _initialPosition = LatLng(-5.08907, -42.8111501);
  
  bool _usingGPS = false;
  
  final Map<String, bool> _mapSettings = {
    'customMarker': false,
    'showRoutes': false,
    'showPolygons': false,
    'show3D': false,
  };

  final List<String> _availableShoppings = [
    'Todos os Shoppings',
    'Shopping da Cidade',
    'Teresina Shopping',
    'Riverside Shopping',
    'Shopping Popular',
  ];

  final Map<String, Color> _categoryColors = {
    'Moda': AppColors.pink,
    'Eletrônicos': Colors.blue,
    'Alimentação': AppColors.orange,
    'Esportes': Colors.green,
    'Entretenimento': AppColors.purple,
    'Serviços': AppColors.cyan,
  };

  final Map<String, LatLng> _shoppingCoordinates = {
    'Shopping da Cidade': const LatLng(-5.088944, -42.803611),
    'Teresina Shopping': const LatLng(-5.095556, -42.815833),
    'Riverside Shopping': const LatLng(-5.080556, -42.780278),
    'Shopping Popular': const LatLng(-5.093611, -42.804444),
  };

  final List<ShoppingMall> _teresinaShoppings = [
    ShoppingMall(
      id: '1',
      name: 'Shopping da Cidade',
      address: 'Av. Frei Serafim, 2000 - Centro',
      lat: -5.088944,
      lng: -42.803611,
      icon: Icons.store_mall_directory,
      floors: 3,
      storesCount: 9,
      openingHours: '10:00 - 22:00',
      phone: '(86) 3221-0000',
      website: 'www.shoppingdacidade.com',
      description: 'Maior shopping de Teresina com diversas opções de lazer e compras',
      imageUrl: 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400&h=200&fit=crop',
      categories: ['Moda', 'Alimentação', 'Eletrônicos', 'Entretenimento'],
      fakeMapLayout: [
        FakeStore(lat: -5.088944, lng: -42.803611, name: 'Entrada Principal', category: 'Serviços'),
        FakeStore(lat: -5.088944, lng: -42.803511, name: 'Praça de Alimentação', category: 'Alimentação'),
        FakeStore(lat: -5.088844, lng: -42.803611, name: 'Área de Lazer', category: 'Entretenimento'),
        FakeStore(lat: -5.088844, lng: -42.803511, name: 'Cinema', category: 'Entretenimento'),
        FakeStore(lat: -5.089044, lng: -42.803611, name: 'Estacionamento', category: 'Serviços'),
        FakeStore(lat: -5.088944, lng: -42.803711, name: 'Lojas Piso 1', category: 'Moda'),
        FakeStore(lat: -5.088744, lng: -42.803611, name: 'Lojas Piso 2', category: 'Eletrônicos'),
        FakeStore(lat: -5.088644, lng: -42.803611, name: 'Lojas Piso 3', category: 'Esportes'),
      ],
    ),
    ShoppingMall(
      id: '2',
      name: 'Teresina Shopping',
      address: 'Av. Raul Lopes, 1000 - Noivos',
      lat: -5.095556,
      lng: -42.815833,
      icon: Icons.local_mall,
      floors: 2,
      storesCount: 6,
      openingHours: '10:00 - 22:00',
      phone: '(86) 3222-1111',
      website: 'www.teresinashopping.com',
      description: 'Shopping moderno com foco em moda e gastronomia',
      imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400&h=200&fit=crop',
      categories: ['Moda', 'Alimentação'],
      fakeMapLayout: [
        FakeStore(lat: -5.095556, lng: -42.815833, name: 'Entrada Principal', category: 'Serviços'),
        FakeStore(lat: -5.095456, lng: -42.815833, name: 'Área Gourmet', category: 'Alimentação'),
        FakeStore(lat: -5.095656, lng: -42.815833, name: 'Moda Feminina', category: 'Moda'),
        FakeStore(lat: -5.095556, lng: -42.815733, name: 'Moda Masculina', category: 'Moda'),
        FakeStore(lat: -5.095556, lng: -42.815933, name: 'Lazer Infantil', category: 'Entretenimento'),
        FakeStore(lat: -5.095756, lng: -42.815833, name: 'Serviços', category: 'Serviços'),
      ],
    ),
    ShoppingMall(
      id: '3',
      name: 'Riverside Shopping',
      address: 'Av. Maranhão, 3000 - Buenos Aires',
      lat: -5.080556,
      lng: -42.780278,
      icon: Icons.shopping_bag,
      floors: 4,
      storesCount: 9,
      openingHours: '09:00 - 23:00',
      phone: '(86) 3223-2222',
      website: 'www.riversideshopping.com',
      description: 'Shopping premium às margens do Rio Poti',
      imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400&h=200&fit=crop',
      categories: ['Moda', 'Eletrônicos', 'Alimentação', 'Esportes', 'Entretenimento'],
      fakeMapLayout: [
        FakeStore(lat: -5.080556, lng: -42.780278, name: 'Entrada Principal', category: 'Serviços'),
        FakeStore(lat: -5.080456, lng: -42.780278, name: 'Praça Central', category: 'Alimentação'),
        FakeStore(lat: -5.080656, lng: -42.780278, name: 'Cinema IMAX', category: 'Entretenimento'),
        FakeStore(lat: -5.080556, lng: -42.780178, name: 'Área Esportiva', category: 'Esportes'),
        FakeStore(lat: -5.080556, lng: -42.780378, name: 'Eletrônicos', category: 'Eletrônicos'),
        FakeStore(lat: -5.080756, lng: -42.780278, name: 'Moda Premium', category: 'Moda'),
        FakeStore(lat: -5.080356, lng: -42.780278, name: 'Praça de Alimentação', category: 'Alimentação'),
        FakeStore(lat: -5.080656, lng: -42.780378, name: 'Brinquedoteca', category: 'Entretenimento'),
      ],
    ),
    ShoppingMall(
      id: '4',
      name: 'Shopping Popular',
      address: 'Rua Areolino de Abreu, 500 - Centro',
      lat: -5.093611,
      lng: -42.804444,
      icon: Icons.attach_money,
      floors: 1,
      storesCount: 5,
      openingHours: '08:00 - 20:00',
      phone: '(86) 3224-3333',
      website: 'www.shoppingpopular.com',
      description: 'Shopping popular com preços acessíveis',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=200&fit=crop',
      categories: ['Moda', 'Serviços'],
      fakeMapLayout: [
        FakeStore(lat: -5.093611, lng: -42.804444, name: 'Entrada Única', category: 'Serviços'),
        FakeStore(lat: -5.093511, lng: -42.804444, name: 'Setor de Moda', category: 'Moda'),
        FakeStore(lat: -5.093711, lng: -42.804444, name: 'Setor de Serviços', category: 'Serviços'),
        FakeStore(lat: -5.093611, lng: -42.804344, name: 'Lanchonetes', category: 'Alimentação'),
        FakeStore(lat: -5.093611, lng: -42.804544, name: 'Lojas Diversas', category: 'Moda'),
      ],
    ),
  ];

  ShoppingMall? _selectedShopping;
  bool _showFakeMap = false;
  bool _showRouteToShopping = false;

  String _getShoppingNameForContact(Contact contact) {
    final contactId = contact.id.toLowerCase();
    
    if (contactId.startsWith('sc_')) {
      return 'Shopping da Cidade';
    } else if (contactId.startsWith('ts_')) {
      return 'Teresina Shopping';
    } else if (contactId.startsWith('rs_')) {
      return 'Riverside Shopping';
    } else if (contactId.startsWith('sp_')) {
      return 'Shopping Popular';
    }
    
    if (contact.lat > -5.085 && contact.lat < -5.091 && contact.lng > -42.800 && contact.lng < -42.806) {
      return 'Shopping da Cidade';
    } else if (contact.lat > -5.093 && contact.lat < -5.098 && contact.lng > -42.813 && contact.lng < -42.818) {
      return 'Teresina Shopping';
    } else if (contact.lat > -5.077 && contact.lat < -5.083 && contact.lng > -42.777 && contact.lng < -42.783) {
      return 'Riverside Shopping';
    } else if (contact.lat > -5.092 && contact.lat < -5.095 && contact.lng > -42.803 && contact.lng < -42.806) {
      return 'Shopping Popular';
    }
    
    return 'Shopping Center';
  }

  int _countStoresForShopping(String shoppingName) {
    if (shoppingName == 'Todos os Shoppings') {
      return widget.contacts.length;
    }
    
    return widget.contacts.where((contact) {
      final contactShoppingName = _getShoppingNameForContact(contact);
      return contactShoppingName == shoppingName;
    }).length;
  }

  ShoppingMall? _getShoppingForContact(Contact contact) {
    final shoppingName = _getShoppingNameForContact(contact);
    return _teresinaShoppings.firstWhere(
      (shopping) => shopping.name == shoppingName,
      orElse: () => _teresinaShoppings[0],
    );
  }

  @override
  void initState() {
    super.initState();
    _setInitialPosition();
  }

  void _setInitialPosition() {
    _currentPosition = Position(
      latitude: _initialPosition.latitude,
      longitude: _initialPosition.longitude,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Serviço de localização desativado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permissão de localização negada'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de localização permanentemente negada. Ative nas configurações do dispositivo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _usingGPS = true;
      });

      _addUserMarker();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Localização obtida: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addUserMarker() {
    if (_currentPosition != null) {
      _markers.removeWhere((marker) => marker.markerId.value == 'user_location');
      
      final markerTitle = _usingGPS ? 'Sua Localização (GPS)' : 'IFPI Campus Teresina Central';
      final markerColor = _usingGPS ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure;
      
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
          infoWindow: InfoWindow(title: markerTitle),
          zIndex: 3,
        ),
      );
      
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            16,
          ),
        );
      }
      
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _updateMarkers() {
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('store_'));
    _polylines.clear();

    if (_currentPosition != null) {
      final markerTitle = _usingGPS ? 'Sua Localização (GPS)' : 'IFPI Campus Teresina Central';
      final markerColor = _usingGPS ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure;
      
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
          infoWindow: InfoWindow(title: markerTitle),
          zIndex: 3,
        ),
      );
    }

    for (var contact in widget.contacts) {
      final shoppingName = _getShoppingNameForContact(contact);
      
      if (_selectedShoppingName == 'Todos os Shoppings' || shoppingName == _selectedShoppingName) {
        final color = _categoryColors[contact.category ?? 'Moda'] ?? AppColors.pink;
        
        _markers.add(
          Marker(
            markerId: MarkerId('store_${contact.id}'),
            position: LatLng(contact.lat, contact.lng),
            infoWindow: InfoWindow(
              title: contact.name,
              snippet: '${contact.category} • ${contact.floor}\n$shoppingName',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getHueFromColor(color),
            ),
            onTap: () => _showMarkerOptions(contact),
          ),
        );
      }
    }

    if (_selectedShoppingName != 'Todos os Shoppings' && 
        _shoppingCoordinates.containsKey(_selectedShoppingName)) {
      final center = _shoppingCoordinates[_selectedShoppingName]!;
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(center, 16),
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  // MÉTODO PARA CALCULAR ROTA PELAS RUAS
  List<LatLng> _calculateStreetRoute(LatLng start, LatLng end) {
    final List<LatLng> routePoints = [start];
    
    // Adicionar pontos intermediários para simular uma rota pelas ruas
    // Calculando 25%, 50% e 75% do caminho com pequenos desvios
    for (int i = 1; i <= 3; i++) {
      final double fraction = i / 4;
      final double lat = start.latitude + (end.latitude - start.latitude) * fraction;
      final double lng = start.longitude + (end.longitude - start.longitude) * fraction;
      
      // Adicionar pequeno desvio para simular curvas de ruas
      final double deviation = 0.0003;
      final double deviatedLat = lat + (i.isOdd ? deviation : -deviation);
      final double deviatedLng = lng + (i.isEven ? deviation : -deviation);
      
      routePoints.add(LatLng(deviatedLat, deviatedLng));
    }
    
    routePoints.add(end);
    return routePoints;
  }

  // MÉTODO PARA CALCULAR DISTÂNCIA ENTRE DOIS PONTOS
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0;
    
    final phi1 = lat1 * (pi / 180.0);
    final phi2 = lat2 * (pi / 180.0);
    final deltaPhi = (lat2 - lat1) * (pi / 180.0);
    final deltaLambda = (lng2 - lng1) * (pi / 180.0);
    
    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) *
        sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return R * c;
  }

  void _showMarkerOptions(Contact contact) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _categoryColors[contact.category ?? 'Moda'] ?? AppColors.pink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          contact.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            '${contact.category} • ${_getShoppingNameForContact(contact)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: AppColors.purple,
                ),
                title: Text(
                  'Ver detalhes da loja',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showStoreDetails(contact);
                },
              ),
              
              ListTile(
                leading: Icon(
                  Icons.route,
                  color: Colors.green,
                ),
                title: Text(
                  'Traçar rota pelas ruas',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Distância: ${_calculateDistanceToContact(contact).toStringAsFixed(2)} km',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _traceRouteToStore(contact);
                },
              ),
              
              ListTile(
                leading: Icon(
                  Icons.center_focus_strong,
                  color: Colors.blue,
                ),
                title: Text(
                  'Centralizar no mapa',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (_mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(contact.lat, contact.lng),
                        18,
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 8),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                      foregroundColor: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Fechar'),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  double _calculateDistanceToContact(Contact contact) {
    if (_currentPosition == null) return 0.0;
    
    final userLat = _currentPosition!.latitude;
    final userLng = _currentPosition!.longitude;
    
    const R = 6371000.0;
    
    final lat1 = userLat * (pi / 180.0);
    final lat2 = contact.lat * (pi / 180.0);
    final dLat = (contact.lat - userLat) * (pi / 180.0);
    final dLng = (contact.lng - userLng) * (pi / 180.0);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return (R * c) / 1000;
  }

  // MÉTODO PRINCIPAL PARA TRAÇAR ROTA PELAS RUAS PARA LOJAS
  Future<void> _traceRouteToStore(Contact contact) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível obter sua localização'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isTracingRoute = true);

    try {
      _polylines.clear();

      final userPosition = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final storePosition = LatLng(contact.lat, contact.lng);

      // Calcular rota pelas ruas
      final routePoints = _calculateStreetRoute(userPosition, storePosition);
      
      // Calcular distância real aproximada
      double totalDistance = 0;
      for (int i = 0; i < routePoints.length - 1; i++) {
        totalDistance += _calculateDistance(
          routePoints[i].latitude,
          routePoints[i].longitude,
          routePoints[i + 1].latitude,
          routePoints[i + 1].longitude,
        );
      }

      final routeColor = _usingGPS ? Colors.green : AppColors.purple;
      
      final polyline = Polyline(
        polylineId: PolylineId('route_to_${contact.id}'),
        points: routePoints,
        color: routeColor,
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        patterns: [PatternItem.dash(25), PatternItem.gap(10)],
        zIndex: 1,
      );

      _polylines.add(polyline);

      // Calcular bounds para incluir toda a rota
      double minLat = routePoints[0].latitude;
      double maxLat = routePoints[0].latitude;
      double minLng = routePoints[0].longitude;
      double maxLng = routePoints[0].longitude;
      
      for (final point in routePoints) {
        minLat = point.latitude < minLat ? point.latitude : minLat;
        maxLat = point.latitude > maxLat ? point.latitude : maxLat;
        minLng = point.longitude < minLng ? point.longitude : minLng;
        maxLng = point.longitude > maxLng ? point.longitude : maxLng;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }

      // Mostrar informações detalhadas da rota
      _showRouteDetails(contact, totalDistance);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao traçar rota: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isTracingRoute = false);
    }
  }

  // MÉTODO PARA MOSTRAR DETALHES DA ROTA
  void _showRouteDetails(Contact contact, double distance) {
    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        final isDarkMode = themeProvider.isDarkMode;
        
        // Calcular tempo estimado
        final walkingTime = (distance / 1000 / 5 * 60).toInt();
        final drivingTime = (distance / 1000 / 50 * 60).toInt();
        
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Rota Calculada',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.name,
                style: TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.route, color: Colors.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distância total:',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${(distance / 1000).toStringAsFixed(2)} km',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.directions_walk, color: Colors.green, size: 18),
                          const SizedBox(height: 4),
                          Text(
                            '$walkingTime min',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Caminhando',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.directions_car, color: Colors.orange, size: 18),
                          const SizedBox(height: 4),
                          Text(
                            '$drivingTime min',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'De carro',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.purple, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rota simulada pelas ruas principais',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fechar',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showStoreDetails(contact);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ver Detalhes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateFakeMapMarkers(ShoppingMall shopping) {
    _markers.clear();
    _polylines.clear();
    
    if (_currentPosition != null) {
      final markerTitle = _usingGPS ? 'Sua Localização (GPS)' : 'IFPI Campus Teresina Central';
      final markerColor = _usingGPS ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure;
      
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
          infoWindow: InfoWindow(title: markerTitle),
          zIndex: 3,
        ),
      );
    }
    
    _markers.add(
      Marker(
        markerId: const MarkerId('shopping_center'),
        position: LatLng(shopping.lat, shopping.lng),
        infoWindow: InfoWindow(
          title: shopping.name,
          snippet: 'Shopping selecionado',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    );
    
    for (var store in shopping.fakeMapLayout) {
      final color = _categoryColors[store.category] ?? AppColors.pink;
      
      _markers.add(
        Marker(
          markerId: MarkerId('fake_store_${store.name}'),
          position: LatLng(store.lat, store.lng),
          infoWindow: InfoWindow(
            title: store.name,
            snippet: '${store.category}\n${shopping.name}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getHueFromColor(color),
          ),
          onTap: () => _showFakeMarkerOptions(store, shopping),
        ),
      );
    }
    
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(shopping.lat, shopping.lng),
          17,
        ),
      );
    }
    
    setState(() {});
  }

  void _showFakeMarkerOptions(FakeStore store, ShoppingMall shopping) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final color = _categoryColors[store.category] ?? AppColors.pink;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _getIconForCategory(store.category),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            '${store.category} • ${shopping.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: AppColors.purple,
                ),
                title: Text(
                  'Ver detalhes',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showFakeStoreDetails(store, shopping);
                },
              ),
              
              ListTile(
                leading: Icon(
                  Icons.center_focus_strong,
                  color: Colors.blue,
                ),
                title: Text(
                  'Centralizar no mapa',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (_mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(store.lat, store.lng),
                        18,
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 8),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                      foregroundColor: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Fechar'),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Moda':
        return Icons.shopping_bag;
      case 'Eletrônicos':
        return Icons.electrical_services;
      case 'Alimentação':
        return Icons.restaurant;
      case 'Esportes':
        return Icons.sports_soccer;
      case 'Entretenimento':
        return Icons.movie;
      case 'Serviços':
        return Icons.business_center;
      default:
        return Icons.store;
    }
  }

  void _showFakeStoreDetails(FakeStore store, ShoppingMall shopping) {
    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        final isDarkMode = themeProvider.isDarkMode;
        final color = _categoryColors[store.category] ?? AppColors.pink;
        
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            store.name,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      shopping.name,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.category,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '📍 Localização:',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${store.lat.toStringAsFixed(6)}, ${store.lng.toStringAsFixed(6)}',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '📝 Observação:',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Esta é uma representação visual do layout do shopping. As posições são ilustrativas.',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fechar',
                style: TextStyle(
                  color: AppColors.purple,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // MÉTODO PARA TRAÇAR ROTA PELAS RUAS PARA SHOPPINGS
  Future<void> _traceRouteToShopping(ShoppingMall shopping) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível obter sua localização'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isTracingRoute = true;
      _showRouteToShopping = true;
      _selectedShopping = shopping;
      _showFakeMap = false;
    });

    try {
      _polylines.clear();
      _markers.clear();

      final markerTitle = _usingGPS ? 'Sua Localização (GPS)' : 'IFPI Campus Teresina Central';
      final markerColor = _usingGPS ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure;
      
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
          infoWindow: InfoWindow(title: markerTitle),
          zIndex: 3,
        ),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('shopping_destination'),
          position: LatLng(shopping.lat, shopping.lng),
          infoWindow: InfoWindow(
            title: shopping.name,
            snippet: 'Destino',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );

      final userPosition = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final shoppingPosition = LatLng(shopping.lat, shopping.lng);

      // Calcular rota pelas ruas para shopping também
      final routePoints = _calculateStreetRoute(userPosition, shoppingPosition);
      
      // Calcular distância
      double totalDistance = 0;
      for (int i = 0; i < routePoints.length - 1; i++) {
        totalDistance += _calculateDistance(
          routePoints[i].latitude,
          routePoints[i].longitude,
          routePoints[i + 1].latitude,
          routePoints[i + 1].longitude,
        );
      }

      final routeColor = _usingGPS ? Colors.green : Colors.green;
      
      final polyline = Polyline(
        polylineId: const PolylineId('route_to_shopping'),
        points: routePoints,
        color: routeColor,
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        zIndex: 1,
      );

      _polylines.add(polyline);

      // Calcular bounds
      double minLat = routePoints[0].latitude;
      double maxLat = routePoints[0].latitude;
      double minLng = routePoints[0].longitude;
      double maxLng = routePoints[0].longitude;
      
      for (final point in routePoints) {
        minLat = point.latitude < minLat ? point.latitude : minLat;
        maxLat = point.latitude > maxLat ? point.latitude : maxLat;
        minLng = point.longitude < minLng ? point.longitude : minLng;
        maxLng = point.longitude > maxLng ? point.longitude : maxLng;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }

      // Calcular tempos estimados
      final walkingTime = (totalDistance / 1000 / 5 * 60).toInt();
      final drivingTime = (totalDistance / 1000 / 50 * 60).toInt();
      
      // Mostrar informações da rota
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            final isDarkMode = themeProvider.isDarkMode;
            
            return AlertDialog(
              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Rota Calculada!',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shopping.name,
                    style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shopping.address,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📏 Distância: ${(totalDistance / 1000).toStringAsFixed(1)} km',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.directions_walk, size: 14, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              '$walkingTime min caminhando',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.directions_car, size: 14, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text(
                              '$drivingTime min de carro',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (_usingGPS) ...[
                          const SizedBox(height: 8),
                          Text(
                            '📍 Rota pelas ruas da sua localização atual',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Continuar navegando',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showFakeMapOfShopping(shopping);
                  },
                  child: Text(
                    'Ver layout do shopping',
                    style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao traçar rota: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isTracingRoute = false);
    }
  }

  void _showFakeMapOfShopping(ShoppingMall shopping) {
    setState(() {
      _showFakeMap = true;
      _selectedShopping = shopping;
      _showRouteToShopping = false;
      _selectedShoppingName = shopping.name;
    });
    
    _updateFakeMapMarkers(shopping);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mostrando layout interno de ${shopping.name}'),
        backgroundColor: AppColors.purple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _showRouteToShopping = false;
      _showFakeMap = false;
      _selectedShopping = null;
    });
    _updateMarkers();
  }

  void _returnToMainMap() {
    setState(() {
      _showFakeMap = false;
      _selectedShopping = null;
      _selectedShoppingName = 'Todos os Shoppings';
    });
    _updateMarkers();
  }

  void _showStoreDetails(Contact contact) {
    setState(() {
      _selectedContact = contact;
    });
    
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(contact.lat, contact.lng),
          18,
        ),
      );
    }
  }

  // ignore: unused_element
  double _calculateDistanceToShopping(ShoppingMall shopping) {
    if (_currentPosition == null) return 0.0;
    
    final userLat = _currentPosition!.latitude;
    final userLng = _currentPosition!.longitude;
    
    const R = 6371000.0;
    
    final lat1 = userLat * (pi / 180.0);
    final lat2 = shopping.lat * (pi / 180.0);
    final dLat = (shopping.lat - userLat) * (pi / 180.0);
    final dLng = (shopping.lng - userLng) * (pi / 180.0);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return R * c;
  }

  double _getHueFromColor(Color color) {
    if (color == AppColors.pink) return BitmapDescriptor.hueRose;
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    if (color == AppColors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == AppColors.purple) return BitmapDescriptor.hueViolet;
    if (color == AppColors.cyan) return BitmapDescriptor.hueCyan;
    return BitmapDescriptor.hueRed;
  }

  List<Contact> get _filteredContacts {
    return widget.contacts.where((c) {
      final shoppingName = _getShoppingNameForContact(c);
      return _selectedShoppingName == 'Todos os Shoppings' || shoppingName == _selectedShoppingName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F3FF),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.8),
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.purple.shade100,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black, size: 24),
                                onPressed: () => widget.onNavigate(Screen.home),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _showFakeMap && _selectedShopping != null
                                    ? 'Layout: ${_selectedShopping!.name}'
                                    : 'Mapa Interativo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader = const LinearGradient(
                                        colors: [AppColors.purple, AppColors.pink],
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 200, 40),
                                      ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_showFakeMap)
                          IconButton(
                            onPressed: _returnToMainMap,
                            icon: Icon(Icons.map, color: Colors.green, size: 24),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          ),
                      ],
                    ),
                  ),
                ),

                if (!_showFakeMap) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => setState(() => _showShoppingModal = true),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Rota para Shoppings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (!_showFakeMap) ...[
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.purple, AppColors.pink],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        'Selecionar Shopping:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: _availableShoppings.map((shopping) {
                                          final isSelected = _selectedShoppingName == shopping;
                                          final shoppingContacts = _countStoresForShopping(shopping);
                                          
                                          return Container(
                                            margin: const EdgeInsets.only(right: 6),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedShoppingName = shopping;
                                                    _updateMarkers();
                                                    _clearRoute();
                                                    _selectedContact = null;
                                                  });
                                                },
                                                borderRadius: BorderRadius.circular(12),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        shopping == 'Todos os Shoppings' ? 'Todos' : shopping,
                                                        style: TextStyle(
                                                          color: isSelected ? AppColors.purple : Colors.white,
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 13,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: isSelected ? AppColors.purple.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          '$shoppingContacts',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: isSelected ? AppColors.purple : Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          Container(
                            width: double.infinity,
                            height: 350,
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode 
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _initialPosition,
                                      zoom: 16,
                                    ),
                                    onMapCreated: (controller) {
                                      _mapController = controller;
                                      Future.delayed(const Duration(milliseconds: 500), () {
                                        _updateMarkers();
                                      });
                                    },
                                    markers: _markers,
                                    polylines: _polylines,
                                    myLocationEnabled: false,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    mapType: MapType.normal,
                                    buildingsEnabled: true,
                                    indoorViewEnabled: true,
                                    onTap: (_) {
                                      setState(() {
                                        _selectedContact = null;
                                      });
                                    },
                                  ),

                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Column(
                                      children: [
                                        _buildMapControlButton(
                                          Icons.zoom_in,
                                          Colors.white,
                                          AppColors.purple,
                                          () {
                                            if (_mapController != null) {
                                              _mapController!.animateCamera(
                                                CameraUpdate.zoomIn(),
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        _buildMapControlButton(
                                          Icons.zoom_out,
                                          Colors.white,
                                          AppColors.purple,
                                          () {
                                            if (_mapController != null) {
                                              _mapController!.animateCamera(
                                                CameraUpdate.zoomOut(),
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        _buildMapControlButton(
                                          Icons.my_location,
                                          Colors.white,
                                          const LinearGradient(
                                            colors: [AppColors.purple, AppColors.pink],
                                          ),
                                          () {
                                            if (_mapController != null && _currentPosition != null) {
                                              _mapController!.animateCamera(
                                                CameraUpdate.newLatLngZoom(
                                                  LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                                  18,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        if (_polylines.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          _buildMapControlButton(
                                            Icons.clear,
                                            Colors.white,
                                            Colors.red,
                                            _clearRoute,
                                          ),
                                        ],
                                        if (_showFakeMap) ...[
                                          const SizedBox(height: 8),
                                          _buildMapControlButton(
                                            Icons.home,
                                            Colors.white,
                                            Colors.blue,
                                            _returnToMainMap,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  Positioned.fill(
                                    child: _isLoadingLocation || _isTracingRoute
                                        ? Container(
                                            color: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const CircularProgressIndicator(
                                                    color: AppColors.purple,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    _isTracingRoute ? 'Tracando rota...' : 'Obtendo localização...',
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white : AppColors.purple,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFDF4FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDarkMode ? Colors.grey.shade800 : Colors.purple.shade100,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _usingGPS ? Icons.gps_fixed : Icons.location_on,
                                      color: _usingGPS ? Colors.green : Colors.blue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _usingGPS 
                                          ? 'Usando GPS - Posição em tempo real' 
                                          : 'Posição: IFPI Campus Teresina Central',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (_polylines.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _showRouteToShopping
                                            ? Colors.green.withOpacity(0.1)
                                            : AppColors.purple.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _showRouteToShopping ? Icons.directions : Icons.route,
                                              size: 12,
                                              color: _showRouteToShopping ? Colors.green : AppColors.purple,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _showRouteToShopping ? 'Rota ativa' : 'Rota pelas ruas',
                                              style: TextStyle(
                                                color: _showRouteToShopping ? Colors.green : AppColors.purple,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Clique em qualquer marcador para traçar uma rota pelas ruas',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    if (!_usingGPS)
                                      TextButton(
                                        onPressed: _getCurrentLocation,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Usar GPS',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    if (_usingGPS)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _usingGPS = false;
                                            _setInitialPosition();
                                            _updateMarkers();
                                            _clearRoute();
                                          });
                                          if (_mapController != null) {
                                            _mapController!.animateCamera(
                                              CameraUpdate.newLatLngZoom(
                                                _initialPosition,
                                                16,
                                              ),
                                            );
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Voltar ao IFPI',
                                          style: TextStyle(
                                            color: AppColors.purple,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildColorLegend(isDarkMode),
                          const SizedBox(height: 16),

                          if (_selectedContact != null) _buildSelectedStoreCard(isDarkMode),
                          if (_selectedContact == null && !_showFakeMap) _buildStoreList(isDarkMode),

                          if (_showFakeMap && _selectedShopping != null) _buildShoppingInfoCard(isDarkMode),

                          if (_showSettings) ...[
                            const SizedBox(height: 16),
                            _buildSettingsPanel(isDarkMode),
                          ],

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showShoppingModal) _buildShoppingModal(isDarkMode),
      ],
    );
  }

  Widget _buildColorLegend(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.purple.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legenda do Mapa',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem('Moda', AppColors.pink, isDarkMode),
              _buildLegendItem('Eletrônicos', Colors.blue, isDarkMode),
              _buildLegendItem('Alimentação', AppColors.orange, isDarkMode),
              _buildLegendItem('Esportes', Colors.green, isDarkMode),
              _buildLegendItem('Entretenimento', AppColors.purple, isDarkMode),
              _buildLegendItem('Serviços', AppColors.cyan, isDarkMode),
              _buildLegendItem('IFPI Campus', const Color(0xFF00BFFF), isDarkMode),
              _buildLegendItem('GPS Ativo', Colors.green, isDarkMode),
              _buildLegendItem('Rota pelas ruas', Colors.blue, isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingModal(bool isDarkMode) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.purple, AppColors.pink],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.store_mall_directory, color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Shoppings de Teresina',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _showShoppingModal = false),
                        icon: Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: _teresinaShoppings.map((shopping) {
                        final actualStoresCount = _countStoresForShopping(shopping.name);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode ? Colors.grey.shade800 : Colors.grey[200]!,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() => _showShoppingModal = false);
                                _traceRouteToShopping(shopping);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Colors.green, Colors.lightGreen],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(shopping.icon, color: Colors.white, size: 28),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                shopping.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode ? Colors.white : Colors.black,
                                                ),
                                              ),
                                              Text(
                                                shopping.address,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _buildShoppingInfoItem(Icons.storefront, '$actualStoresCount lojas', isDarkMode),
                                        const SizedBox(width: 12),
                                        _buildShoppingInfoItem(Icons.layers, '${shopping.floors} pisos', isDarkMode),
                                        const SizedBox(width: 12),
                                        _buildShoppingInfoItem(Icons.access_time, shopping.openingHours, isDarkMode),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: shopping.categories.map((category) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _categoryColors[category]?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _categoryColors[category]?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              color: _categoryColors[category] ?? Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      shopping.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Colors.green, Colors.lightGreen],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() => _showShoppingModal = false);
                                                _traceRouteToShopping(shopping);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                minimumSize: const Size(double.infinity, 44),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.directions, color: Colors.white, size: 18),
                                                  const SizedBox(width: 6),
                                                  const Text(
                                                    'Traçar Rota',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() => _showShoppingModal = false);
                                              _showFakeMapOfShopping(shopping);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              minimumSize: const Size(44, 44),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Icon(Icons.map, color: AppColors.purple, size: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildShoppingInfoItem(IconData icon, String text, bool isDarkMode) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingInfoCard(bool isDarkMode) {
    final shopping = _selectedShopping!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Layout Interno',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.purple, AppColors.pink],
                      ).createShader(
                        const Rect.fromLTWH(0, 0, 200, 40),
                      ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Visual',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            shopping.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este mapa mostra o layout interno aproximado do shopping com as principais áreas:',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: shopping.fakeMapLayout.map((store) {
              final color = _categoryColors[store.category] ?? AppColors.pink;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      store.name,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '⚠️ Observação:',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Este é um mapa ilustrativo para visualização das áreas principais do shopping. As posições são aproximadas.',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, AppColors.purple],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _traceRouteToShopping(shopping);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Traçar Rota',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: _returnToMainMap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(44, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Icon(Icons.home, color: AppColors.purple, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton(IconData icon, Color iconColor, dynamic background, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background is Gradient ? null : background,
        gradient: background is Gradient ? background : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedStoreCard(bool isDarkMode) {
    final contact = _selectedContact!;
    final color = _categoryColors[contact.category ?? 'Moda'] ?? AppColors.pink;
    final shoppingName = _getShoppingNameForContact(contact);
    final shopping = _getShoppingForContact(contact);
    
    final distance = _calculateDistanceToContact(contact);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Detalhes da Loja',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.purple, AppColors.pink],
                      ).createShader(
                        const Rect.fromLTWH(0, 0, 200, 40),
                      ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedContact = null),
                icon: Icon(Icons.close, color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600], size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      contact.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.store_mall_directory, color: AppColors.purple, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shoppingName,
                              style: TextStyle(
                                color: AppColors.purple,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (shopping != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                shopping.address,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailItem('Nome', contact.name, null, isDarkMode),
                const SizedBox(height: 10),
                _buildDetailItem('Categoria', contact.category ?? '', Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    contact.category ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ), isDarkMode),
                const SizedBox(height: 10),
                _buildDetailItem('Andar', contact.floor ?? '', null, isDarkMode),
                const SizedBox(height: 10),
                _buildDetailItem('Distância', '${distance.toStringAsFixed(2)} km', Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_walk, size: 12, color: AppColors.purple),
                      const SizedBox(width: 4),
                      Text(
                        '${distance.toStringAsFixed(2)} km',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ), isDarkMode),
                const SizedBox(height: 10),
                _buildDetailItem('Localização', contact.address, null, isDarkMode),
                const SizedBox(height: 10),
                _buildDetailItem('Contato', contact.phone, null, isDarkMode),
                const SizedBox(height: 16),
                
                // Indicador de rota pelas ruas (quando houver rota)
                if (_polylines.isNotEmpty && _selectedContact?.id == contact.id) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.route, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _usingGPS 
                                  ? 'Rota pelas ruas traçada'
                                  : 'Rota pelas ruas do IFPI',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Clique para ver detalhes da rota',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showRouteDetails(contact, distance * 1000),
                          icon: Icon(Icons.info_outline, color: Colors.blue, size: 16),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.purple, AppColors.pink],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _traceRouteToStore(contact),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isTracingRoute ? Icons.hourglass_bottom : Icons.route,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isTracingRoute ? 'Tracando...' : 'Traçar Rota',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_mapController != null) {
                            _mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(contact.lat, contact.lng),
                                18,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(44, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Icon(Icons.location_on, color: AppColors.purple, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreList(bool isDarkMode) {
    final List<Contact> filteredContacts = _filteredContacts;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedShoppingName == 'Todos os Shoppings' 
                  ? 'Todas as Lojas' 
                  : 'Lojas - $_selectedShoppingName',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [AppColors.purple, AppColors.pink],
                    ).createShader(
                      const Rect.fromLTWH(0, 0, 200, 40),
                    ),
              ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${filteredContacts.length}',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filteredContacts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.store,
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey[300],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma loja encontrada',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecione outro shopping ou adicione novas lojas',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: filteredContacts.map((contact) {
                final color = _categoryColors[contact.category ?? 'Moda'] ?? AppColors.pink;
                final distance = _calculateDistanceToContact(contact);
                final shoppingName = _getShoppingNameForContact(contact);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.grey[50],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showStoreDetails(contact),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  contact.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          contact.category ?? '',
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '• ${contact.floor}',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.directions_walk, size: 10, color: isDarkMode ? Colors.grey.shade500 : Colors.grey[500]),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${distance.toStringAsFixed(2)}km',
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shoppingName,
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.purple,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opções do Mapa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [AppColors.purple, AppColors.pink],
                ).createShader(
                  const Rect.fromLTWH(0, 0, 200, 40),
                ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildSettingItem(
                'Marcador Quadrado',
                'Usar ícone personalizado',
                'customMarker',
                isDarkMode,
              ),
              const SizedBox(height: 10),
              _buildSettingItem(
                'Mostrar Rotas',
                'Conectar lojas',
                'showRoutes',
                isDarkMode,
              ),
              const SizedBox(height: 10),
              _buildSettingItem(
                'Área de Cobertura',
                'Polígono delimitador',
                'showPolygons',
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Widget? child, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 3),
        if (child != null)
          child
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
      ],
    );
  }

  Widget _buildSettingItem(String title, String subtitle, String key, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.grey[50],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _mapSettings[key] ?? false,
            onChanged: (value) {
              setState(() {
                _mapSettings[key] = value ?? false;
              });
            },
            activeColor: AppColors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _updateMapBounds() {
    if (_mapController != null && _markers.isNotEmpty) {
      final bounds = _calculateBounds();
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }

  LatLngBounds _calculateBounds() {
    double? minLat, maxLat, minLng, maxLng;
    
    for (var marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;
      
      minLat = minLat == null ? lat : (lat < minLat ? lat : minLat);
      maxLat = maxLat == null ? lat : (lat > maxLat ? lat : maxLat);
      minLng = minLng == null ? lng : (lng < minLng ? lng : minLng);
      maxLng = maxLng == null ? lng : (lng > maxLng ? lng : maxLng);
    }
    
    return LatLngBounds(
      southwest: LatLng(minLat ?? 0, minLng ?? 0),
      northeast: LatLng(maxLat ?? 0, maxLng ?? 0),
    );
  }
}

class ShoppingMall {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final IconData icon;
  final int floors;
  final int storesCount;
  final String openingHours;
  final String phone;
  final String website;
  final String description;
  final String imageUrl;
  final List<String> categories;
  final List<FakeStore> fakeMapLayout;

  ShoppingMall({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.icon,
    required this.floors,
    required this.storesCount,
    required this.openingHours,
    required this.phone,
    required this.website,
    required this.description,
    required this.imageUrl,
    required this.categories,
    required this.fakeMapLayout,
  });
}

class FakeStore {
  final double lat;
  final double lng;
  final String name;
  final String category;

  FakeStore({
    required this.lat,
    required this.lng,
    required this.name,
    required this.category,
  });
}