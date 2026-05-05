# save as convert_model.py in ai/ folder
import tensorflow as tf

print("Loading model...")
model = tf.keras.models.load_model('./model/phase3_best.keras')

print("Converting to TFLite...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]  # quantization = 4x faster
tflite_model = converter.convert()

with open('./model/skin_model.tflite', 'wb') as f:
    f.write(tflite_model)

print(f"Done! Size: {len(tflite_model)/1024/1024:.1f} MB")