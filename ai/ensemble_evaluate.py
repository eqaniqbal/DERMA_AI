import tensorflow as tf
import numpy as np
import json
import os
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications.efficientnet import preprocess_input as efficientnet_preprocess

DATASET_PATH = './dataset'
MOBILENET_PATH = './model/skin_model_finetuned.h5'
EFFICIENTNET_PATH = './model/phase3_best.keras'
CLASSES_PATH = './model/classes.json'

print("Loading models...")
mobilenet = tf.keras.models.load_model(MOBILENET_PATH)
print("  MobileNetV2 loaded (72.8%)")
efficientnet = tf.keras.models.load_model(EFFICIENTNET_PATH)
print("  EfficientNetB4 loaded (70%+)")

# Load class names
with open(CLASSES_PATH) as f:
    class_indices = json.load(f)
classes = {v: k for k, v in class_indices.items()}
print(f"  Classes: {list(classes.values())}")

# Data generators — separate preprocessing for each model
mobilenet_datagen = ImageDataGenerator(
    rescale=1./255,
    validation_split=0.2,
)
efficientnet_datagen = ImageDataGenerator(
    preprocessing_function=efficientnet_preprocess,
    validation_split=0.2,
)

print("\nLoading validation data...")
mobilenet_val = mobilenet_datagen.flow_from_directory(
    DATASET_PATH,
    target_size=(224, 224),
    batch_size=16,
    subset='validation',
    shuffle=False,
)
efficientnet_val = efficientnet_datagen.flow_from_directory(
    DATASET_PATH,
    target_size=(380, 380),
    batch_size=16,
    subset='validation',
    shuffle=False,
)

print(f"Validation samples: {mobilenet_val.samples}")
print("\nRunning predictions (this takes 20-40 minutes on CPU)...")
print("Getting MobileNetV2 predictions...")
mobilenet_preds = mobilenet.predict(mobilenet_val, verbose=1)

print("\nGetting EfficientNetB4 predictions...")
efficientnet_preds = efficientnet.predict(efficientnet_val, verbose=1)

# True labels
true_labels = mobilenet_val.classes

print("\n" + "="*55)
print("RESULTS")
print("="*55)

# Individual accuracies
mobilenet_acc = np.mean(np.argmax(mobilenet_preds, axis=1) == true_labels)
efficientnet_acc = np.mean(np.argmax(efficientnet_preds, axis=1) == true_labels)
print(f"MobileNetV2 alone:    {mobilenet_acc*100:.2f}%")
print(f"EfficientNetB4 alone: {efficientnet_acc*100:.2f}%")

# Ensemble — try different weights
print("\n--- Ensemble Results ---")
for w1, w2 in [(0.5, 0.5), (0.6, 0.4), (0.4, 0.6), (0.7, 0.3), (0.3, 0.7)]:
    ensemble_preds = (w1 * mobilenet_preds) + (w2 * efficientnet_preds)
    ensemble_acc = np.mean(np.argmax(ensemble_preds, axis=1) == true_labels)
    print(f"  MobileNet {w1:.0%} + EfficientNet {w2:.0%}: {ensemble_acc*100:.2f}%")

# Find best weights
best_acc = 0
best_w1, best_w2 = 0.5, 0.5
for w1 in np.arange(0.1, 1.0, 0.1):
    w2 = 1.0 - w1
    ensemble_preds = (w1 * mobilenet_preds) + (w2 * efficientnet_preds)
    acc = np.mean(np.argmax(ensemble_preds, axis=1) == true_labels)
    if acc > best_acc:
        best_acc = acc
        best_w1, best_w2 = w1, w2

print(f"\nBest ensemble: MobileNet {best_w1:.0%} + EfficientNet {best_w2:.0%}")
print(f"BEST ENSEMBLE ACCURACY: {best_acc*100:.2f}%")
print("="*55)

# Save best weights for use in app.py
result = {
    "mobilenet_weight": float(best_w1),
    "efficientnet_weight": float(best_w2),
    "mobilenet_accuracy": float(mobilenet_acc),
    "efficientnet_accuracy": float(efficientnet_acc),
    "ensemble_accuracy": float(best_acc),
}
with open('./model/ensemble_config.json', 'w') as f:
    json.dump(result, f, indent=2)

print("\nEnsemble config saved to model/ensemble_config.json")
print("Use these weights in your Flask app.py for best predictions!")