"""Deduplicação local e gratuita: hash exato + Jaccard de n-gramas com MinHash/LSH (sem embeddings).
Nunca apaga nada: só aponta duplicatas; quem decide (rejeitar a NOVA) é run.py. Questões do acervo ativo nunca são tocadas."""
import hashlib, re, zlib
from qc import norm_text

N_HASH, BANDS = 64, 16  # 16 bandas x 4 linhas


def shingles(text, n=3):
    w = norm_text(text).split()
    return {" ".join(w[i:i + n]) for i in range(max(1, len(w) - n + 1))} if w else set()

def jaccard(a, b):
    return len(a & b) / len(a | b) if a and b else 0.0

def signature(sh):
    return [min((zlib.crc32(s.encode(), k * 2654435761 % 2**32) for s in sh), default=0) for k in range(N_HASH)]

def exact_key(prompt):
    return hashlib.sha1(norm_text(prompt).encode()).hexdigest()

class Index:
    """Índice de questões já conhecidas (acervo + lote). add() e query() são independentes."""
    def __init__(self): self.items, self.buckets, self.exact = {}, {}, {}
    def add(self, qid, prompt, options=()):
        sh = shingles(prompt); full = shingles(prompt + " " + " ".join(options))
        self.items[qid] = (sh, full); self.exact.setdefault(exact_key(prompt), qid)
        sig = signature(sh); r = N_HASH // BANDS
        for b in range(BANDS): self.buckets.setdefault((b, tuple(sig[b * r:(b + 1) * r])), set()).add(qid)
    def query(self, prompt, options=(), thr_prompt=0.7, thr_full=0.75, skip=None):
        k = exact_key(prompt)
        if k in self.exact and self.exact[k] != skip: return self.exact[k], 1.0, "enunciado_identico"
        sh = shingles(prompt); full = shingles(prompt + " " + " ".join(options)); sig = signature(sh); r = N_HASH // BANDS
        cand = set()
        for b in range(BANDS): cand |= self.buckets.get((b, tuple(sig[b * r:(b + 1) * r])), set())
        best = (None, 0.0, "")
        for c in cand:
            if c == skip: continue
            jp, jf = jaccard(sh, self.items[c][0]), jaccard(full, self.items[c][1])
            s = max(jp, jf)
            if (jp >= thr_prompt or jf >= thr_full) and s > best[1]: best = (c, s, "similaridade_ngramas")
        return best
