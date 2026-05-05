from flask import Flask, request, jsonify
from tensorflow.keras.applications.efficientnet import preprocess_input
from PIL import Image
import tensorflow as tf
import numpy as np
import json
import io

app = Flask(__name__)

print("Loading model...")
model = tf.keras.models.load_model('./model/phase3_best.keras')
print("Model loaded!")

with open('./model/classes.json') as f:
    class_indices = json.load(f)
classes = {v: k for k, v in class_indices.items()}

display_names = {
    'actinic_keratosis':    'Actinic Keratosis',
    'basal_cell_carcinoma': 'Basal Cell Carcinoma',
    'benign_keratosis':     'Benign Keratosis',
    'dermatofibroma':       'Dermatofibroma',
    'melanocytic_nevi':     'Melanocytic Nevi (Mole)',
    'melanoma':             'Melanoma',
    'vascular_lesion':      'Vascular Lesion',
}

tips = {
    'actinic_keratosis':    'Avoid sun exposure. Use sunscreen SPF 50+. Consult a dermatologist soon.',
    'basal_cell_carcinoma': 'See a dermatologist immediately. Do not scratch or pick the area.',
    'benign_keratosis':     'Usually harmless. Monitor for changes. Keep skin moisturized.',
    'dermatofibroma':       'Generally harmless. See a doctor if it changes size or bleeds.',
    'melanocytic_nevi':     'Monitor for changes in size, color, or shape. Annual skin check recommended.',
    'melanoma':             'URGENT: See a dermatologist immediately. Early detection is critical.',
    'vascular_lesion':      'Consult a doctor. Avoid trauma to the area.',
}

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'model': 'EfficientNetB4'})

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    file = request.files['image']

    try:
        img = Image.open(io.BytesIO(file.read())).convert('RGB')
        img = img.resize((380, 380))  # must match training size
        img_array = np.array(img, dtype=np.float32)
        img_array = preprocess_input(img_array)
        img_array = np.expand_dims(img_array, axis=0)

        predictions = model.predict(img_array, verbose=0)[0]
        top_idx = int(np.argmax(predictions))
        confidence = float(predictions[top_idx]) * 100

        condition_key = classes[top_idx]
        condition_display = display_names.get(condition_key, condition_key)
        tip = tips.get(condition_key, 'Consult a dermatologist.')

        all_scores = {
            display_names.get(classes[i], classes[i]): round(float(p) * 100, 2)
            for i, p in enumerate(predictions)
        }

        return jsonify({
            'success': True,
            'condition': condition_display,
            'condition_key': condition_key,
            'confidence': round(confidence, 2),
            'tip': tip,
            'all_scores': all_scores,
            'low_confidence': confidence < 50,
        })

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("Starting server on port 5001...")
    app.run(host='0.0.0.0', port=5001, debug=False)