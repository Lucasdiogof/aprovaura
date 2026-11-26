"""Gera SOMENTE os fontes do ícone de instalação (launcher) do Aprovaura.

Símbolo = o "A" oficial (aprovaura-brand/01-icone-simbolo-A.webp), sem
alteração de cor/forma; só escala e posição mudam. Fundo = degradê sutil em
tons escuros da identidade (violeta -> azul-noite -> petróleo).

Saídas (lib/assets/branding):
  aprovaura_app_icon_1024.png         iOS/legado: opaco, sem cantos (o SO mascara)
  aprovaura_adaptive_foreground.png   Android: só o A, transparente, na safe zone
  aprovaura_adaptive_background.png   Android: degradê
Depois: dart run flutter_launcher_icons

Uso: python tool/gen_app_icon.py [caminho/01-icone-simbolo-A.webp]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'lib' / 'assets' / 'branding'
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT.parent / 'aprovaura-brand' / '01-icone-simbolo-A.webp'
N = 1024
SAFE_R = 33 / 108 * N  # círculo seguro adaptive: 66dp de 108dp = 313px
FG_R = 330             # raio máx. do A (só pontas da estrela/anel passam de 313); máscara circular visível = 72dp (raio 341)
IOS_W = 0.80           # largura do A no ícone iOS (antes 0.70)


def load_symbol():
    arr = np.array(Image.open(SRC).convert('RGBA'))
    arr[arr[..., 3] <= 4] = 0
    ys, xs = np.nonzero(arr[..., 3] > 4)
    return arr[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def hull(pts):
    pts = sorted(set(map(tuple, pts)))
    def half(p):
        h = []
        for q in p:
            while len(h) >= 2 and (h[-1][0]-h[-2][0])*(q[1]-h[-2][1]) - (h[-1][1]-h[-2][1])*(q[0]-h[-2][0]) <= 0:
                h.pop()
            h.append(q)
        return h[:-1]
    return np.array(half(pts) + half(pts[::-1]), float)


def centers(sym):
    """Centro óptico (bbox+centróide) e centro do menor círculo envolvente."""
    a = sym[..., 3].astype(float)
    ys, xs = np.nonzero(a > 32)
    bbox_c = np.array([(xs.min() + xs.max()) / 2, (ys.min() + ys.max()) / 2])
    w = a.sum()
    cen = np.array([(a.sum(0) * np.arange(a.shape[1])).sum() / w,
                    (a.sum(1) * np.arange(a.shape[0])).sum() / w])
    optical = (bbox_c + cen) / 2
    # casco convexo de pontos amostrados + descida para o círculo mínimo
    sel = [(int(xs[ys == y].min()), int(y)) for y in np.unique(ys)] + [(int(xs[ys == y].max()), int(y)) for y in np.unique(ys)]  # extremos por linha: casco exato
    h = hull(sel)
    c = bbox_c.copy()
    for i in range(4000):
        d = np.hypot(*(h - c).T)
        c += (h[d.argmax()] - c) * 0.5 * (1 - i / 4000)
    return optical, c, h


def place(sym, scale, center):
    im = Image.fromarray(sym)
    sized = im.resize((round(im.width * scale), round(im.height * scale)), Image.LANCZOS)
    off = (np.array([N / 2, N / 2]) - np.array(center) * scale).round().astype(int)
    layer = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    layer.alpha_composite(sized, dest=(int(off[0]), int(off[1])))
    return layer


def gradient():
    y, x = np.mgrid[0:N, 0:N] / (N - 1)
    t = (x + y) / 2  # diagonal
    stops = [(0.0, (0x24, 0x15, 0x4F)), (0.5, (0x10, 0x14, 0x33)), (1.0, (0x07, 0x1F, 0x30))]
    img = np.zeros((N, N, 3))
    for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
        m = (t >= t0) & (t <= t1)
        k = ((t - t0) / (t1 - t0))[m][:, None]
        img[m] = np.array(c0) * (1 - k) + np.array(c1) * k
    glow = np.exp(-(((x - .5) ** 2 + (y - .52) ** 2) / 0.09))[..., None]  # halo suave atrás do A
    img = img + glow * np.array([22, 14, 44])
    return Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), 'RGB')


def main():
    sym = load_symbol()
    optical, mec, h = centers(sym)
    bg = gradient()

    # Android: centro = meio-termo óptico/círculo mínimo (equilíbrio visual sem desperdiçar safe zone)
    c = (optical + mec) / 2
    r = np.hypot(*(h - c).T).max()
    scale = FG_R / r
    fg = place(sym, scale, c)
    fg.save(OUT / 'aprovaura_adaptive_foreground.png', optimize=True)
    bg.save(OUT / 'aprovaura_adaptive_background.png', optimize=True)
    print('android: A %.0fpx de %d (%.1f%%), raio máx %.0f / seguro %.0f' % (
        sym.shape[1] * scale, N, sym.shape[1] * scale / N * 100, FG_R, SAFE_R))

    # iOS: A maior, centro óptico, opaco
    s = N * IOS_W / sym.shape[1]
    layer = place(sym, s, optical)
    master = bg.convert('RGBA')
    master.alpha_composite(layer)
    master.convert('RGB').save(OUT / 'aprovaura_app_icon_1024.png', optimize=True)
    print('ios: A %.0fpx (%.0f%%)' % (sym.shape[1] * s, IOS_W * 100))


if __name__ == '__main__':
    main()
