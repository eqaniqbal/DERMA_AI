const dns = require('dns');
dns.setDefaultResultOrder('ipv4first');

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// Routes
const chatbotRoutes = require('./src/routes/chatbot');
app.use('/api/chatbot', chatbotRoutes);

const scanRoutes = require('./src/routes/scan');
app.use('/api/scan', scanRoutes);

// Test route
app.get('/', (req, res) => {
  res.json({ message: 'Derma AI Backend is running!' });
});

// Discovery endpoint
app.get('/discover', (req, res) => {
  res.json({ 
    service: 'derma-ai-backend',
    version: '1.0.0',
    status: 'running'
  });
});

// Connect to MongoDB
mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.log('MongoDB error:', err));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});