const mongoose = require('mongoose');

const scanSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      default: 'guest',
    },
    condition: {
      type: String,
      required: true,
    },
    conditionKey: String,
    confidence: Number,
    tip: String,
    allScores: Object,
    lowConfidence: Boolean,
    imageBase64: String,
  },
  { timestamps: true }
);

module.exports = mongoose.model('Scan', scanSchema);