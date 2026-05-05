import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras import layers, models
from sklearn.utils.class_weight import compute_class_weight
import numpy as np
import json
import os

IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 15
DATASET_PATH = './dataset'

print("Setting up data generators...")

datagen = ImageDataGenerator(
    rescale=1./255,
    validation_split=0.2,
    rotation_range=20,
    horizontal_flip=True,
    zoom_range=0.2,
    width_shift_range=0.1,
    height_shift_range=0.1,
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

print(f"\nClasses found: {train_data.class_indices}")
print(f"Training samples: {train_data.samples}")
print(f"Validation samples: {val_data.samples}")

# Handle class imbalance (melanocytic_nevi has 6705 vs dermatofibroma 115)
print("\nComputing class weights to handle imbalance...")
class_weights_array = compute_class_weight(
    class_weight='balanced',
    classes=np.unique(train_data.classes),
    y=train_data.classes
)
class_weights = dict(enumerate(class_weights_array))
print(f"Class weights: {class_weights}")

# Build model using MobileNetV2 (fast + accurate, good for mobile)
print("\nBuilding model...")
base_model = MobileNetV2(
    input_shape=(IMG_SIZE, IMG_SIZE, 3),
    include_top=False,
    weights='imagenet'
)
base_model.trainable = False  # freeze base, only train top layers first

model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dense(256, activation='relu'),
    layers.Dropout(0.4),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.3),
    layers.Dense(train_data.num_classes, activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

model.summary()

# Train
print("\nStarting training... (this will take 1-3 hours on CPU)")
os.makedirs('./model', exist_ok=True)

callbacks = [
    tf.keras.callbacks.ModelCheckpoint(
        './model/skin_model_best.h5',
        save_best_only=True,
        monitor='val_accuracy',
        verbose=1,
    ),
    tf.keras.callbacks.EarlyStopping(
        monitor='val_accuracy',
        patience=4,
        restore_best_weights=True,
        verbose=1,
    ),
    tf.keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.5,
        patience=2,
        verbose=1,
    ),
]

history = model.fit(
    train_data,
    validation_data=val_data,
    epochs=EPOCHS,
    class_weight=class_weights,
    callbacks=callbacks,
)

# Save final model and class names
model.save('./model/skin_model.h5')

# Save class index map (index -> class name)
class_indices = train_data.class_indices
with open('./model/classes.json', 'w') as f:
    json.dump(class_indices, f, indent=2)

print("\n✅ Training complete!")
print(f"Final val accuracy: {max(history.history['val_accuracy']):.4f}")
print("Model saved to: ./model/skin_model.h5")
print("Classes saved to: ./model/classes.json")