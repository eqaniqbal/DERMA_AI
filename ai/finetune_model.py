import tensorflow as tf
import numpy as np
import json
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.utils.class_weight import compute_class_weight
import os

IMG_SIZE = 224
BATCH_SIZE = 16
DATASET_PATH = './dataset'

print("Loading best model from Phase 1...")
model = tf.keras.models.load_model('./model/skin_model.h5')

# Get the MobileNetV2 base layer
base_model = model.layers[0]

# Unfreeze top 40 layers of MobileNetV2
base_model.trainable = True
for layer in base_model.layers[:-40]:
    layer.trainable = False

frozen = sum(1 for l in base_model.layers if not l.trainable)
unfrozen = sum(1 for l in base_model.layers if l.trainable)
print(f"Frozen layers: {frozen} | Unfrozen layers: {unfrozen}")

# Recompile with very low learning rate (critical for fine-tuning)
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=2e-5),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# Same data generators
datagen = ImageDataGenerator(
    rescale=1./255,
    validation_split=0.2,
    rotation_range=40,
    horizontal_flip=True,
    vertical_flip=True,
    zoom_range=0.3,
    width_shift_range=0.2,
    height_shift_range=0.2,
    brightness_range=[0.75, 1.25],
    shear_range=0.2,
    fill_mode='nearest'
)

train_data = datagen.flow_from_directory(
    DATASET_PATH,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    subset='training',
    shuffle=True,
)
val_data = datagen.flow_from_directory(
    DATASET_PATH,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    subset='validation',
    shuffle=False,
)

# Class weights
class_weights_array = compute_class_weight(
    class_weight='balanced',
    classes=np.unique(train_data.classes),
    y=train_data.classes
)
class_weights = dict(enumerate(class_weights_array))

os.makedirs('./model', exist_ok=True)

print("\n=== PHASE 2: Fine-tuning unfrozen layers ===")
print("This will take 3-5 hours. Best model saved after every improvement.")
print("You can safely leave this running overnight.\n")

history = model.fit(
    train_data,
    validation_data=val_data,
    epochs=20,
    class_weight=class_weights,
    callbacks=[
        tf.keras.callbacks.ModelCheckpoint(
            './model/skin_model_finetuned.h5',
            save_best_only=True,
            monitor='val_accuracy',
            verbose=1,
        ),
        tf.keras.callbacks.EarlyStopping(
            monitor='val_accuracy',
            patience=6,
            restore_best_weights=True,
            verbose=1,
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.3,
            patience=3,
            min_lr=1e-7,
            verbose=1,
        ),
    ]
)

# Save as the main model
model.save('./model/skin_model.h5')

best = max(history.history['val_accuracy'])
print(f"\n✅ Fine-tuning complete!")
print(f"Best val accuracy: {best:.4f}  ({best*100:.1f}%)")
print("Model saved to: ./model/skin_model.h5")
print("Best checkpoint: ./model/skin_model_finetuned.h5")