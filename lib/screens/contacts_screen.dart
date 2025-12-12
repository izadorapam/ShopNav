import 'package:flutter/material.dart';
import 'package:shopnav/models/contact.dart';
import 'package:shopnav/utils/colors.dart';
import 'package:shopnav/main.dart';
import 'package:provider/provider.dart';
import 'package:shopnav/providers/theme_provider.dart';

class ContactsScreen extends StatefulWidget {
  final List<Contact> contacts;
  final Function(Screen) onNavigate;
  final Function(Contact) onAddContact;
  final Function(String, Contact) onUpdateContact;
  final Function(String) onDeleteContact;

  const ContactsScreen({
    super.key,
    required this.contacts,
    required this.onNavigate,
    required this.onAddContact,
    required this.onUpdateContact,
    required this.onDeleteContact,
  });

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool _showForm = false;
  Contact? _editingContact;
  String _searchTerm = '';
  String _selectedCategory = 'Todas';
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();
  final _floorController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  final List<String> _categories = [
    'Todas',
    'Moda',
    'Eletrônicos',
    'Alimentação',
    'Esportes',
    'Entretenimento',
    'Serviços',
  ];

  final List<String> _floors = ['Piso 1', 'Piso 2', 'Piso 3'];

  final Map<String, List<Color>> _categoryColors = {
    'Moda': [AppColors.pink, AppColors.rose],
    'Eletrônicos': [Colors.blue, Colors.indigo],
    'Alimentação': [AppColors.orange, AppColors.amber],
    'Esportes': [Colors.green, Colors.green.shade700],
    'Entretenimento': [AppColors.purple, Colors.purple.shade700],
    'Serviços': [AppColors.cyan, Colors.teal],
  };

  @override
  void initState() {
    super.initState();
    _categoryController.text = 'Moda';
    _floorController.text = 'Piso 1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    _floorController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  void _handleEdit(Contact contact) {
    setState(() {
      _editingContact = contact;
      _nameController.text = contact.name;
      _emailController.text = contact.email;
      _phoneController.text = contact.phone;
      _addressController.text = contact.address;
      _categoryController.text = contact.category ?? 'Moda';
      _floorController.text = contact.floor ?? 'Piso 1';
      _latController.text = contact.lat.toString();
      _lngController.text = contact.lng.toString();
      _showForm = true;
    });
  }

  void _resetForm() {
    setState(() {
      _showForm = false;
      _editingContact = null;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      _categoryController.text = 'Moda';
      _floorController.text = 'Piso 1';
      _latController.clear();
      _lngController.clear();
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final contact = Contact(
        id: _editingContact?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        lat: double.parse(_latController.text),
        lng: double.parse(_lngController.text),
        category: _categoryController.text,
        floor: _floorController.text,
      );

      if (_editingContact != null) {
        widget.onUpdateContact(_editingContact!.id, contact);
      } else {
        widget.onAddContact(contact);
      }
      _resetForm();
    }
  }

  List<Contact> get _filteredContacts {
    return widget.contacts.where((contact) {
      final matchesSearch = contact.name.toLowerCase().contains(_searchTerm.toLowerCase());
      final matchesCategory = _selectedCategory == 'Todas' || contact.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDarkMode
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A1A2E),
                        Color(0xFF16213E),
                        Color(0xFF0F3460),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF3E8FF),
                        Color(0xFFFCE7F3),
                        Color(0xFFFFEDD5),
                      ],
                    ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // App Bar
                    _buildAppBar(isDarkMode),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Search and Filter
                          _buildSearchFilter(isDarkMode),
                          const SizedBox(height: 20),
                          
                          // Stats - TUDO EM COLUNA
                          Column(
                            children: [
                              _buildStatCard(
                                widget.contacts.length.toString(),
                                'Total de Lojas',
                                AppColors.purple,
                                isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                widget.contacts.where((c) => c.category == 'Moda').length.toString(),
                                'Moda',
                                AppColors.pink,
                                isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                widget.contacts.where((c) => c.category == 'Alimentação').length.toString(),
                                'Alimentação',
                                AppColors.orange,
                                isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                widget.contacts.where((c) => c.category == 'Eletrônicos').length.toString(),
                                'Eletrônicos',
                                Colors.blue,
                                isDarkMode,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Store Grid - EM COLUNA
                          _buildStoreList(isDarkMode),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Form Modal
        if (_showForm) _buildFormModal(isDarkMode),
      ],
    );
  }

Widget _buildAppBar(bool isDarkMode) {
  return Container(
    decoration: BoxDecoration(
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.8),
      border: Border(bottom: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey[200]!)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black, size: 24),
            onPressed: () => widget.onNavigate(Screen.home),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Icon(Icons.store, color: AppColors.purple, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Lojas do Shopping',
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSearchFilter(bool isDarkMode) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(Icons.search, color: isDarkMode ? Colors.grey.shade400 : Colors.grey[500]),
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchTerm = value),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar lojas...',
                    hintStyle: TextStyle(color: isDarkMode ? Colors.grey.shade500 : Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.purple, AppColors.pink],
                          )
                        : null,
                    color: isSelected ? null : (isDarkMode ? const Color(0xFF2D2D2D) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : (isDarkMode ? Colors.grey.shade700 : Colors.grey[300]!),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.purple.withOpacity(isDarkMode ? 0.4 : 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _selectedCategory = category),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isDarkMode ? Colors.grey.shade300 : Colors.grey[700]),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildStoreList(bool isDarkMode) {
  if (_filteredContacts.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  return Column(
    children: _filteredContacts.map((contact) {
      final colors = _categoryColors[contact.category ?? 'Moda'] ?? [AppColors.pink, AppColors.rose];
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Listra no topo
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: colors,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.first.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    contact.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // REMOVIDOS OS ÍCONES DE EDITAR E EXCLUIR
                              Container(width: 0), // Espaçador vazio para manter layout
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            contact.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    color: AppColors.purple,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    contact.category ?? '',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: AppColors.pink,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    contact.floor ?? '',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                contact.address,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey.shade500 : Colors.grey[500],
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey[200],
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                contact.phone,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                              InkWell(
                                onTap: () => widget.onNavigate(Screen.maps),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.map,
                                        color: AppColors.purple,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ver no mapa',
                                        style: TextStyle(
                                          color: AppColors.purple,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

  Widget _buildFormModal(bool isDarkMode) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _editingContact != null ? 'Editar Loja' : 'Nova Loja',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [AppColors.purple, AppColors.pink],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 200, 40),
                                ),
                            ),
                          ),
                          IconButton(
                            onPressed: _resetForm,
                            icon: Icon(Icons.close),
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                            iconSize: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Nome da Loja',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.grey.shade300 : null,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.purple, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite o nome da loja';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Categoria',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey.shade300 : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _categoryController.text,
                                  dropdownColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.purple, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                                    filled: true,
                                  ),
                                  items: _categories
                                      .where((c) => c != 'Todas')
                                      .map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _categoryController.text = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Andar',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey.shade300 : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _floorController.text,
                                  dropdownColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.purple, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                                    filled: true,
                                  ),
                                  items: _floors.map((floor) {
                                    return DropdownMenuItem(
                                      value: floor,
                                      child: Text(floor),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _floorController.text = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.grey.shade300 : null,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.purple, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                          filled: true,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite o email';
                          }
                          if (!value.contains('@')) {
                            return 'Por favor, digite um email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.grey.shade300 : null,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.purple, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                          filled: true,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite o telefone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Localização',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.grey.shade300 : null,
                          ),
                          hintText: 'Ex: Ala Norte - Loja 201',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.purple, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite a localização';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Coordenada X',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey.shade300 : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _latController,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.purple, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                                    filled: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite a coordenada';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Por favor, digite um número válido';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Coordenada Y',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey.shade300 : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _lngController,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.purple, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                                    filled: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite a coordenada';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Por favor, digite um número válido';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _resetForm,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
                                side: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.purple, AppColors.pink],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.purple.withOpacity(isDarkMode ? 0.4 : 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _editingContact != null ? 'Atualizar' : 'Cadastrar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
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
            ),
          ),
        ),
      ),
    );
  }
}