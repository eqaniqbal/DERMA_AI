import os
import shutil
import pandas as pd

# Paths - adjust if your extraction folder name differs
CSV_PATH = 'dataset_raw/HAM10000_metadata.csv'
IMG_DIRS = [
    'dataset_raw/HAM10000_images_part_1',
    'dataset_raw/HAM10000_images_part_2',
]
OUTPUT_DIR = 'dataset'

df = pd.read_csv(CSV_PATH)

# Class label mapping
class_names = {
    'akiec': 'actinic_keratosis',
    'bcc':   'basal_cell_carcinoma',
    'bkl':   'benign_keratosis',
    'df':    'dermatofibroma',
    'mel':   'melanoma',
    'nv':    'melanocytic_nevi',
    'vasc':  'vascular_lesion',
}

# Create output class folders
for cls in class_names.values():
    os.makedirs(os.path.join(OUTPUT_DIR, cls), exist_ok=True)

# Copy images into class folders
not_found = 0
for _, row in df.iterrows():
    img_name = row['image_id'] + '.jpg'
    label = class_names[row['dx']]
    dest = os.path.join(OUTPUT_DIR, label, img_name)

    copied = False
    for img_dir in IMG_DIRS:
        src = os.path.join(img_dir, img_name)
        if os.path.exists(src):
            shutil.copy(src, dest)
            copied = True
            break

    if not copied:
        not_found += 1

print(f"Done! Dataset organized into '{OUTPUT_DIR}/'")
print(f"Images not found: {not_found}")

# Print class counts
for cls in class_names.values():
    count = len(os.listdir(os.path.join(OUTPUT_DIR, cls)))
    print(f"  {cls}: {count} images")