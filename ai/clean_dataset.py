import os

dataset_dir = './dataset'
total_removed = 0

for cls in os.listdir(dataset_dir):
    cls_path = os.path.join(dataset_dir, cls)
    if not os.path.isdir(cls_path):
        continue
    
    removed = 0
    for fname in os.listdir(cls_path):
        if fname.startswith('aug_'):
            os.remove(os.path.join(cls_path, fname))
            removed += 1
    
    total_removed += removed
    remaining = len(os.listdir(cls_path))
    print(f'{cls}: removed {removed} augmented → {remaining} originals remain')

print(f'\nTotal removed: {total_removed}')
print('Done! Only original images remain.')