import os

from PIL import Image, ImageDraw, ImageFont


ITEMS = [
    ("依靠记忆管理物品", 93.33, "现状"),
    ("认为提前提醒 App 有价值/愿意尝试", 83.34, "价值判断"),
    ("收拾后忘记物品位置", 80.00, "痛点"),
    ("希望 AI 记录物品存放位置", 76.67, "AI能力"),
    ("希望根据事件主动提醒物品", 70.00, "AI能力"),
    ("希望旅行前提醒相关物品", 66.67, "事件场景"),
    ("希望开学/考试前提醒", 63.33, "事件场景"),
    ("希望工作任务前提醒", 63.33, "事件场景"),
    ("需要时找物品耗时较长", 56.67, "痛点"),
    ("希望 AI 根据空间提出整理建议", 56.67, "AI能力"),
]

COLORS = {
    "现状": "#8EA6C8",
    "痛点": "#E58D6D",
    "事件场景": "#8DCB8A",
    "AI能力": "#A994E6",
    "价值判断": "#F0B75A",
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


def draw_text(draw, xy, text, font, fill="#20242A", anchor=None):
    draw.text(xy, text, font=font, fill=fill, anchor=anchor)


def main():
    width, height = 1800, 1120
    image = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(image)

    title_font = load_font(48)
    subtitle_font = load_font(25)
    label_font = load_font(28)
    value_font = load_font(30)
    small_font = load_font(22)

    draw_text(draw, (90, 68), "个人物品管理 App 需求重点指标", title_font)
    draw_text(
        draw,
        (90, 128),
        "基于问卷结果，选取最能说明用户痛点、使用场景与 AI 能力期待的指标。",
        subtitle_font,
        "#555B64",
    )

    left_label_x = 90
    bar_x = 650
    bar_y = 255
    bar_w = 930
    bar_h = 34
    row_gap = 78
    max_value = 100

    draw.line((bar_x, bar_y - 38, bar_x + bar_w, bar_y - 38), fill="#D8DDE5", width=2)
    for tick in range(0, 101, 20):
        x = bar_x + int(bar_w * tick / max_value)
        draw.line((x, bar_y - 45, x, bar_y + row_gap * len(ITEMS) - 34), fill="#EDF0F4", width=1)
        draw_text(draw, (x, bar_y - 78), f"{tick}%", small_font, "#6B7280", anchor="mm")

    for idx, (label, value, category) in enumerate(ITEMS):
        y = bar_y + idx * row_gap
        color = hex_to_rgb(COLORS[category])
        draw_text(draw, (left_label_x, y + bar_h / 2), label, label_font, anchor="lm")

        draw.rounded_rectangle(
            (bar_x, y, bar_x + bar_w, y + bar_h),
            radius=17,
            fill="#EEF1F5",
        )
        fill_w = int(bar_w * value / max_value)
        draw.rounded_rectangle(
            (bar_x, y, bar_x + fill_w, y + bar_h),
            radius=17,
            fill=color,
        )

        draw_text(draw, (bar_x + bar_w + 28, y + bar_h / 2), f"{value:.2f}%", value_font, anchor="lm")

        badge_x = bar_x + fill_w + 12 if fill_w < bar_w - 120 else bar_x + fill_w - 112
        badge_fill = "#FFFFFF" if fill_w >= bar_w - 120 else "#F6F7F9"
        badge_text = "#20242A"
        bbox = draw.textbbox((0, 0), category, font=small_font)
        badge_w = bbox[2] - bbox[0] + 24
        draw.rounded_rectangle(
            (badge_x, y - 2, badge_x + badge_w, y + bar_h + 2),
            radius=18,
            fill=badge_fill,
            outline="#D8DDE5",
        )
        draw_text(draw, (badge_x + 12, y + bar_h / 2), category, small_font, badge_text, anchor="lm")

    legend_y = 1020
    legend_x = 90
    for category, color in COLORS.items():
        draw.rounded_rectangle(
            (legend_x, legend_y, legend_x + 28, legend_y + 28),
            radius=6,
            fill=hex_to_rgb(color),
        )
        draw_text(draw, (legend_x + 42, legend_y + 14), category, small_font, "#555B64", anchor="lm")
        legend_x += 205

    output = os.path.abspath("111-focus-chart.png")
    image.save(output)
    print(output)


if __name__ == "__main__":
    main()
