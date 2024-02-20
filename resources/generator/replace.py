from PIL import Image
import numpy as np

def replace_color(image_path, target_color, replacement_color, output_path):
    # 打开图像
    img = Image.open(image_path)

    # 将图像转换为NumPy数组以便进行修改
    img_array = np.array(img)

    # 获取图像尺寸
    height, width, _ = img_array.shape

    # 遍历所有像素
    for y in range(height):
        for x in range(width):
            # 获取当前像素的颜色值
            current_color = img_array[y, x]

            # 检查是否与目标颜色匹配
            if np.array_equal(current_color[:3], target_color):
                # 替换为新颜色
                img_array[y, x] = replacement_color
    
    for y in range(height):
        for x in range(width):
            # 获取当前像素的颜色值
            current_color = img_array[y, x]

            # 半透明像素转换为不透明像素，颜色值不变
            if current_color[3] != 255:
                img_array[y, x][0] = img_array[y, x][0] * (current_color[3] / 255)
                img_array[y, x][1] = img_array[y, x][1] * (current_color[3] / 255)
                img_array[y, x][2] = img_array[y, x][2] * (current_color[3] / 255)
                img_array[y, x][3] = 255

    # 从NumPy数组创建图像对象
    modified_img = Image.fromarray(img_array)

    # 保存修改后的图像
    modified_img.save(output_path)

# 用法示例
image_path = 'stage04b.png'
output_path = 'output.png'
target_color = [0, 0, 0, 255]  # 目标颜色 (黑色)
replacement_color = [1, 1, 1, 255]  # 替换为的新颜色 (白色)

replace_color(image_path, target_color, replacement_color, output_path)
