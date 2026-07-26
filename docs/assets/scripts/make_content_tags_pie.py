import math
import os

from PIL import Image, ImageDraw, ImageFont


DATA = [
    ("物品记录", 72, "物品管理"),
    ("整理收纳", 64, "物品管理"),
    ("空间管理", 55, "空间管理"),
    ("特定事件", 52, "事件管理"),
    ("找物品", 43, "物品管理"),
    ("谷子/收藏品", 41, "物品管理"),
    ("j人", 36, "智能管理"),
    ("快速录入", 32, "智能管理"),
    ("区域划分", 31, "空间管理"),
    ("重复购买", 26, "物品管理"),
    ("记录过期", 18, "物品管理"),
    ("AI辅助", 15, "智能管理"),
]

COLORS = {
    "物品管理": "#F6B26B",
    "空间管理": "#9DB7E8",
    "智能管理": "#B9A0EA",
    "事件管理": "#9ED49A",
}


def load_font(size):
    font_paths = [
        r"C:\Windows\Fonts\msyh.ttc",
        r"C:\Windows\Fonts\simhei.ttf",
        r"C:\Windows\Fonts\simsun.ttc",
    ]
    for path in font_paths:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def hex_to_rgb(value):
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def draw_centered_text(draw, xy, text, font, fill):
    bbox = draw.textbbox((0, 0), text, font=font)
    x = xy[0] - (bbox[2] - bbox[0]) / 2
    y = xy[1] - (bbox[3] - bbox[1]) / 2
    draw.text((x, y), text, font=font, fill=fill)


def main():
    width, height = 1800, 1200
    image = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(image)

    title_font = load_font(48)
    label_font = load_font(27)
    small_font = load_font(23)
    legend_font = load_font(26)

    title = "内容标签出现次数占比"
    draw_centered_text(draw, (width / 2, 70), title, title_font, "#20242A")

    total = sum(value for _, value, _ in DATA)
    cx, cy = 675, 630
    radius = 390
    box = (cx - radius, cy - radius, cx + radius, cy + radius)

    start = -90
    for label, value, category in DATA:
        angle = value / total * 360
        fill = hex_to_rgb(COLORS[category])
        draw.pieslice(box, start=start, end=start + angle, fill=fill, outline="white", width=2)

        mid = math.radians(start + angle / 2)
        pct = value / total * 100

        pct_x = cx + math.cos(mid) * radius * 0.66
        pct_y = cy + math.sin(mid) * radius * 0.66
        draw_centered_text(draw, (pct_x, pct_y), f"{pct:.1f}%", small_font, "#20242A")

        label_x = cx + math.cos(mid) * radius * 1.18
        label_y = cy + math.sin(mid) * radius * 1.18
        anchor = "mm"
        text = f"{label} {value}"
        draw.text((label_x, label_y), text, font=label_font, fill="#20242A", anchor=anchor)

        start += angle

    legend_x, legend_y = 1270, 360
    draw.text((legend_x, legend_y - 70), "标签类别", font=title_font, fill="#20242A")
    for index, (category, color) in enumerate(COLORS.items()):
        y = legend_y + index * 72
        draw.rounded_rectangle(
            (legend_x, y, legend_x + 34, y + 34),
            radius=6,
            fill=hex_to_rgb(color),
        )
        draw.text((legend_x + 52, y - 2), category, font=legend_font, fill="#20242A")

    note = f"数据口径：截图中“出现次数”，合计 {total} 次；扇区表示各标签在全部出现次数中的占比。"
    draw.text((120, 1110), note, font=small_font, fill="#555B64")

    output = os.path.abspath("content-tags-pie.png")
    image.save(output)
    print(output)


if __name__ == "__main__":
    main()
