const express = require('express');
const router = express.Router();
const multer = require('multer');
const axios = require('axios');
const FormData = require('form-data');
const Scan = require('../models/Scan');

const upload = multer({ storage: multer.memoryStorage() });

// POST /api/scan/analyze
router.post('/analyze', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image uploaded' });
    }

    // Forward to Flask AI server
    const formData = new FormData();
    formData.append('image', req.file.buffer, {
      filename: req.file.originalname,
      contentType: req.file.mimetype,
    });

    const aiResponse = await axios.post(
      'http://localhost:5001/predict',
      formData,
      { headers: formData.getHeaders() }
    );

    const {
      condition,
      condition_key,
      confidence,
      tip,
      all_scores,
      low_confidence,
    } = aiResponse.data;

    // Save to MongoDB
    const scan = new Scan({
      userId: req.body.userId || 'guest',
      condition,
      conditionKey: condition_key,
      confidence,
      tip,
      allScores: all_scores,
      lowConfidence: low_confidence,
      imageBase64: req.file.buffer.toString('base64'),
    });
    await scan.save();

    res.json({
      success: true,
      scanId: scan._id,
      condition,
      conditionKey: condition_key,
      confidence,
      tip,
      allScores: all_scores,
      lowConfidence: low_confidence,
    });

  } catch (error) {
    console.error('Scan error:', error.message);
    res.status(500).json({
      error: 'Analysis failed',
      detail: error.message,
    });
  }
});

// GET /api/scan/history/:userId
router.get('/history/:userId', async (req, res) => {
  try {
    const scans = await Scan.find({ userId: req.params.userId })
      .sort({ createdAt: -1 })
      .limit(20)
      .select('-imageBase64');
    res.json({ scans });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch history' });
  }
});

// GET /api/scan/:id
router.get('/:id', async (req, res) => {
  try {
    const scan = await Scan.findById(req.params.id);
    if (!scan) return res.status(404).json({ error: 'Scan not found' });
    res.json({ scan });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch scan' });
  }
});

module.exports = router;