import 'package:TrueTrack/models/product.dart';

final List<Product> mockAmazonProducts = [
  Product(
    name: 'iPhone 15 Pro Max 256GB',
    imageUrl:
        'https://via.placeholder.com/300x300/E91E63/FFFFFF?text=iPhone+15',
    price: '159999',
    source: 'Amazon',
    productId: 'B0CHX2Y5RK',
    isDeal: false,
  ),
  Product(
    name: 'Samsung Galaxy S24 Ultra 5G',
    imageUrl:
        'https://via.placeholder.com/300x300/3F51B5/FFFFFF?text=S24+Ultra',
    price: '134999',
    source: 'Amazon',
    productId: 'B0BRS9M2CX',
    isDeal: true,
  ),
  Product(
    name: 'MacBook Air M3 15-inch',
    imageUrl:
        'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=MacBook+Air',
    price: '149900',
    source: 'Amazon',
    productId: 'B0CX23V2ZK',
    isDeal: false,
  ),
  Product(
    name: 'OnePlus 12 5G',
    imageUrl:
        'https://via.placeholder.com/300x300/FF9800/FFFFFF?text=OnePlus+12',
    price: '79999',
    source: 'Amazon',
    productId: 'B0CQ4H3Y7F',
    isDeal: true,
  ),
  Product(
    name: 'Sony WH-1000XM5 Headphones',
    imageUrl: 'https://via.placeholder.com/300x300/9C27B0/FFFFFF?text=XM5',
    price: '29990',
    source: 'Amazon',
    productId: 'B09XSX1J2L',
    isDeal: false,
  ),
  Product(
    name: 'Apple Watch Ultra 2',
    imageUrl:
        'https://via.placeholder.com/300x300/607D8B/FFFFFF?text=Watch+Ultra',
    price: '89900',
    source: 'Amazon',
    productId: 'B0CHX9Q7YK',
    isDeal: true,
  ),
  Product(
    name: 'iPad Pro M4 11-inch',
    imageUrl: 'https://via.placeholder.com/300x300/00BCD4/FFFFFF?text=iPad+Pro',
    price: '99900',
    source: 'Amazon',
    productId: 'B0D3J5M7K9',
    isDeal: false,
  ),
  Product(
    name: 'Dell XPS 16 Laptop',
    imageUrl: 'https://via.placeholder.com/300x300/795548/FFFFFF?text=Dell+XPS',
    price: '189990',
    source: 'Amazon',
    productId: 'B0CQ8J2R5X',
    isDeal: true,
  ),
];

final List<Product> mockFlipkartProducts = [
  Product(
    name: 'Google Pixel 8 Pro',
    imageUrl:
        'https://via.placeholder.com/300x300/FF5722/FFFFFF?text=Pixel+8+Pro',
    price: '99999',
    source: 'Flipkart',
    productId: 'PIX8PRO123',
    isDeal: false,
  ),
  Product(
    name: 'boAt Airdopes 141 Pro',
    imageUrl: 'https://via.placeholder.com/300x300/009688/FFFFFF?text=boAt',
    price: '1999',
    source: 'Flipkart',
    productId: 'BOAT141PR',
    isDeal: true,
  ),
  Product(
    name: 'ASUS ROG Phone 8',
    imageUrl:
        'https://via.placeholder.com/300x300/673AB7/FFFFFF?text=ROG+Phone',
    price: '74999',
    source: 'Flipkart',
    productId: 'ASUSROG8P',
    isDeal: false,
  ),
  Product(
    name: 'Canon EOS R50 Mirrorless',
    imageUrl:
        'https://via.placeholder.com/300x300/795548/FFFFFF?text=Canon+R50',
    price: '77990',
    source: 'Flipkart',
    productId: 'CANR50BODY',
    isDeal: true,
  ),
  Product(
    name: 'Xiaomi Robot Vacuum X20',
    imageUrl:
        'https://via.placeholder.com/300x300/2196F3/FFFFFF?text=Xiaomi+Vacuum',
    price: '32999',
    source: 'Flipkart',
    productId: 'XIAOVACX20',
    isDeal: false,
  ),
  Product(
    name: 'Logitech MX Master 3S',
    imageUrl:
        'https://via.placeholder.com/300x300/FFC107/000000?text=MX+Master',
    price: '7495',
    source: 'Flipkart',
    productId: 'LOGIMM3S',
    isDeal: true,
  ),
  Product(
    name: 'Samsung Galaxy Tab S9 FE',
    imageUrl:
        'https://via.placeholder.com/300x300/E91E63/FFFFFF?text=Tab+S9+FE',
    price: '39999',
    source: 'Flipkart',
    productId: 'SMTAB9FE',
    isDeal: false,
  ),
  Product(
    name: 'HP Pavilion 15 Laptop',
    imageUrl:
        'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=HP+Pavilion',
    price: '64990',
    source: 'Flipkart',
    productId: 'HPPAV15R5',
    isDeal: true,
  ),
];

final List<Map<String, dynamic>> mockDeals = [
  {
    'deal_title': 'Samsung Galaxy S24 Ultra - 50% Off',
    'deal_photo': 'https://via.placeholder.com/200x200/3F51B5/FFFFFF?text=S24',
    'deal_price': {'amount': '67499'},
    'list_price': {'amount': '134999'},
    'deal_badge': '50% OFF',
    'product_asin': 'B0BRS9M2CX',
  },
  {
    'deal_title': 'OnePlus 12 - 40% Off Exchange Bonus',
    'deal_photo':
        'https://via.placeholder.com/200x200/FF9800/FFFFFF?text=OnePlus',
    'deal_price': {'amount': '47999'},
    'list_price': {'amount': '79999'},
    'deal_badge': '40% OFF',
    'product_asin': 'B0CQ4H3Y7F',
  },
  {
    'deal_title': 'Apple Watch Ultra 2 - 25% Off',
    'deal_photo':
        'https://via.placeholder.com/200x200/607D8B/FFFFFF?text=Watch',
    'deal_price': {'amount': '67425'},
    'list_price': {'amount': '89900'},
    'deal_badge': '25% OFF',
    'product_asin': 'B0CHX9Q7YK',
  },
  {
    'deal_title': 'Dell XPS 16 - 30% Off',
    'deal_photo': 'https://via.placeholder.com/200x200/795548/FFFFFF?text=XPS',
    'deal_price': {'amount': '132993'},
    'list_price': {'amount': '189990'},
    'deal_badge': '30% OFF',
    'product_asin': 'B0CQ8J2R5X',
  },
  {
    'deal_title': 'boAt Airdopes - 60% Off',
    'deal_photo': 'https://via.placeholder.com/200x200/009688/FFFFFF?text=boAt',
    'deal_price': {'amount': '799'},
    'list_price': {'amount': '1999'},
    'deal_badge': '60% OFF',
    'product_asin': 'BOAT141PR',
  },
  {
    'deal_title': 'Canon EOS R50 - 35% Off',
    'deal_photo':
        'https://via.placeholder.com/200x200/795548/FFFFFF?text=Canon',
    'deal_price': {'amount': '50644'},
    'list_price': {'amount': '77990'},
    'deal_badge': '35% OFF',
    'product_asin': 'CANR50BODY',
  },
];

final Map<String, dynamic> mockAmazonProductDetails = {
  'product_information': {
    'Brand': 'Apple',
    'Model Name': 'iPhone 15 Pro Max',
    'Color': 'Natural Titanium',
    'Storage': '256GB',
    'Display': '6.7-inch Super Retina XDR OLED',
    'Processor': 'A17 Pro Chip',
    'RAM': '8GB',
    'Camera': '48MP Main + 12MP Ultra Wide + 12MP Telephoto',
    'Battery': '4422 mAh',
    'Operating System': 'iOS 17',
  },
  'product_url': 'https://www.apple.com/iphone-15-pro/',
  'product_photos': [
    'https://via.placeholder.com/600x600/E91E63/FFFFFF?text=iPhone+15'
  ],
  'product_price': '159999',
  'product_original_price': '159999',
  'product_star_rating': '4.7',
  'product_num_ratings': 12543,
  'customers_say':
      'Customers love the battery life and camera quality. The A17 Pro chip handles gaming effortlessly. Some users find the titanium frame prone to scratches.',
};

final Map<String, dynamic> mockFlipkartProductDetails = {
  'url': 'https://store.google.com/product/pixel_8_pro',
  'images': ['https://via.placeholder.com/600x600/FF5722/FFFFFF?text=Pixel+8'],
  'mrp': '99999',
  'price': '89999',
  'rating': {
    'overall': {'average': 4.6, 'count': 8721},
  },
  'specifications': {
    'General': {
      'Brand': 'Google',
      'Model': 'Pixel 8 Pro',
      'Color': 'Obsidian',
      'RAM': '12GB',
      'Storage': '128GB',
    },
    'Display': {
      'Size': '6.7 inches',
      'Type': 'LTPO OLED',
      'Resolution': '1344 x 2992',
    },
    'Camera': {
      'Rear': '50MP + 48MP + 48MP',
      'Front': '10.5MP',
    },
  },
  'reviews': [
    {
      'title': 'Best Android phone',
      'review': 'Amazing camera and smooth performance. Battery lasts all day.',
      'reviewer': 'Rahul S.',
      'location': 'Mumbai',
      'date': '2024-12-15'
    },
    {
      'title': 'Great value',
      'review': 'The AI features are incredible. Photo editing is magical.',
      'reviewer': 'Priya M.',
      'location': 'Delhi',
      'date': '2024-11-20'
    },
    {
      'title': 'Excellent display',
      'review':
          'The screen is bright and colors are accurate. Tensor G3 is fast.',
      'reviewer': 'Amit K.',
      'location': 'Bangalore',
      'date': '2024-10-05'
    },
  ],
};

const String mockReviewSummary =
    'Customers consistently praise the battery life and camera performance, noting all-day battery life and stunning low-light photography. The processor delivers buttery-smooth performance for gaming and multitasking. Some users mention the premium build feels great but is slightly heavier than previous models. Alternatives to consider: Samsung Galaxy S24 Ultra for the S Pen and superior zoom capabilities; OnePlus 12 for faster charging and better value; Pixel 8 Pro for the best software experience and AI features.';

const String mockSpecSummary =
    'Key features include the latest A17 Pro chip for exceptional performance, a 48MP pro-level camera system with 5x optical zoom, and a stunning Super Retina XDR OLED display. The titanium build is both durable and lightweight. Ideal for content creators and power users who need top-tier performance. Potential drawbacks include the premium price point and lack of included charger.';

final List<Map<String, dynamic>> mockPriceEntries = [
  {'price': '164999', 'id': '01-06-2025'},
  {'price': '162999', 'id': '02-06-2025'},
  {'price': '161500', 'id': '03-06-2025'},
  {'price': '159999', 'id': '04-06-2025'},
  {'price': '158000', 'id': '05-06-2025'},
  {'price': '157500', 'id': '06-06-2025'},
  {'price': '159000', 'id': '07-06-2025'},
  {'price': '160500', 'id': '08-06-2025'},
  {'price': '158500', 'id': '09-06-2025'},
  {'price': '157000', 'id': '10-06-2025'},
  {'price': '155000', 'id': '11-06-2025'},
  {'price': '156500', 'id': '12-06-2025'},
  {'price': '154999', 'id': '13-06-2025'},
  {'price': '153500', 'id': '14-06-2025'},
  {'price': '155500', 'id': '15-06-2025'},
  {'price': '157000', 'id': '16-06-2025'},
  {'price': '156000', 'id': '17-06-2025'},
  {'price': '154000', 'id': '18-06-2025'},
  {'price': '153000', 'id': '19-06-2025'},
  {'price': '152500', 'id': '20-06-2025'},
];

final List<Map<String, dynamic>> mockPredictedPrices = [
  {'date': '21-06-2025', 'price': '152000'},
  {'date': '22-06-2025', 'price': '151500'},
  {'date': '23-06-2025', 'price': '151000'},
  {'date': '24-06-2025', 'price': '150500'},
  {'date': '25-06-2025', 'price': '150000'},
  {'date': '26-06-2025', 'price': '149500'},
  {'date': '27-06-2025', 'price': '149000'},
];

const String mockBuyAdvice =
    'Current price is 7% below the 30-day average of ₹1,64,500. The price has been trending downward with consistent drops over the past week. Based on historical patterns, the price may decrease further in the next 5-7 days. Consider waiting if you are not in a hurry. However, if you need the product immediately, the current price is a good deal compared to the MRP.';
