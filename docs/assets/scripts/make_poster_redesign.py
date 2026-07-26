import math
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont


SOURCE = r"C:\Users\xushe\AppData\Local\Temp\codex-clipboard-3fd26a07-93e4-45fc-8146-3830867f63d2.png"
OUTPUT = "locates-poster-redesign.png"

W, H = 1536, 2048


def font(size, bold=False):
    candidates = [
        r"C:\Windows\Fonts\msyhbd.ttc" if bold else r"C:\Windows\Fonts\msyh.ttc",
        r"C:\Windows\Fonts\simhei.ttf",
        r"C:\Windows\Fonts\simsun.ttc",
    ]
    for path in candidates:
        if path and os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def rgb(hex_color):
    value = hex_color.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def rounded(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def text(draw, xy, value, fnt, fill="#4B2717", anchor=None, spacing=4):
    draw.multiline_text(xy, value, font=fnt, fill=fill, anchor=anchor, spacing=spacing)


def fit_multiline(draw, value, fnt, max_width):
    lines = []
    for para in value.split("\n"):
        current = ""
        for ch in para:
            test = current + ch
            if draw.textlength(test, font=fnt) <= max_width:
                current = test
            else:
                if current:
                    lines.append(current)
                current = ch
        if current:
            lines.append(current)
    return "\n".join(lines)


def draw_jujube(draw, cx, cy, scale=1.0):
    red = "#D82919"
    orange = "#F47B22"
    dark = "#8B2617"
    draw.ellipse(
        (cx - 56 * scale, cy - 72 * scale, cx + 52 * scale, cy + 70 * scale),
        fill=red,
        outline="#B91D14",
        width=max(1, int(3 * scale)),
    )
    draw.ellipse(
        (cx - 82 * scale, cy + 18 * scale, cx + 20 * scale, cy + 88 * scale),
        fill=orange,
        outline="#D04B1D",
        width=max(1, int(3 * scale)),
    )
    draw.ellipse(
        (cx - 42 * scale, cy + 39 * scale, cx - 8 * scale, cy + 59 * scale),
        fill="#F8D48C",
    )
    draw.ellipse(
        (cx - 28 * scale, cy + 43 * scale, cx - 14 * scale, cy + 55 * scale),
        fill=dark,
    )
    draw.ellipse(
        (cx - 28 * scale, cy - 52 * scale, cx + 22 * scale, cy - 14 * scale),
        fill="#F35C39",
    )


def section(draw, box, title, subtitle=None):
    rounded(draw, box, 28, "#FFF7EB", "#F2C789", 3)
    x, y, _, _ = box
    text(draw, (x + 34, y + 28), title, font(38, True), "#C81E16")
    if subtitle:
        text(draw, (x + 34, y + 76), subtitle, font(22), "#D87622")
    draw.line((x + 34, y + 110, box[2] - 34, y + 110), fill="#F0B75A", width=2)


def bullet(draw, x, y, content, max_width, color="#D64224"):
    draw.ellipse((x, y + 6, x + 16, y + 22), fill=color)
    wrapped = fit_multiline(draw, content, font(23), max_width)
    text(draw, (x + 28, y), wrapped, font(23), "#6A341C", spacing=8)
    return y + 34 * (wrapped.count("\n") + 1) + 12


def phone(draw, box, title, accent):
    x1, y1, x2, y2 = box
    rounded(draw, box, 28, "#292929", "#111111", 2)
    rounded(draw, (x1 + 8, y1 + 8, x2 - 8, y2 - 8), 22, "#FFFFFF")
    draw.ellipse(((x1 + x2) / 2 - 9, y1 + 15, (x1 + x2) / 2 + 9, y1 + 33), fill="#111111")
    text(draw, ((x1 + x2) / 2, y1 + 56), title, font(20, True), "#4B2717", anchor="mm")
    rounded(draw, (x1 + 24, y1 + 86, x2 - 24, y1 + 126), 12, "#F6EEE4")
    for i in range(3):
        yy = y1 + 144 + i * 50
        rounded(draw, (x1 + 24, yy, x2 - 24, yy + 38), 10, "#FAF7F2", "#E9D8C5", 1)
        draw.ellipse((x1 + 40, yy + 12, x1 + 56, yy + 28), fill=accent)
        draw.line((x1 + 70, yy + 16, x2 - 44, yy + 16), fill="#D7C7B6", width=3)
        draw.line((x1 + 70, yy + 29, x2 - 74, yy + 29), fill="#E7D9CA", width=2)
    rounded(draw, (x1 + 32, y2 - 70, x2 - 32, y2 - 32), 18, accent)


def big_number_card(draw, box, value, label, fill):
    rounded(draw, box, 24, fill, "#FFFFFF", 2)
    x1, y1, x2, y2 = box
    text(draw, ((x1 + x2) / 2, y1 + 52), value, font(42, True), "#FFFFFF", anchor="mm")
    wrapped = fit_multiline(draw, label, font(22), x2 - x1 - 36)
    text(draw, ((x1 + x2) / 2, y1 + 112), wrapped, font(22), "#FFFFFF", anchor="mm", spacing=5)


def main():
    canvas = Image.new("RGB", (W, H), "#FFF6E4")
    draw = ImageDraw.Draw(canvas)

    for i in range(0, H, 4):
        shade = int(246 + 8 * math.sin(i / 180))
        draw.line((0, i, W, i), fill=(255, min(250, shade), 228), width=4)

    for cx, cy, r, color in [
        (1300, 160, 360, "#FFE4A6"),
        (115, 1640, 260, "#FFE9C5"),
        (720, 350, 250, "#FFE1B2"),
    ]:
        overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.ellipse((cx - r, cy - r, cx + r, cy + r), fill=rgb(color) + (90,))
        overlay = overlay.filter(ImageFilter.GaussianBlur(40))
        canvas.paste(Image.alpha_composite(canvas.convert("RGBA"), overlay).convert("RGB"))
        draw = ImageDraw.Draw(canvas)

    rounded(draw, (62, 48, 1474, 306), 42, "#FFFDF8", "#F7D799", 2)
    text(draw, (114, 94), "枣寻", font(92, True), "#C80000")
    text(draw, (338, 116), "LocateS", font(80, True), "#E0A116")
    text(draw, (118, 212), "让每件物品都有迹可循", font(38, True), "#C75B12")
    text(draw, (644, 222), "Everything Locates In Its Space", font(30), "#8E4B1A")
    rounded(draw, (1198, 82, 1370, 260), 30, "#FFF2D8", "#FFD460", 6)
    draw_jujube(draw, 1294, 158, 0.9)

    section(draw, (62, 342, 724, 760), "设计背景", "Design Background")
    y = 480
    y = bullet(draw, 102, y, "大学生居住空间有限，物品分散，容易遗忘位置。", 560)
    y = bullet(draw, 102, y, "用户主要依靠记忆管理物品，找物、重复购买、事件准备问题突出。", 560)
    bullet(draw, 102, y, "枣寻以空间标记、事件清单、AI辅助为核心，提升收纳效率。", 560)

    section(draw, (772, 342, 1474, 760), "调研洞察", "Survey Insights")
    big_number_card(draw, (820, 480, 1018, 684), "93.33%", "依靠记忆\n管理物品", "#D65032")
    big_number_card(draw, (1038, 480, 1236, 684), "80%", "收拾后忘记\n物品位置", "#E58D35")
    big_number_card(draw, (1256, 480, 1426, 684), "76.67%", "希望AI记录\n物品位置", "#B069D6")

    section(draw, (62, 806, 724, 1290), "产品创新", "Product Innovation")
    innovations = [
        ("1", "沉浸光感", "底部悬浮导航、动态 MiniBar 与渐变背景，强化轻量操作体验。"),
        ("2", "物品-事件关联", "通过勾选物品与事件关联，生成准备清单并支持提醒。"),
        ("3", "AI辅助管理", "辅助分类、识别、整理建议和清单规划，降低录入成本。"),
    ]
    y = 920
    for num, title, desc in innovations:
        rounded(draw, (100, y - 7, 154, y + 47), 12, "#FFF4E7", "#D11F14", 4)
        text(draw, (127, y + 19), num, font(35, True), "#D11F14", anchor="mm")
        text(draw, (178, y - 4), title, font(32, True), "#C81E16")
        text(draw, (178, y + 42), fit_multiline(draw, desc, font(21), 470), font(21), "#6A341C", spacing=6)
        y += 120

    section(draw, (772, 806, 1474, 1290), "用户定位", "User Targeting")
    targets = [
        ("大学生", "宿舍空间小，书本、衣物、证件、电子产品分散，需要快速定位。"),
        ("搬家/租房青年", "常整理收纳和行李箱，需要物品清单、位置追踪与事件提醒。"),
        ("家庭成员", "管理衣柜、药品、厨房小物和日历提醒，适合家庭日常整理。"),
    ]
    y = 940
    for title, desc in targets:
        draw.ellipse((820, y, 866, y + 46), fill="#F4B45E", outline="#D65032", width=2)
        text(draw, (890, y - 2), title, font(28, True), "#C81E16")
        text(draw, (890, y + 40), fit_multiline(draw, desc, font(22), 505), font(22), "#6A341C", spacing=7)
        y += 124

    section(draw, (62, 1338, 1474, 1846), "主要界面", "Main Pages")
    phone_y = 1478
    phone_w, phone_h = 176, 270
    phone_boxes = [
        (164, phone_y, 164 + phone_w, phone_y + phone_h, "首页", "#E84D47"),
        (430, phone_y, 430 + phone_w, phone_y + phone_h, "空间", "#E58D35"),
        (696, phone_y, 696 + phone_w, phone_y + phone_h, "物品详情", "#A86FE7"),
        (962, phone_y, 962 + phone_w, phone_y + phone_h, "事件提醒", "#4E9BE6"),
        (1228, phone_y, 1228 + phone_w, phone_y + phone_h, "添加物品", "#2F9E6B"),
    ]
    for box in phone_boxes:
        phone(draw, box[:4], box[4], box[5])
    for i in range(len(phone_boxes) - 1):
        x1 = phone_boxes[i][2] + 22
        y1 = phone_y + phone_h // 2
        x2 = phone_boxes[i + 1][0] - 22
        draw.line((x1, y1, x2, y1), fill="#D11F14", width=4)
        draw.polygon([(x2, y1), (x2 - 18, y1 - 10), (x2 - 18, y1 + 10)], fill="#D11F14")

    rounded(draw, (98, 1866, 1438, 2012), 24, "#F4CF68", "#C81E16", 4)
    text(draw, (132, 1892), "CONCLUSION", font(40, True), "#FFFFFF")
    conclusion = "枣寻 LocateS 以物品记录、空间定位、事件提醒和AI辅助为核心，帮助用户建立个人物品档案，减少遗忘、重复购买和临时寻找，让物品管理更清晰高效。"
    text(draw, (132, 1942), fit_multiline(draw, conclusion, font(23), 1260), font(23), "#FFFFFF", spacing=7)

    canvas.save(os.path.abspath(OUTPUT), quality=95)
    print(os.path.abspath(OUTPUT))


if __name__ == "__main__":
    main()
