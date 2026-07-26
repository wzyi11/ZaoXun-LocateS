from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math

BASE = Path(__file__).resolve().parent

BG = (232, 232, 232)
CARD = (250, 250, 250)
TEXT = (48, 48, 48)
MUTED = (95, 95, 95)
RED = (214, 74, 74)
BLUE = (58, 126, 220)
GREEN = (57, 165, 92)


def font(size: int, bold: bool = False):
    candidates = []
    if bold:
        candidates += [r"C:\Windows\Fonts\msyhbd.ttc", r"C:\Windows\Fonts\simhei.ttf"]
    candidates += [
        r"C:\Windows\Fonts\msyh.ttc",
        r"C:\Windows\Fonts\simhei.ttf",
        r"C:\Windows\Fonts\arial.ttf",
    ]
    for item in candidates:
        try:
            return ImageFont.truetype(item, size)
        except Exception:
            pass
    return ImageFont.load_default()


TITLE = font(48, True)
SUB = font(25)
LABEL = font(22, True)
ARROW = font(18)

SCREENS = {
    "start": ("StartPage.png", "StartPage 启动页"),
    "02": ("02_items_list_all.png", "物品列表"),
    "03": ("03_item_detail_view.png", "物品详情"),
    "04": ("04_item_delete_confirm.png", "删除确认"),
    "05": ("05_item_edit_category_sheet.png", "修改分类"),
    "06": ("06_item_edit_location_sheet.png", "分配位置"),
    "07": ("07_item_category_manager_sheet.png", "管理分类"),
    "08": ("08_items_list_documents.png", "分类筛选"),
    "09": ("09_item_add_sheet.png", "添加物品"),
    "10": ("10_spaces_list.png", "空间列表"),
    "11": ("11_space_detail_locations.png", "空间详情"),
    "12": ("12_space_panorama_preview.png", "全景预览"),
    "13": ("13_space_replace_image_confirm.png", "替换照片"),
    "14": ("14_space_items_list.png", "空间物品"),
    "15": ("15_space_add_partition_dialog.png", "新增分区"),
    "16": ("16_space_add_items_to_partition_sheet.png", "分区添加物品"),
    "17": ("17_events_calendar_active.png", "事件日历"),
    "18": ("18_event_detail.png", "事件详情"),
    "19": ("19_event_edit_items_sheet.png", "修改事件物品"),
    "20": ("20_event_add_sheet.png", "添加事件"),
    "21": ("21_events_calendar_completed.png", "已完成事件"),
    "22": ("22_profile_dashboard.png", "我的"),
    "23": ("23_profile_background_settings.png", "背景设置"),
}


def fit_screen(code: str, width: int) -> Image.Image:
    image = Image.open(BASE / SCREENS[code][0]).convert("RGBA")
    ratio = width / image.width
    return image.resize((width, int(image.height * ratio)), Image.LANCZOS)


def rounded_image(image: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", image.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([0, 0, image.width, image.height], radius=radius, fill=255)
    out = Image.new("RGBA", image.size, (0, 0, 0, 0))
    out.paste(image, (0, 0), mask)
    return out


def make_canvas(width: int, height: int, title: str, subtitle: str):
    canvas = Image.new("RGBA", (width, height), BG + (255,))
    draw = ImageDraw.Draw(canvas)
    draw.text((72, 52), title, fill=TEXT, font=TITLE)
    draw.text((74, 112), subtitle, fill=MUTED, font=SUB)
    return canvas, draw


def draw_card(canvas: Image.Image, code: str, center: tuple[int, int], width: int = 205):
    draw = ImageDraw.Draw(canvas)
    screen = rounded_image(fit_screen(code, width), 26)
    x = int(center[0] - screen.width / 2)
    y = int(center[1] - screen.height / 2)
    pad = 14
    x1, y1 = x - pad, y - pad
    x2, y2 = x + screen.width + pad, y + screen.height + pad

    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle([x1 + 5, y1 + 8, x2 + 5, y2 + 8], radius=24, fill=(0, 0, 0, 42))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(10)))

    draw.rounded_rectangle([x1, y1, x2, y2], radius=24, fill=CARD)
    canvas.alpha_composite(screen, (x, y))

    label = SCREENS[code][1]
    bbox = draw.textbbox((0, 0), label, font=LABEL)
    draw.text((center[0] - (bbox[2] - bbox[0]) / 2, y2 + 20), label, fill=TEXT, font=LABEL)

    return {"left": x1, "top": y1, "right": x2, "bottom": y2, "cx": center[0], "cy": center[1]}


def edge(box, side: str):
    return {
        "left": (box["left"], box["cy"]),
        "right": (box["right"], box["cy"]),
        "top": (box["cx"], box["top"]),
        "bottom": (box["cx"], box["bottom"]),
    }[side]


def dashed_line(draw, points, color, width=4, dash=14, gap=9):
    for start, end in zip(points, points[1:]):
        x1, y1 = start
        x2, y2 = end
        dx, dy = x2 - x1, y2 - y1
        dist = math.hypot(dx, dy)
        if dist == 0:
            continue
        ux, uy = dx / dist, dy / dist
        pos = 0
        while pos < dist:
            pos2 = min(pos + dash, dist)
            draw.line([(x1 + ux * pos, y1 + uy * pos), (x1 + ux * pos2, y1 + uy * pos2)], fill=color, width=width)
            pos += dash + gap


def arrow_head(draw, start, end, color, size=17):
    x1, y1 = start
    x2, y2 = end
    angle = math.atan2(y2 - y1, x2 - x1)
    points = [
        (x2, y2),
        (x2 + size * math.cos(angle + math.pi * 0.82), y2 + size * math.sin(angle + math.pi * 0.82)),
        (x2 + size * math.cos(angle - math.pi * 0.82), y2 + size * math.sin(angle - math.pi * 0.82)),
    ]
    draw.polygon(points, fill=color)


def arrow_label(draw, text: str, xy: tuple[int, int], color):
    x, y = xy
    bbox = draw.textbbox((0, 0), text, font=ARROW)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.rounded_rectangle([x - 9, y - 7, x + w + 9, y + h + 7], radius=8, fill=BG)
    draw.text((x, y), text, fill=color, font=ARROW)


def connect(draw, boxes, start_code, start_side, end_code, end_side, color, text, label_xy, via=None):
    points = [edge(boxes[start_code], start_side)] + (via or []) + [edge(boxes[end_code], end_side)]
    dashed_line(draw, points, color)
    arrow_head(draw, points[-2], points[-1], color)
    arrow_label(draw, text, label_xy, color)


def connect_points(draw, points, color, text, label_xy):
    dashed_line(draw, points, color)
    arrow_head(draw, points[-2], points[-1], color)
    arrow_label(draw, text, label_xy, color)


def render(path: str, canvas: Image.Image):
    canvas.convert("RGB").save(BASE / path, quality=95)
    image = Image.open(BASE / path)
    image.verify()
    image = Image.open(BASE / path)
    print(f"OK {path} {image.width}x{image.height}")


def generate_overview():
    canvas, draw = make_canvas(
        2400,
        1850,
        "App 流程交互图 - 总览",
        "StartPage 位于中心；物品、空间、事件、我的与新增表单围绕启动页放射状分布。",
    )
    boxes = {}
    positions = {
        "start": (1200, 930),
        "02": (485, 430),
        "10": (1200, 315),
        "17": (1915, 430),
        "09": (485, 1430),
        "20": (1200, 1545),
        "22": (1915, 1430),
    }
    for code, pos in positions.items():
        boxes[code] = draw_card(canvas, code, pos, 220 if code == "start" else 205)

    connect(draw, boxes, "start", "left", "02", "right", RED, "进入物品", (740, 620))
    connect(draw, boxes, "start", "top", "10", "bottom", BLUE, "空间 Tab", (1240, 600))
    connect(draw, boxes, "start", "right", "17", "left", BLUE, "事件 Tab", (1585, 620))
    connect(draw, boxes, "start", "left", "09", "right", GREEN, "+ 添加物品", (735, 1235))
    connect(draw, boxes, "start", "bottom", "20", "top", GREEN, "+ 添加事件", (1240, 1265))
    connect(draw, boxes, "start", "right", "22", "left", BLUE, "我的 Tab", (1585, 1235))

    ring = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(ring).ellipse([825, 555, 1575, 1305], outline=(255, 255, 255, 92), width=3)
    canvas.alpha_composite(ring)
    render("app-flow-overview.png", canvas)


def generate_items():
    canvas, draw = make_canvas(
        2050,
        1380,
        "App 流程交互图 - 物品管理",
        "物品列表进入详情；详情页可删除、修改分类和位置；列表页可筛选、管理分类和新增物品。",
    )
    boxes = {}
    positions = {
        "02": (255, 430),
        "03": (660, 430),
        "04": (1065, 430),
        "05": (1470, 430),
        "06": (1830, 430),
        "07": (460, 1070),
        "08": (980, 1070),
        "09": (1500, 1070),
    }
    for code, pos in positions.items():
        boxes[code] = draw_card(canvas, code, pos, 205)

    connect(draw, boxes, "02", "right", "03", "left", RED, "点选物品", (425, 390))
    connect(draw, boxes, "03", "right", "04", "left", RED, "删除", (830, 390))
    connect(draw, boxes, "03", "right", "05", "left", BLUE, "修改分类", (1100, 195), via=[(820, 185), (1300, 185)])
    connect(draw, boxes, "03", "right", "06", "left", BLUE, "分配位置", (1370, 720), via=[(820, 720), (1660, 720)])
    connect(draw, boxes, "02", "bottom", "07", "top", BLUE, "管理分类", (330, 760), via=[(255, 770), (460, 770)])
    connect(draw, boxes, "07", "right", "08", "left", BLUE, "筛选分类", (690, 1030))
    connect(draw, boxes, "02", "bottom", "09", "top", GREEN, "+ 添加物品", (815, 840), via=[(255, 840), (1500, 840)])
    render("app-flow-items.png", canvas)


def generate_spaces():
    canvas, draw = make_canvas(
        2050,
        1380,
        "App 流程交互图 - 空间管理",
        "空间列表进入空间详情；空间详情连接全景、替换图片、分区新增、分区添加物品和空间物品列表。",
    )
    boxes = {}
    positions = {
        "10": (255, 430),
        "11": (660, 430),
        "12": (1065, 430),
        "13": (1470, 430),
        "15": (1830, 430),
        "14": (820, 1070),
        "16": (1600, 1070),
    }
    for code, pos in positions.items():
        boxes[code] = draw_card(canvas, code, pos, 212 if code in {"12", "13", "15"} else 205)

    connect(draw, boxes, "10", "right", "11", "left", RED, "进入空间", (420, 390))
    connect(draw, boxes, "11", "right", "12", "left", RED, "查看全景", (830, 390))
    connect(draw, boxes, "12", "right", "13", "left", RED, "替换照片", (1240, 390))
    connect(draw, boxes, "11", "right", "15", "left", GREEN, "新增分区", (1210, 195), via=[(825, 185), (1660, 185)])
    connect(draw, boxes, "15", "bottom", "16", "top", GREEN, "添加物品到分区", (1650, 760))
    connect(draw, boxes, "11", "bottom", "14", "top", BLUE, "查看空间物品", (680, 760), via=[(660, 770), (820, 770)])
    render("app-flow-spaces.png", canvas)


def generate_events_profile():
    canvas, draw = make_canvas(
        1900,
        1500,
        "App 流程交互图 - 事件与我的",
        "日历页查看进行中/已完成事件；事件详情可修改关联物品；我的页进入背景设置。",
    )
    boxes = {}
    positions = {
        "17": (260, 430),
        "18": (680, 430),
        "19": (1100, 430),
        "20": (1520, 430),
        "21": (260, 1050),
        "22": (1100, 1050),
        "23": (1520, 1050),
    }
    for code, pos in positions.items():
        boxes[code] = draw_card(canvas, code, pos, 205)

    connect(draw, boxes, "17", "right", "18", "left", RED, "点选事件", (430, 390))
    connect(draw, boxes, "18", "right", "19", "left", BLUE, "修改物品", (850, 390))
    connect_points(
        draw,
        [
            (boxes["17"]["right"], boxes["17"]["cy"] + 115),
            (440, 715),
            (1320, 715),
            (1320, boxes["20"]["cy"] + 105),
            (boxes["20"]["left"], boxes["20"]["cy"] + 105),
        ],
        GREEN,
        "+ 添加事件",
        (845, 705),
    )
    connect(draw, boxes, "17", "bottom", "21", "top", BLUE, "完成/筛选", (285, 735))
    connect_points(
        draw,
        [
            (boxes["17"]["right"], boxes["17"]["bottom"] - 90),
            (430, boxes["17"]["bottom"] - 90),
            (430, boxes["22"]["cy"]),
            (boxes["22"]["left"], boxes["22"]["cy"]),
        ],
        BLUE,
        "我的 Tab",
        (690, 1015),
    )
    connect(draw, boxes, "22", "right", "23", "left", RED, "背景设置", (1275, 1010))
    render("app-flow-events-profile.png", canvas)


def generate_items_spaces_combo():
    items = Image.open(BASE / "app-flow-items.png").convert("RGBA")
    spaces = Image.open(BASE / "app-flow-spaces.png").convert("RGBA")
    gap = 70
    width = max(items.width, spaces.width)
    height = items.height + spaces.height + gap
    canvas = Image.new("RGBA", (width, height), BG + (255,))
    canvas.alpha_composite(items, ((width - items.width) // 2, 0))
    canvas.alpha_composite(spaces, ((width - spaces.width) // 2, items.height + gap))
    render("app-flow-items-spaces.png", canvas)


def main():
    generate_overview()
    generate_items()
    generate_spaces()
    generate_events_profile()
    generate_items_spaces_combo()


if __name__ == "__main__":
    main()
