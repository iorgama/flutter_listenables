import 'package:flutter/material.dart';
import 'package:flutter_listenables/data/product.dart';

final controller = WishlistController();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Listenables',
      home: ProductPage(title: 'Carrinho de Compras com Listenables'),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.title});

  final String title;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _products = List<Product>.generate(20, (i) {
    return Product(
      uid: i.toString(),
      name: 'Produto ${i + 1}',
      image: 'https://picsum.photos/200/100',
      price: ((i + 1) * 1.9).truncateToDouble(),
    );
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.shopping_cart)),
              Tab(icon: Icon(Icons.favorite))
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ProductView(products: _products),
            const WishlistView(),
          ],
        ),
      ),
    );
  }
}

class WishlistController extends ChangeNotifier {
  List<Product> _desiredProducts = [];

  List<Product> get products => [..._desiredProducts];

  double get total =>
      _desiredProducts.map((p) => p.price).reduce((a, b) => a + b);

  void likeProduct(Product product) {
    _desiredProducts.add(product);
    notifyListeners();
  }

  void unlikeProduct(Product product) {
    _desiredProducts =
        _desiredProducts.where((p) => p.uid != product.uid).toList();
    notifyListeners();
  }

  bool hasProduct(Product product) {
    return _desiredProducts.indexWhere((p) => p.uid == product.uid) > -1;
  }
}

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lista de Favoritos',
            ),
            const SizedBox(height: 8.0),
            Text('Total: ${controller.total} '),
            const SizedBox(height: 16.0),
            ListView.builder(
              itemCount: controller.products.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final product = controller.products[index];
                return ListTile(
                  leading: CircleAvatar(
                      radius: (52),
                      backgroundColor: Colors.red,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(product.image,
                              fit: BoxFit.contain))),
                  title: Text(product.name),
                  subtitle: Text(product.price.toString()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class ProductView extends StatelessWidget {
  const ProductView({
    Key? key,
    required this.products,
  }) : super(key: key);
  final List<Product> products;

  void _toogleFavorite(Product product) {
    if (controller.hasProduct(product)) {
      controller.unlikeProduct(product);
    } else {
      controller.likeProduct(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Image.network(
                    product.image,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name),
                            const SizedBox(height: 4),
                            Text('R\$ ${product.price}'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: controller.hasProduct(product)
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                              )
                            : const Icon(Icons.favorite_border_outlined),
                        onPressed: () => _toogleFavorite(product),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
