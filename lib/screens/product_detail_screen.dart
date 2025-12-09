import 'package:flutter/material.dart';
import '../api/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String barcode;

  const ProductDetailScreen({super.key, required this.barcode});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();

  Map<String, dynamic>? _product;
  bool _isLoading = true;
  bool _isFavorite = false; // Kalbin dolu mu boş mu olduğunu tutar
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  void _fetchProductDetails() async {
    // 1. Ürünü API'den çek
    final data = await _productService.getProduct(widget.barcode);

    if (mounted) {
      setState(() {
        if (data != null) {
          _product = data;
          // Ürün bulunduysa geçmişe kaydet
          _productService.addToHistory(data['id'], widget.barcode);
          // Favori mi diye kontrol et
          _checkIfFavorite(data['id']);
        } else {
          _errorMessage = "Ürün bulunamadı.";
        }
        _isLoading = false;
      });
    }
  }

  // Bu ürün zaten favorilerde mi diye bakar
  void _checkIfFavorite(int productId) async {
    final favorites = await _productService.getFavorites();
    // Listede bu ID var mı diye kontrol et
    bool exists = favorites.any((item) => item['ProductID'] == productId);

    if (mounted) {
      setState(() {
        _isFavorite = exists;
      });
    }
  }

  // Kalbe basınca çalışır
  void _toggleFavorite() async {
    if (_product == null) return;

    // Eski durumu sakla (Hata olursa geri almak için)
    bool oldState = _isFavorite;

    // Ekranda hemen değiştir (Hızlı hissettirsin)
    setState(() {
      _isFavorite = !oldState;
    });

    // API'ye gönder (Eğer şu an favoriyse siler, değilse ekler)
    bool success = await _productService.toggleFavorite(
      _product!['id'],
      oldState,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            oldState ? "Favorilerden çıkarıldı" : "Favorilere eklendi",
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // Hata olduysa eski haline döndür
      setState(() {
        _isFavorite = oldState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Ürün İnceleme"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // --- İŞTE KAYIP OLAN KALP İKONU BURADA ---
          if (_product != null) // Ürün yüklendiyse göster
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.grey,
                size: 30,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Text(_errorMessage!, style: const TextStyle(fontSize: 18)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- Ürün Resmi ve İsmi ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _product!['ImageUrl'] != null &&
                                _product!['ImageUrl'].toString().startsWith(
                                  'http',
                                )
                            ? Image.network(
                                _product!['ImageUrl'],
                                height: 150,
                                fit: BoxFit.contain,
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey,
                              ),

                        const SizedBox(height: 16),

                        Text(
                          _product!['productName'] ?? 'İsimsiz Ürün',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Bilgi Kartları ---
                  // null değerleri temizleyerek gösteriyoruz
                  _buildInfoCard(
                    "İçindekiler",
                    (_product!['Icindekiler'] ??
                            _product!['Description'] ??
                            'Bilgi yok')
                        .replaceAll('NULL', ''),
                  ),
                  _buildInfoCard(
                    "Alerjen Uyarısı",
                    (_product!['AlerjenUyarisi'] ?? 'Bilgi yok').replaceAll(
                      'NULL',
                      '',
                    ),
                  ),
                  _buildInfoCard(
                    "Enerji ve Besin Öğeleri",
                    (_product!['Nutrients'] ?? 'Bilgi yok').replaceAll(
                      'NULL',
                      '',
                    ),
                  ),
                  _buildInfoCard(
                    "Menşei",
                    (_product!['Origin'] ?? 'Bilgi yok').replaceAll('NULL', ''),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
