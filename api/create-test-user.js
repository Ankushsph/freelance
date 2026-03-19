import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';

dotenv.config();

// User Schema (simplified)
const UserSchema = new mongoose.Schema({
  name: String,
  email: String,
  password: String,
}, { timestamps: true });

const User = mongoose.model('User', UserSchema);

async function createTestUser() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    // Check if test user already exists
    const existingUser = await User.findOne({ email: 'test@example.com' });
    if (existingUser) {
      console.log('✅ Test user already exists!');
      console.log('Email: test@example.com');
      console.log('Password: test123');
      process.exit(0);
    }

    // Create test user
    const hashedPassword = await bcrypt.hash('test123', 10);
    const testUser = await User.create({
      name: 'Test User',
      email: 'test@example.com',
      password: hashedPassword,
    });

    console.log('✅ Test user created successfully!');
    console.log('Email: test@example.com');
    console.log('Password: test123');
    console.log('User ID:', testUser._id);

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
}

createTestUser();