import re

with open('C:/Users/xushe/Desktop/666/作品说明文档/作品说明文档.tex', 'r', encoding='utf-8') as f:
    content = f.read()

BS = '\\'
start = content.index(BS + 'secondheading{介绍文档}')
end_marker = '% ' + BS + 'clearpage'
end = content.index(end_marker, start)
chunk = content[start:end]

# Remove LaTeX comments
text = re.sub(r'(?<!\\)%.*', '', chunk)
# Remove \command... sequences - just remove everything that starts with \
text = re.sub(BS + r'[a-zA-Z@*]+', '', text)
# Remove braces
text = text.replace('{', '').replace('}', '')
# Remove remaining backslash-escaped special chars like \%, \_, etc
text = re.sub(BS + r'[%_&$#]', '', text)
# Also remove \verb|...| blocks
text = re.sub(BS + r'verb\|[^|]*\|', '', text)
# Collapse whitespace
text = re.sub(r'\s+', '', text)

cn = sum(1 for c in text if ord('一') <= ord(c) <= ord('鿿'))
total = len(text)

print('Chinese characters (汉字):', cn)
print('Total visible characters:', total)
print('First 100:', text[:100])
