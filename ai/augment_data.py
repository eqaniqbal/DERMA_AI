import os
import random
from tensorflow.keras.preprocessing.image import (
    ImageDataGenerator, img_to_array, array_to_img, load_img
)

SOURCE_DIR = './dataset'

TARGET_COUNTS = {
    'actinic_keratosis':    1500,
    'basal_cell_carcinoma': 1500,
    'benign_keratosis':     1500,
    'dermatofibroma':       1500,
    'melanocytic_nevi':     6705,  # keep all originals, no deletion
    'melanoma':             1500,
    'vascular_lesion':      1500,
}

aug = ImageDataGenerator(
    rotation_range=40,
    horizontal_flip=True,
    vertical_flip=True,
    zoom_range=0.3,
    brightness_range=[0.7, 1.3],
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    fill_mode='nearest'
)

print("Starting augmentation (no deletion, originals preserved)...")
print("="*55)

for cls, target in TARGET_COUNTS.items():
    cls_dir = os.path.join(SOURCE_DIR, cls)

    if not os.path.exists(cls_dir):
        print(f"WARNING: {cls_dir} not found, skipping.")
        continue

    all_images = [f for f in os.listdir(cls_dir)
                  if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
    current = len(all_images)

    print(f"\n{cls}: {current} images → target {target}")

    if current >= target:
        print(f"  Already at or above target ({current}), skipping.")
        continue

    needed = target - current
    print(f"  Generating {needed} augmented images...")

    count = 0
    while count < needed:
        img_name = random.choice(all_images)
        img_path = os.path.join(cls_dir, img_name)

        try:
            img = load_img(img_path)
            x = img_to_array(img)
            x = x.reshape((1,) + x.shape)

            for batch in aug.flow(x, batch_size=1):
                save_name = f'aug_{cls}_{count:04d}.jpg'
                save_path = os.path.join(cls_dir, save_name)
                array_to_img(batch[0]).save(save_path)
                count += 1
                break

        except Exception as e:
            print(f"  Skipping {img_name}: {e}")
            continue

        if count % 200 == 0 and count > 0:
            print(f"  Progress: {count}/{needed}")

    print(f"  Done. Generated {count} images.")

print("\n" + "="*55)
print("FINAL DATASET COUNTS:")
print("="*55)
total = 0
for cls in sorted(TARGET_COUNTS.keys()):
    cls_dir = os.path.join(SOURCE_DIR, cls)
    count = len([f for f in os.listdir(cls_dir)
                 if f.lower().endswith(('.jpg', '.jpeg', '.png'))])
    total += count
    orig = {
        'actinic_keratosis': 327,
        'basal_cell_carcinoma': 514,
        'benign_keratosis': 1099,
        'dermatofibroma': 115,
        'melanocytic_nevi': 6705,
        'melanoma': 1113,
        'vascular_lesion': 142,
    }
    aug_count = count - orig.get(cls, 0)
    print(f"  {cls}: {count} ({orig.get(cls,0)} original + {aug_count} augmented)")

print(f"\n  TOTAL: {total} images")
print("="*55)
print("\nDone! Dataset ready for Colab training.")