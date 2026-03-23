import Razorpay from 'razorpay';
import dotenv from 'dotenv';

dotenv.config();

const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID || '';
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || '';

console.log('Testing Razorpay integration...');
console.log('Key ID:', RAZORPAY_KEY_ID ? 'Present' : 'Missing');
console.log('Key Secret:', RAZORPAY_KEY_SECRET ? 'Present' : 'Missing');

try {
  const razorpayInstance = new Razorpay({
    key_id: RAZORPAY_KEY_ID,
    key_secret: RAZORPAY_KEY_SECRET,
  });
  
  console.log('Razorpay instance created successfully');
  console.log('Instance type:', typeof razorpayInstance);
  console.log('Has orders method:', typeof razorpayInstance.orders);
  
  // Try to create a test order
  const options = {
    amount: 99900,
    currency: 'INR',
    receipt: `test_receipt_${Date.now()}`,
    notes: {
      test: 'true'
    }
  };
  
  console.log('\nCreating test order with options:', options);
  
  razorpayInstance.orders.create(options)
    .then((order: any) => {
      console.log('\n✓ Order created successfully!');
      console.log('Order ID:', order.id);
      console.log('Amount:', order.amount);
      console.log('Currency:', order.currency);
      console.log('Status:', order.status);
    })
    .catch((error: any) => {
      console.error('\n✗ Order creation failed:');
      console.error('Error:', error);
      console.error('Error message:', error.message);
      console.error('Error description:', error.description);
    });
    
} catch (error: any) {
  console.error('Failed to initialize Razorpay:', error);
  console.error('Error message:', error.message);
}
