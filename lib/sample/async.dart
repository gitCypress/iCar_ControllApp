Future<String> fetchUserOrder() {
  // Imagine that this function is fetching user info from another service or database.
  return Future.delayed(const Duration(seconds: 2), () => 'Large Latte');
  // return Future.delayed(const Duration(seconds: 2), () => throw Exception('No more Large Latte.'));
}

Future<String> createOrderMessage() async {
  var order = await fetchUserOrder();
  return 'Your order is: $order';
}

Future<void> main() async {
  print('Fetching user order...');
  print(await createOrderMessage());
}