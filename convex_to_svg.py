from __future__ import annotations

def rgb01_to_hex(rgb):
    r, g, b = rgb
    return '#%02x%02x%02x' % (
        int(max(0, min(255, round(r * 255)))),
        int(max(0, min(255, round(g * 255)))),
        int(max(0, min(255, round(b * 255)))),
    )

import argparse, math, re, sys
from dataclasses import dataclass
from typing import Any, List, Tuple, Optional

# -----------------------------
# Basic math types
# -----------------------------

@dataclass
class Vec:
    x: float
    y: float
    z: float

    def __add__(self, o):
        if isinstance(o, Vec):
            return Vec(self.x + o.x, self.y + o.y, self.z + o.z)
        return Vec(self.x + o, self.y + o, self.z + o)

    __radd__ = __add__

    def __sub__(self, o):
        if isinstance(o, Vec):
            return Vec(self.x - o.x, self.y - o.y, self.z - o.z)
        return Vec(self.x - o, self.y - o, self.z - o)

    def __rsub__(self, o):
        if isinstance(o, Vec):
            return Vec(o.x - self.x, o.y - self.y, o.z - self.z)
        return Vec(o - self.x, o - self.y, o - self.z)

    def __mul__(self, o):
        if isinstance(o, Vec):
            return Vec(self.x * o.x, self.y * o.y, self.z * o.z)
        return Vec(self.x * o, self.y * o, self.z * o)

    __rmul__ = __mul__

    def __truediv__(self, o):
        if isinstance(o, Vec):
            return Vec(
                0.0 if o.x == 0 else self.x / o.x,
                0.0 if o.y == 0 else self.y / o.y,
                0.0 if o.z == 0 else self.z / o.z,
            )
        return Vec(
            0.0 if o == 0 else self.x / o,
            0.0 if o == 0 else self.y / o,
            0.0 if o == 0 else self.z / o,
        )

    def __neg__(self):
        return Vec(-self.x, -self.y, -self.z)

    def __repr__(self):
        return f"<{self.x:.6g},{self.y:.6g},{self.z:.6g}>"


def vdot(a: Vec, b: Vec) -> float:
    return a.x * b.x + a.y * b.y + a.z * b.z


def vcross(a: Vec, b: Vec) -> Vec:
    return Vec(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x,
    )


def vlength(a: Vec) -> float:
    return math.sqrt(vdot(a, a))


def vnormalize(a: Vec) -> Vec:
    l = vlength(a)
    if l == 0:
        return Vec(0.0, 0.0, 0.0)
    return a / l


def rotateabout(axis: Vec, angle_rad: float, v: Vec) -> Vec:
    """POV macro-space rotation for geometry-building code.
    The source file's custom rotateabout() macro is used to modify point sets
    (e.g. gyration operations). Matching its effective handedness here is more
    important than reusing the scene/camera rotation path.
    """
    axis = vnormalize(axis)
    proj = axis * vdot(axis, v)
    # Use the flipped cross-product order for geometry-space rotations so that
    # rotate_vtxs()/gyration macros match the POV output.
    return proj + math.cos(angle_rad) * (v - proj) + math.sin(angle_rad) * vcross(v, axis)


def scene_rotateabout(axis: Vec, angle_rad: float, v: Vec) -> Vec:
    axis = vnormalize(axis)
    proj = axis * vdot(axis, v)
    return proj + math.cos(angle_rad) * (v - proj) + math.sin(angle_rad) * vcross(axis, v)


def vaxis_rotate(v: Vec, axis: Vec, angle_deg: float) -> Vec:
    return scene_rotateabout(axis, math.pi * angle_deg / 180.0, v)


# -----------------------------
# POV-Ray compatible-ish RNG
# -----------------------------
# POV-Ray documentation specifies seed()/rand() streams but not the low-level
# formula on the reference page. Long-time POV-Ray discussions describe the 3.x
# generator as a 32-bit linear congruential generator with increment 12345 and
# wraparound arithmetic; the implementation below follows the classic 32-bit
# form used for POV-Ray-compatible scene reproducibility.

class POVRandom:
    def __init__(self, seed_value: int):
        self.state = int(seed_value) & 0xFFFFFFFF

    def rand(self) -> float:
        # POV-Ray's historical SDL generator is a 32-bit linear congruential
        # stream using multiplier 1812433253 and increment 12345, as discussed
        # by POV-Ray developers in the project newsgroups.
        self.state = (1812433253 * self.state + 12345) & 0xFFFFFFFF
        return self.state / 4294967295.0


# -----------------------------
# Tokenizer
# -----------------------------

TOKEN_RE = re.compile(
    r'''\s*(
        \#\w+ |
        "(?:\\.|[^"])*" |
        \d+\.\d*|\.\d+|\d+\.\d*[eE][+\-]?\d+|\d+[eE][+\-]?\d+|\d+ |
        <=|>=|!=|==|\|\||&&|[+\-*/=(),;\[\].&<>|{}] |
        [A-Za-z_][A-Za-z0-9_]*
    )''',
    re.X | re.S,
)


def strip_comments(text: str) -> str:
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    text = re.sub(r'//.*', '', text)
    return text


def tokenize(text: str) -> List[str]:
    out: List[str] = []
    pos = 0
    while pos < len(text):
        m = TOKEN_RE.match(text, pos)
        if not m:
            if text[pos].isspace():
                pos += 1
                continue
            raise SyntaxError(f"Unexpected character at {pos}: {text[pos:pos+40]!r}")
        tok = m.group(1)
        out.append(tok)
        pos = m.end()
    return out


# -----------------------------
# AST nodes
# -----------------------------

@dataclass
class Expr:
    kind: str
    value: Any = None
    args: Any = None

@dataclass
class Stmt:
    kind: str
    args: Any = None


# -----------------------------
# Parser
# -----------------------------

class Parser:
    def __init__(self, tokens: List[str]):
        self.toks = tokens
        self.i = 0

    def peek(self, k=0):
        return self.toks[self.i + k] if self.i + k < len(self.toks) else None

    def pop(self, expected=None):
        tok = self.peek()
        if tok is None:
            raise SyntaxError("Unexpected EOF")
        if expected is not None and tok != expected:
            raise SyntaxError(f"Expected {expected!r}, got {tok!r}")
        self.i += 1
        return tok

    def maybe(self, tok):
        if self.peek() == tok:
            self.i += 1
            return True
        return False

    def parse_program(self) -> List[Stmt]:
        stmts = []
        while self.peek() is not None:
            if self.peek() == ';':
                self.pop(';')
                continue
            stmts.append(self.parse_stmt())
            self.maybe(';')
        return stmts

    def parse_block(self, end_tokens: set[str]) -> List[Stmt]:
        stmts = []
        while self.peek() is not None and self.peek() not in end_tokens:
            if self.peek() == ';':
                self.pop(';')
                continue
            stmts.append(self.parse_stmt())
            self.maybe(';')
        return stmts

    def parse_stmt(self) -> Stmt:
        tok = self.peek()
        if tok in ('#declare', '#local'):
            scope = self.pop()
            name = self.pop()
            indices = []
            while self.maybe('['):
                indices.append(self.parse_expr(stop_tokens={']'}))
                self.pop(']')
            self.pop('=')
            expr = self.parse_expr()
            return Stmt('assign', (scope, name, indices, expr))
        if tok == '#macro':
            self.pop('#macro')
            name = self.pop()
            self.pop('(')
            params = []
            if self.peek() != ')':
                while True:
                    params.append(self.pop())
                    if not self.maybe(','):
                        break
            self.pop(')')
            body = self.parse_block({'#end'})
            self.pop('#end')
            return Stmt('macro', (name, params, body))
        if tok == '#ifdef':
            self.pop('#ifdef')
            self.pop('(')
            cond = self.parse_expr()
            self.pop(')')
            body = self.parse_block({'#end'})
            self.pop('#end')
            return Stmt('ifdef', (cond, body))
        if tok == '#if':
            self.pop('#if')
            self.pop('(')
            cond = self.parse_expr()
            self.pop(')')
            then_body = self.parse_block({'#else', '#end'})
            else_body = []
            if self.peek() == '#else':
                self.pop('#else')
                else_body = self.parse_block({'#end'})
            self.pop('#end')
            return Stmt('if', (cond, then_body, else_body))
        if tok == '#while':
            self.pop('#while')
            self.pop('(')
            cond = self.parse_expr()
            self.pop(')')
            body = self.parse_block({'#end'})
            self.pop('#end')
            return Stmt('while', (cond, body))
        if tok == '#switch':
            self.pop('#switch')
            self.pop('(')
            expr = self.parse_expr()
            self.pop(')')
            cases = []
            while self.peek() != '#end':
                kind = self.peek()
                if kind == '#case':
                    self.pop('#case')
                    self.pop('(')
                    cexpr = self.parse_expr()
                    self.pop(')')
                    body = self.parse_block({'#case', '#range', '#else', '#break', '#end'})
                    has_break = False
                    if self.peek() == '#break':
                        self.pop('#break')
                        has_break = True
                    cases.append(('case', cexpr, None, body, has_break))
                elif kind == '#range':
                    self.pop('#range')
                    self.pop('(')
                    lo = self.parse_expr(stop_tokens={',',')'})
                    self.pop(',')
                    hi = self.parse_expr(stop_tokens={')'})
                    self.pop(')')
                    body = self.parse_block({'#case', '#range', '#else', '#break', '#end'})
                    has_break = False
                    if self.peek() == '#break':
                        self.pop('#break')
                        has_break = True
                    cases.append(('range', lo, hi, body, has_break))
                elif kind == '#else':
                    self.pop('#else')
                    body = self.parse_block({'#break', '#end'})
                    has_break = False
                    if self.peek() == '#break':
                        self.pop('#break')
                        has_break = True
                    cases.append(('else', None, None, body, has_break))
                else:
                    raise SyntaxError(f'Unexpected token in switch: {kind}')
            self.pop('#end')
            return Stmt('switch', (expr, cases))
        if tok == '#for':
            self.pop('#for')
            self.pop('(')
            var = self.pop()
            self.pop(',')
            start = self.parse_expr()
            self.pop(',')
            stop = self.parse_expr()
            step = Expr('num', 1.0)
            if self.maybe(','):
                step = self.parse_expr()
            self.pop(')')
            body = self.parse_block({'#end'})
            self.pop('#end')
            return Stmt('for', (var, start, stop, step, body))
        if tok == '#debug':
            self.pop('#debug')
            expr = self.parse_expr()
            return Stmt('debug', expr)
        if tok == '#end' or tok == '#else' or tok == '#case' or tok == '#break':
            raise SyntaxError(f"Unexpected block token {tok}")
        expr = self.parse_expr()
        return Stmt('expr', expr)

    def parse_expr(self, min_bp=0, stop_tokens=None) -> Expr:
        tok = self.pop()
        # prefix
        if tok == '(':
            left = self.parse_expr()
            self.pop(')')
        elif tok == '<':
            a = self.parse_expr(stop_tokens={',','>'})
            self.pop(',')
            b = self.parse_expr(stop_tokens={',','>'})
            if self.maybe(','):
                c = self.parse_expr(stop_tokens={',','>'})
            else:
                c = Expr('num', 0.0)
            self.pop('>')
            left = Expr('vec', args=[a, b, c])
        elif tok == '-':
            left = Expr('neg', self.parse_expr(100))
        elif tok == '+':
            left = self.parse_expr(100)
        elif re.fullmatch(r'\d+\.\d*|\.\d+|\d+[eE][+\-]?\d+|\d+\.\d*[eE][+\-]?\d+|\d+', tok):
            left = Expr('num', float(tok))
        elif tok.startswith('"'):
            left = Expr('str', bytes(tok[1:-1], 'utf-8').decode('unicode_escape'))
        elif tok == 'array' and self.peek() == '[':
            dims = []
            while self.maybe('['):
                dims.append(self.parse_expr(stop_tokens={']'}))
                self.pop(']')
            if self.maybe('{'):
                items = []
                if self.peek() != '}':
                    while True:
                        items.append(self.parse_expr(stop_tokens={',','}'}))
                        if not self.maybe(','):
                            break
                self.pop('}')
                left = Expr('array_init', args=(dims, items))
            else:
                left = Expr('array', args=dims)
        else:
            left = Expr('name', tok)

        while True:
            tok = self.peek()
            if tok is None:
                break
            if stop_tokens and tok in stop_tokens:
                break
            # postfix
            if tok == '(':
                self.pop('(')
                args = []
                if self.peek() != ')':
                    while True:
                        args.append(self.parse_expr())
                        if not self.maybe(','):
                            break
                self.pop(')')
                left = Expr('call', value=left, args=args)
                continue
            if tok == '[':
                self.pop('[')
                idx = self.parse_expr(stop_tokens={']'})
                self.pop(']')
                left = Expr('index', value=left, args=idx)
                continue
            if tok == '.':
                self.pop('.')
                attr = self.pop()
                left = Expr('attr', value=left, args=attr)
                continue

            # infix binding powers
            infix = {
                '||': (1, 2), '|': (1, 2),
                '&&': (3, 4), '&': (3, 4),
                '==': (5, 6), '=': (5, 6), '!=': (5, 6),
                '<': (7, 8), '>': (7, 8), '<=': (7, 8), '>=': (7, 8),
                '+': (9, 10), '-': (9, 10),
                '*': (11, 12), '/': (11, 12),
            }
            if tok not in infix:
                break
            lbp, rbp = infix[tok]
            if lbp < min_bp:
                break
            op = self.pop()
            right = self.parse_expr(rbp)
            left = Expr('binop', value=op, args=[left, right])
        return left


# -----------------------------
# Interpreter
# -----------------------------

class BreakException(Exception):
    pass


class Macro:
    def __init__(self, name: str, params: List[str], body: List[Stmt]):
        self.name = name
        self.params = params
        self.body = body


class Env:
    def __init__(self):
        self.globals: dict[str, Any] = {
            'pi': math.pi,
            'x': Vec(1.0, 0.0, 0.0),
            'y': Vec(0.0, 1.0, 0.0),
            'z': Vec(0.0, 0.0, 1.0),
            'clock': 0.0,
        }
        self.locals_stack: List[dict[str, Any]] = []
        self.macros: dict[str, Macro] = {}

    def get(self, name: str):
        for scope in reversed(self.locals_stack):
            if name in scope:
                return scope[name]
        if name in self.globals:
            return self.globals[name]
        raise NameError(name)

    def set_local(self, name: str, value: Any):
        if not self.locals_stack:
            self.locals_stack.append({})
        self.locals_stack[-1][name] = value

    def set_global(self, name: str, value: Any):
        self.globals[name] = value

    def eval_expr(self, e: Expr):
        k = e.kind
        if k == 'num' or k == 'str':
            return e.value
        if k == 'name':
            return self.get(e.value)
        if k == 'vec':
            return Vec(*(float(self.eval_expr(a)) for a in e.args))
        if k == 'array':
            dims = [int(round(float(self.eval_expr(a)))) for a in e.args]
            def make(ds):
                if len(ds) == 1:
                    return [None for _ in range(ds[0])]
                return [make(ds[1:]) for _ in range(ds[0])]
            return make(dims)
        if k == 'array_init':
            dims_exprs, items_exprs = e.args
            dims = [int(round(float(self.eval_expr(a)))) for a in dims_exprs]
            items = [self.eval_expr(a) for a in items_exprs]
            if len(dims) != 1:
                raise NotImplementedError('Only one-dimensional array initializers are supported')
            n = dims[0]
            arr = [None for _ in range(n)]
            for i, item in enumerate(items[:n]):
                arr[i] = item
            return arr
        if k == 'neg':
            return -self.eval_expr(e.value)
        if k == 'attr':
            obj = self.eval_expr(e.value)
            attr = e.args
            if isinstance(obj, Vec):
                if attr == 'u':
                    attr = 'x'
                elif attr == 'v':
                    attr = 'y'
            return getattr(obj, attr)
        if k == 'index':
            arr = self.eval_expr(e.value)
            idx = int(round(float(self.eval_expr(e.args))))
            return arr[idx]
        if k == 'binop':
            op = e.value
            a = self.eval_expr(e.args[0])
            b = self.eval_expr(e.args[1])
            if op in ('&', '&&'):
                return 1.0 if truthy(a) and truthy(b) else 0.0
            if op in ('|', '||'):
                return 1.0 if truthy(a) or truthy(b) else 0.0
            if op == '+':
                return a + b
            if op == '-':
                return a - b
            if op == '*':
                return a * b
            if op == '/':
                return a / b
            if op == '<':
                return 1.0 if a < b else 0.0
            if op == '>':
                return 1.0 if a > b else 0.0
            if op == '<=':
                return 1.0 if a <= b else 0.0
            if op == '>=':
                return 1.0 if a >= b else 0.0
            if op in ('==', '='):
                return 1.0 if a == b else 0.0
            if op == '!=':
                return 1.0 if a != b else 0.0
            raise ValueError(op)
        if k == 'call':
            fn = e.value
            if fn.kind != 'name':
                raise ValueError('Only simple function/macro calls are supported')
            name = fn.value
            args = [self.eval_expr(a) for a in e.args]
            return self.call(name, args)
        raise ValueError(k)

    def call(self, name: str, args: List[Any]):
        # builtins
        if name == 'sqrt': return math.sqrt(args[0])
        if name == 'pow': return math.pow(args[0], args[1])
        if name == 'sin': return math.sin(args[0])
        if name == 'cos': return math.cos(args[0])
        if name == 'tan': return math.tan(args[0])
        if name == 'acos': return math.acos(args[0])
        if name == 'max': return max(args[0], args[1])
        if name == 'min': return min(args[0], args[1])
        if name == 'abs': return abs(args[0])
        if name == 'int': return int(args[0])
        if name == 'vdot': return vdot(args[0], args[1])
        if name == 'vcross': return vcross(args[0], args[1])
        if name == 'vlength': return vlength(args[0])
        if name == 'vnormalize': return vnormalize(args[0])
        if name == 'vaxis_rotate': return vaxis_rotate(args[0], args[1], args[2])
        if name == 'seed': return POVRandom(int(round(args[0])))
        if name == 'rand': return args[0].rand()
        if name == 'concat': return ''.join(str(a) for a in args)
        if name == 'strlen': return len(str(args[0]))
        if name == 'substr':
            s = str(args[0])
            start = int(args[1])
            if len(args) >= 3:
                count = int(args[2])
                if count <= 0:
                    return ''
                return s[max(0, start-1):max(0, start-1)+count]
            return s[max(0, start-1):]
        if name == 'strcmp':
            a = str(args[0])
            b = str(args[1])
            if a == b:
                return 0
            return -1 if a < b else 1
        if name == 'val':
            s = str(args[0]).strip()
            try:
                if any(c in s for c in '.eE'):
                    return float(s)
                return int(s)
            except Exception:
                try:
                    return float(s)
                except Exception:
                    return 0
        if name == 'mod': return math.fmod(args[0], args[1])
        if name == 'div': return int(math.floor(float(args[0]) / float(args[1]))) if float(args[1]) != 0 else 0
        if name == 'str':
            val = args[0]
            if isinstance(val, (int, float)):
                return f"{val}"
            return str(val)
        if name == 'showvtxs':
            return 0
        # macro
        macro = self.macros.get(name)
        if macro is None:
            raise NameError(f"Unknown function or macro {name}")
        local = {p: a for p, a in zip(macro.params, args)}
        self.locals_stack.append(local)
        try:
            # POV-Ray expression macros return the value of their final expression.
            if len(macro.body) == 1 and getattr(macro.body[0], 'kind', None) == 'expr':
                return self.eval_expr(macro.body[0].args)
            last = 0
            for st in macro.body:
                if getattr(st, 'kind', None) == 'expr':
                    last = self.eval_expr(st.args)
                else:
                    self.exec_stmt(st)
            return last
        finally:
            self.locals_stack.pop()

    def exec_stmt(self, st: Stmt):
        if st.kind == 'assign':
            scope, name, index_exprs, expr = st.args
            value = self.eval_expr(expr)
            if not index_exprs:
                if scope == '#local':
                    self.set_local(name, value)
                else:
                    self.set_global(name, value)
            else:
                arr = self.get(name)
                idxs = [int(round(float(self.eval_expr(ix)))) for ix in index_exprs]
                for ix in idxs[:-1]:
                    arr = arr[ix]
                arr[idxs[-1]] = value
            return
        if st.kind == 'macro':
            name, params, body = st.args
            self.macros[name] = Macro(name, params, body)
            return
        if st.kind == 'ifdef':
            cond, body = st.args
            try:
                val = self.eval_expr(cond)
                ok = val is not None and truthy(val)
            except Exception:
                ok = False
            if ok:
                self.exec_block(body)
            return
        if st.kind == 'if':
            cond, then_body, else_body = st.args
            self.exec_block(then_body if truthy(self.eval_expr(cond)) else else_body)
            return
        if st.kind == 'while':
            cond, body = st.args
            while truthy(self.eval_expr(cond)):
                self.exec_block(body)
            return
        if st.kind == 'switch':
            expr, cases = st.args
            val = self.eval_expr(expr)
            active = False
            for ckind, a1, a2, body, has_break in cases:
                match = False
                if active:
                    match = True
                elif ckind == 'case':
                    match = scalar_eq(val, self.eval_expr(a1))
                elif ckind == 'range':
                    lo = float(self.eval_expr(a1)); hi = float(self.eval_expr(a2)); vv = float(val)
                    match = lo <= vv <= hi
                elif ckind == 'else':
                    match = True
                if match:
                    active = True
                    self.exec_block(body)
                    if has_break:
                        break
            return
        if st.kind == 'for':
            var, start, stop, step, body = st.args
            s = float(self.eval_expr(start))
            e = float(self.eval_expr(stop))
            p = float(self.eval_expr(step))
            cur = s
            cmp = (lambda a, b: a <= b + 1e-9) if p >= 0 else (lambda a, b: a >= b - 1e-9)
            if not self.locals_stack:
                self.locals_stack.append({})
            while cmp(cur, e):
                self.locals_stack[-1][var] = cur
                self.exec_block(body)
                cur += p
            return
        if st.kind == 'debug':
            return
        if st.kind == 'expr':
            self.eval_expr(st.args)
            return
        raise ValueError(st.kind)

    def exec_block(self, body: List[Stmt]):
        for st in body:
            self.exec_stmt(st)


def truthy(v: Any) -> bool:
    if isinstance(v, Vec):
        return abs(v.x) > 1e-12 or abs(v.y) > 1e-12 or abs(v.z) > 1e-12
    if isinstance(v, POVRandom):
        return True
    return bool(v)


def scalar_eq(a: Any, b: Any) -> bool:
    if isinstance(a, Vec) or isinstance(b, Vec):
        return a == b
    return abs(float(a) - float(b)) < 1e-9


# -----------------------------
# Rendering helpers
# -----------------------------

def project_point(p: Vec, camera_loc: Vec, max_bearing: float, max_elev: float, width: int, height: int):
    sight = p - camera_loc
    if sight.z <= 1e-9:
        return None
    bearing = sight.x / sight.z
    elev = sight.y / sight.z
    x = width * (0.5 + 0.5 * bearing / max_bearing)
    y = height * (0.5 - 0.5 * elev / max_elev)
    return x, y, sight.z



def solve3_rows(a1: Vec, a2: Vec, a3: Vec, b1: float, b2: float, b3: float, tol: float = 1e-12):
    det = (a1.x * (a2.y * a3.z - a2.z * a3.y)
           - a1.y * (a2.x * a3.z - a2.z * a3.x)
           + a1.z * (a2.x * a3.y - a2.y * a3.x))
    if abs(det) < tol:
        return None
    dx = (b1 * (a2.y * a3.z - a2.z * a3.y)
          - a1.y * (b2 * a3.z - a2.z * b3)
          + a1.z * (b2 * a3.y - a2.y * b3))
    dy = (a1.x * (b2 * a3.z - a2.z * b3)
          - b1 * (a2.x * a3.z - a2.z * a3.x)
          + a1.z * (a2.x * b3 - b2 * a3.x))
    dz = (a1.x * (a2.y * b3 - b2 * a3.y)
          - a1.y * (a2.x * b3 - b2 * a3.x)
          + b1 * (a2.x * a3.y - a2.y * a3.x))
    return Vec(dx / det, dy / det, dz / det)


def dedupe_points(points: List[Vec], tol: float = 1e-6) -> List[Vec]:
    out: List[Vec] = []
    for p in points:
        if not any(vlength(p - q) <= tol for q in out):
            out.append(p)
    return out


def derive_geometry_from_halfspaces(faces: List[Vec], tol: float = 1e-6):
    # Each stored face vector f encodes the halfspace f·x <= 1.
    verts: List[Vec] = []
    nfaces = len(faces)
    for i in range(nfaces):
        fi = faces[i]
        for j in range(i + 1, nfaces):
            fj = faces[j]
            for k in range(j + 1, nfaces):
                fk = faces[k]
                p = solve3_rows(fi, fj, fk, 1.0, 1.0, 1.0)
                if p is None:
                    continue
                ok = True
                for f in faces:
                    if vdot(f, p) > 1.0 + 5e-5:
                        ok = False
                        break
                if ok:
                    verts.append(p)
    verts = dedupe_points(verts, tol=1e-5)

    face_loops_out = []
    vertices_on_face = []
    for fi, f in enumerate(faces):
        idxs = [idx for idx, p in enumerate(verts) if abs(vdot(f, p) - 1.0) <= 1e-5]
        vertices_on_face.append(idxs)
        if len(idxs) < 3:
            continue
        ordered = order_face(idxs, f, verts)
        face_loops_out.append((fi, ordered))

    # Robust edge recovery: in a convex polyhedron, an edge is the intersection
    # of two supporting planes and therefore appears as exactly two vertices that
    # lie on both planes.
    edge_set = set()
    for i in range(nfaces):
        set_i = set(vertices_on_face[i])
        if len(set_i) < 2:
            continue
        for j in range(i + 1, nfaces):
            common = sorted(set_i.intersection(vertices_on_face[j]))
            if len(common) == 2:
                a, b = common
                if a != b:
                    edge_set.add((a, b) if a < b else (b, a))

    return verts, face_loops_out, edge_set


def point_on_face(face: Vec, p: Vec, tol: float = 1e-5) -> bool:
    return vdot(face, p) > 1 - tol


def find_face_vertices(face: Vec, points: List[Vec], tol: float = 1e-5) -> List[int]:
    return [i for i, p in enumerate(points) if point_on_face(face, p, tol)]


def order_face(idxs: List[int], face: Vec, points: List[Vec]) -> List[int]:
    verts = [points[i] for i in idxs]
    center = Vec(0.0, 0.0, 0.0)
    for vv in verts:
        center += vv
    center = center / len(verts)
    n = vnormalize(face)
    ref = Vec(1.0, 0.0, 0.0)
    if abs(vdot(ref, n)) > 0.9:
        ref = Vec(0.0, 1.0, 0.0)
    u = vnormalize(vcross(n, ref))
    v = vnormalize(vcross(n, u))
    angs = []
    for i in idxs:
        d = points[i] - center
        angs.append((math.atan2(vdot(d, v), vdot(d, u)), i))
    angs.sort()
    return [i for _, i in angs]


def _point_between_on_segment(pa: Vec, pb: Vec, pc: Vec, tol: float = 1e-6) -> bool:
    ab = pb - pa
    ac = pc - pa
    if vlength(ab) < tol:
        return False
    if vlength(vcross(ab, ac)) > tol:
        return False
    dotp = vdot(ac, ab)
    if dotp <= tol:
        return False
    if dotp >= vdot(ab, ab) - tol:
        return False
    return True


def face_loops(face_index: int, faces: List[Vec], points: List[Vec], tol: float = 1e-5) -> List[List[int]]:
    face = faces[face_index]
    idxs = find_face_vertices(face, points, tol)
    if len(idxs) < 3:
        return []

    memberships = {i: [] for i in idxs}
    for fj, other in enumerate(faces):
        for i in idxs:
            if point_on_face(other, points[i], tol):
                memberships[i].append(fj)

    adjacency = {i: set() for i in idxs}
    for ai in range(len(idxs)):
        a = idxs[ai]
        for bi in range(ai + 1, len(idxs)):
            b = idxs[bi]
            shared_other = False
            aset = memberships[a]
            bset = set(memberships[b])
            for fj in aset:
                if fj != face_index and fj in bset:
                    shared_other = True
                    break
            if not shared_other:
                continue
            pa, pb = points[a], points[b]
            blocked = False
            for c in idxs:
                if c == a or c == b:
                    continue
                if _point_between_on_segment(pa, pb, points[c], tol):
                    blocked = True
                    break
            if not blocked:
                adjacency[a].add(b)
                adjacency[b].add(a)

    if any(len(adjacency[i]) != 2 for i in idxs):
        return [order_face(idxs, face, points)]

    loops = []
    used = set()
    for start in idxs:
        for nb in sorted(adjacency[start]):
            e = tuple(sorted((start, nb)))
            if e in used:
                continue
            loop = [start]
            prev, curr = start, nb
            while True:
                loop.append(curr)
                used.add(tuple(sorted((prev, curr))))
                nxts = [x for x in adjacency[curr] if x != prev]
                if not nxts:
                    loop = []
                    break
                nxt = nxts[0]
                prev, curr = curr, nxt
                if curr == start:
                    break
                if len(loop) > len(idxs) + 2:
                    loop = []
                    break
            if loop and len(loop) >= 3:
                m = min(loop)
                k = loop.index(m)
                loop = loop[k:] + loop[:k]
                rloop = [loop[0]] + list(reversed(loop[1:]))
                key = min(tuple(loop), tuple(rloop))
                if key not in {tuple(x) for x in loops}:
                    loops.append(list(key))
    return loops or [order_face(idxs, face, points)]


def face_depth(idxs: List[int], points: List[Vec], camera_loc: Vec) -> float:
    return sum((points[i] - camera_loc).z for i in idxs) / len(idxs)


def svg_color(r: float, g: float, b: float) -> str:
    return f"rgb({int(max(0,min(255,round(r*255))))},{int(max(0,min(255,round(g*255))))},{int(max(0,min(255,round(b*255))))})"


def clamp01(x: float) -> float:
    return max(0.0, min(1.0, x))


def mix_rgb(a, b, t: float):
    t = clamp01(t)
    return (
        a[0] * (1.0 - t) + b[0] * t,
        a[1] * (1.0 - t) + b[1] * t,
        a[2] * (1.0 - t) + b[2] * t,
    )


def shaded_face_style(normal: Vec, base_rgbt, depth01: float,
                      tint_strength: float = 1.0,
                      shade_strength: float = 1.0,
                      brightness: float = 1.0,
                      face_alpha_scale: float = 1.0):
    # Fixed green-family orientation tint, using a palette biased toward the
    # attached reference PNG: teal on one side, yellow-green on favorable
    # upward/front-facing planes, and olive/amber-green on the opposite side.
    nx, ny, nz = normal.x, normal.y, normal.z

    teal = (0.21, 0.53, 0.48)
    green = (0.36, 0.58, 0.27)
    lime = (0.66, 0.92, 0.18)
    olive = (0.49, 0.50, 0.18)
    amber_olive = (0.56, 0.43, 0.22)

    # Warm/cool split from left-right orientation.
    cool_warm = clamp01((nx + 1.0) * 0.5)
    side_rgb = mix_rgb(teal, amber_olive, cool_warm)

    # Upward/front-facing boost toward the bright lime seen in the reference.
    lift = clamp01(0.55 * ((ny + 1.0) * 0.5) + 0.45 * ((nz + 1.0) * 0.5))

    # Blend between a flatter base-green and the oriented palette.
    base = mix_rgb(green, side_rgb, clamp01(0.45 * tint_strength))
    if lift >= 0.5:
        rgb = mix_rgb(base, lime, clamp01((lift - 0.5) * 1.35 * tint_strength))
    else:
        rgb = mix_rgb(base, olive, clamp01((0.5 - lift) * 1.10 * tint_strength))

    # Mild orientation/depth shading for separation.
    raw_shade = 0.78 + 0.26 * clamp01(0.30 * nz + 0.20 * ny + 0.50) - 0.06 * depth01
    shade = 1.0 + (raw_shade - 1.0) * shade_strength
    rgb = tuple(clamp01(c * shade * brightness) for c in rgb)

    t = base_rgbt[3] if len(base_rgbt) >= 4 else 0.4
    opacity = clamp01((1.0 - t) * face_alpha_scale)
    return rgb01_to_hex(rgb), opacity

def extract_colors_and_radii(text: str):
    edge_rgb = (0.3, 0.3, 0.3, 1.0)
    point_rgb = (0.3, 0.3, 0.3, 1.0)
    face_rgbt = (0.8, 0.8, 0.8, 0.4)
    edge_radius = 0.02
    point_radius = 0.05

    m = re.search(r'cylinder\s*\{\s*[^,{}]+\s*,\s*[^,{}]+\s*,\s*([0-9.+\-eE]+)', text, re.S)
    if m:
        edge_radius = float(m.group(1))
    m = re.search(r'sphere\s*\{\s*[^,{}]+\s*,\s*([0-9.+\-eE]+)', text, re.S)
    if m:
        point_radius = float(m.group(1))

    m = re.search(r'cylinder\s*\{.*?pigment\s*\{\s*colour\s*(?:rgb\s*)?<\s*([0-9.+\-eE]+)\s*,\s*([0-9.+\-eE]+)\s*,\s*([0-9.+\-eE]+)\s*>', text, re.S)
    if m:
        edge_rgb = tuple(map(float, m.groups())) + (1.0,)
    m = re.search(r'sphere\s*\{.*?pigment\s*\{\s*colour\s*(?:rgb\s*)?<\s*([0-9.+\-eE]+)\s*,\s*([0-9.+\-eE]+)\s*,\s*([0-9.+\-eE]+)\s*>', text, re.S)
    if m:
        point_rgb = tuple(map(float, m.groups())) + (1.0,)
    m = re.search(r'pigment\s*\{\s*colour\s*rgbt\s*<\s*([0-9.+\-eE]+)\s*,\s*([0-9.+\-eE]+)\s*,\s*([0-9.+\-eE]+)\s*,\s*([0-9.+\-eE]+)\s*>', text, re.S)
    if m:
        face_rgbt = tuple(map(float, m.groups()))
    return edge_rgb, point_rgb, face_rgbt, edge_radius, point_radius


def build_svg(points: List[Vec], faces: List[Vec], width: int, height: int, text: str, rotation_stream: POVRandom,
              edge_radius_scale: float = 1.0, point_radius_scale: float = 1.0,
              tint_strength: float = 1.0, shade_strength: float = 1.0,
              brightness: float = 1.0, face_alpha_scale: float = 1.0) -> str:
    # Random rotations exactly as in the scene logic.
    rot1 = rotation_stream.rand() * math.pi * 2
    rot2 = math.acos(1 - 2 * rotation_stream.rand())
    rot3 = (rotation_stream.rand() + 0.0) * math.pi * 2

    def dorot(p: Vec) -> Vec:
        p = vaxis_rotate(p, Vec(0,1,0), rot1 * 180 / math.pi)
        p = vaxis_rotate(p, Vec(1,0,0), rot2 * 180 / math.pi)
        p = vaxis_rotate(p, Vec(0,1,0), rot3 * 180 / math.pi)
        return p

    def point_in_poly_2d(x: float, y: float, poly_pts) -> bool:
        inside = False
        n = len(poly_pts)
        for i in range(n):
            x1, y1 = poly_pts[i]
            x2, y2 = poly_pts[(i + 1) % n]
            # point on edge counts as inside
            cross = (x - x1) * (y2 - y1) - (y - y1) * (x2 - x1)
            dot = (x - x1) * (x - x2) + (y - y1) * (y - y2)
            if abs(cross) < 1e-9 and dot <= 1e-9:
                return True
            if ((y1 > y) != (y2 > y)):
                xinters = (x2 - x1) * (y - y1) / ((y2 - y1) if abs(y2 - y1) > 1e-12 else 1e-12) + x1
                if x < xinters:
                    inside = not inside
        return inside

    def ray_depth_for_face(screen_x: float, screen_y: float, face_vec_rot: Vec) -> Optional[float]:
        # Reconstruct the sight ray from screen coordinates.
        dx = ((screen_x / width) * 2.0 - 1.0) * max_bear
        dy = (1.0 - (screen_y / height) * 2.0) * max_elev
        target = camera_loc + Vec(dx, dy, 0.5)
        d = target - camera_loc
        denom = vdot(face_vec_rot, d)
        if abs(denom) < 1e-12:
            return None
        t = (1.0 - vdot(face_vec_rot, camera_loc)) / denom
        if t <= 0:
            return None
        hit = camera_loc + d * t
        return hit.z - camera_loc.z

    def classify_hidden(rep_screen, rep_depth: float, exclude_faces: set) -> bool:
        if rep_screen is None:
            return False
        sx, sy, _ = rep_screen
        for fdata in face_data:
            if fdata['fi'] in exclude_faces:
                continue
            poly2d = fdata['poly2d']
            if len(poly2d) < 3:
                continue
            if not point_in_poly_2d(sx, sy, poly2d):
                continue
            occ_depth = ray_depth_for_face(sx, sy, fdata['face_vec_rot'])
            if occ_depth is None:
                continue
            if occ_depth < rep_depth - 1e-6:
                return True
        return False

    # Scale to unit sphere.
    maxlen = max(vlength(p) for p in points)
    points = [p / maxlen for p in points]
    faces = [f * maxlen for f in faces]

    # Reconstruct the convex polyhedron directly from the face halfspaces.
    try:
        geom_points, geom_face_loops, geom_edges = derive_geometry_from_halfspaces(faces)
        if len(geom_points) >= 4 and len(geom_face_loops) >= 4:
            points = geom_points
        else:
            geom_face_loops, geom_edges = [], set()
    except Exception:
        geom_face_loops, geom_edges = [], set()

    rpoints = [dorot(p) for p in points]
    rfaces = [dorot(f) for f in faces]

    camera_loc = Vec(0, 0, -4.8)
    max_elev = 0.0
    max_bear = 0.0
    for p in rpoints:
        sight = p - camera_loc
        elev = sight.y / sight.z
        bear = sight.x / sight.z
        max_elev = max(max_elev, abs(elev))
        max_bear = max(max_bear, abs(bear))
    max_bear = max(max_bear, max_elev)
    max_elev = max_bear
    max_bear *= 1.05
    max_elev *= 1.05

    proj = [project_point(p, camera_loc, max_bear, max_elev, width, height) for p in rpoints]

    edge_rgba, point_rgba, face_rgbt, edge_radius, point_radius = extract_colors_and_radii(text)
    edge_color = svg_color(*edge_rgba[:3])
    point_color = svg_color(*point_rgba[:3])

    face_info = []
    edge_set = set()
    if geom_face_loops:
        for fi, ordered in geom_face_loops:
            if len(ordered) < 3:
                continue
            rotated_normal = dorot(vnormalize(faces[fi]))
            depth = face_depth(ordered, rpoints, camera_loc)
            face_info.append((fi, depth, ordered, rotated_normal))
        edge_set = set(geom_edges)
    else:
        for fi, f in enumerate(faces):
            loops = face_loops(fi, faces, points)
            if not loops:
                continue
            rotated_normal = dorot(vnormalize(f))
            for ordered in loops:
                if len(ordered) < 3:
                    continue
                depth = face_depth(ordered, rpoints, camera_loc)
                face_info.append((fi, depth, ordered, rotated_normal))
                for i in range(len(ordered)):
                    a = ordered[i]
                    b = ordered[(i + 1) % len(ordered)]
                    if a != b:
                        edge_set.add(tuple(sorted((a, b))))

    px_per_world_x = width * 0.5 / max_bear
    px_per_world_y = height * 0.5 / max_elev
    px_per_world = min(px_per_world_x, px_per_world_y)

    face_depths = [d for _, d, _, _ in face_info] or [1.0]
    min_face_depth = min(face_depths)
    max_face_depth = max(face_depths)
    depth_span = max(1e-9, max_face_depth - min_face_depth)

    # Adjacency maps.
    edge_to_faces = {}
    vertex_to_faces = {i: set() for i in range(len(points))}
    for fi, depth, ordered, rotated_normal in face_info:
        for vidx in ordered:
            vertex_to_faces.setdefault(vidx, set()).add(fi)
        for i in range(len(ordered)):
            a = ordered[i]
            b = ordered[(i + 1) % len(ordered)]
            if a != b:
                edge_to_faces.setdefault(tuple(sorted((a, b))), set()).add(fi)

    # Build face data first so hidden tests can reference it.
    face_data = []
    for fi, depth, ordered, rotated_normal in face_info:
        pts2 = []
        poly2d = []
        valid = True
        for idx in ordered:
            pp = proj[idx]
            if pp is None:
                valid = False
                break
            pts2.append(f"{pp[0]:.3f},{pp[1]:.3f}")
            poly2d.append((pp[0], pp[1]))
        if not valid or len(poly2d) < 3:
            continue
        depth01 = (depth - min_face_depth) / depth_span
        face_color, face_opacity = shaded_face_style(rotated_normal, face_rgbt, depth01, tint_strength=tint_strength, shade_strength=shade_strength, brightness=brightness, face_alpha_scale=face_alpha_scale)
        centroid3 = Vec(0,0,0)
        for idx in ordered:
            centroid3 = centroid3 + rpoints[idx]
        centroid3 = centroid3 / float(len(ordered))
        centroid_proj = project_point(centroid3, camera_loc, max_bear, max_elev, width, height)
        centroid_depth = centroid_proj[2] if centroid_proj is not None else depth
        face_data.append({
            'fi': fi,
            'depth': depth,
            'ordered': ordered,
            'rotated_normal': rotated_normal,
            'face_vec_rot': rfaces[fi],
            'poly2d': poly2d,
            'svg': f'<polygon points="{" ".join(pts2)}" fill="{face_color}" fill-opacity="{face_opacity:.4f}" stroke="none"/>',
            'hidden': False,
            'rep_proj': centroid_proj,
            'rep_depth': centroid_depth,
        })

    # On a convex polyhedron, visibility is determined by face orientation.
    # A face is visible iff its outward normal points toward the camera.
    # Edges/vertices are visible iff at least one incident face is visible.
    visible_face_ids = set()
    for fd in face_data:
        ordered = fd['ordered']
        center3 = Vec(0.0, 0.0, 0.0)
        for idx in ordered:
            center3 = center3 + rpoints[idx]
        center3 = center3 / float(len(ordered))
        to_camera = camera_loc - center3
        facing = vdot(fd['rotated_normal'], to_camera)
        fd['hidden'] = not (facing > 1e-9)
        if not fd['hidden']:
            visible_face_ids.add(fd['fi'])

    # Build edge and vertex items.
    edge_items = []
    for a, b in edge_set:
        pa, pb = proj[a], proj[b]
        if pa is None or pb is None:
            continue
        depth_mid = 0.5 * (pa[2] + pb[2])
        stroke_w = max(0.35, 2.0 * edge_radius * edge_radius_scale * px_per_world / max(1e-9, depth_mid))
        incident = set(edge_to_faces.get(tuple(sorted((a, b))), set()))
        hidden = len(incident.intersection(visible_face_ids)) == 0
        edge_items.append({
            'depth': min(pa[2], pb[2]),
            'hidden': hidden,
            'svg': f'<line x1="{pa[0]:.3f}" y1="{pa[1]:.3f}" x2="{pb[0]:.3f}" y2="{pb[1]:.3f}" stroke="{edge_color}" stroke-width="{stroke_w:.3f}" stroke-linecap="round"/>',
        })

    vertex_items = []
    for i, p in enumerate(proj):
        if p is None:
            continue
        depth = p[2]
        radius = max(0.45, point_radius * point_radius_scale * px_per_world / depth)
        incident = set(vertex_to_faces.get(i, set()))
        hidden = len(incident.intersection(visible_face_ids)) == 0
        vertex_items.append({
            'depth': depth,
            'hidden': hidden,
            'svg': f'<circle cx="{p[0]:.3f}" cy="{p[1]:.3f}" r="{radius:.3f}" fill="{point_color}"/>',
        })

    hidden_faces = sorted([fd for fd in face_data if fd['hidden']], key=lambda d: -d['depth'])
    hidden_ev = sorted([it for it in (edge_items + vertex_items) if it['hidden']], key=lambda d: -d['depth'])
    visible_faces = sorted([fd for fd in face_data if not fd['hidden']], key=lambda d: -d['depth'])
    visible_ev = sorted([it for it in (edge_items + vertex_items) if not it['hidden']], key=lambda d: -d['depth'])

    out = []
    out.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">')
    out.append(f'<rect x="0" y="0" width="{width}" height="{height}" fill="white"/>')
    for fd in hidden_faces:
        out.append(fd['svg'])
    for it in hidden_ev:
        out.append(it['svg'])
    for fd in visible_faces:
        out.append(fd['svg'])
    for it in visible_ev:
        out.append(it['svg'])
    out.append('</svg>')
    return '\n'.join(out)


# -----------------------------
# Driver
# -----------------------------

def main():
    ap = argparse.ArgumentParser(description='Convert a POV-Ray polyhedron scene of this specific macro system into an SVG.')
    ap.add_argument('input', help='Input .pov file')
    ap.add_argument('output', help='Output .svg file')
    ap.add_argument('--shape', help='Fallback macro name to invoke if This_shape_will_be_drawn is not defined in the file')
    ap.add_argument('--seed', type=int, default=1, help='Fallback seed if the file does not declare rotation=seed(R)')
    ap.add_argument('--width', type=int, default=1200)
    ap.add_argument('--height', type=int, default=1200)
    ap.add_argument('--edge-scale', type=float, default=1.0, help='Multiply POV cylinder radius by this factor in SVG rendering')
    ap.add_argument('--vertex-scale', type=float, default=1.0, help='Multiply POV sphere radius by this factor in SVG rendering')
    ap.add_argument('--tint-strength', type=float, default=1.0, help='Strength of orientation-based tinting (0 = flatter green).')
    ap.add_argument('--shade-strength', type=float, default=1.0, help='Strength of orientation-based light/dark shading.')
    ap.add_argument('--brightness', type=float, default=1.0, help='Overall face brightness multiplier.')
    ap.add_argument('--face-alpha-scale', type=float, default=1.0, help='Scale factor for face opacity.')
    args = ap.parse_args()

    text = open(args.input, 'r', encoding='utf-8').read()
    clean = strip_comments(text)
    # The file contains some rendering macros (notably drawit) with full object syntax
    # that this geometry interpreter does not need. Remove them before tokenizing.
    m_draw = re.search(r'#macro\s+drawit\s*\(\)', clean)
    m_after = re.search(r'\#declare\s+el\s*=\s*1\s*;', clean)
    if m_draw and m_after and m_after.start() > m_draw.start():
        clean = clean[:m_draw.start()] + clean[m_after.start():]


    # We only need to execute the geometry construction section up to the placeholder call.
    marker = clean.find('This_shape_will_be_drawn()')
    if marker == -1:
        raise SystemExit('Could not find This_shape_will_be_drawn() call in input file.')
    prefix = clean[:marker]

    tokens = tokenize(prefix)
    parser = Parser(tokens)
    prog = parser.parse_program()
    env = Env()

    # Allow the user-supplied inserted seed line to win if present.
    env.set_global('rotation', POVRandom(args.seed))
    env.exec_block(prog)

    if 'rotation' not in env.globals:
        env.set_global('rotation', POVRandom(args.seed))

    if 'points' not in env.globals or 'faces' not in env.globals:
        raise SystemExit('Scene did not declare points/faces arrays as expected.')

    def invoke_shape(shape_text: str):
        expr_tokens = tokenize(shape_text)
        expr_parser = Parser(expr_tokens)
        expr = expr_parser.parse_expr()
        # Allow bare macro names like icosahedron as shorthand for icosahedron()
        if getattr(expr, 'kind', None) == 'name' and expr.value in env.macros:
            return env.call(expr.value, [])
        return env.eval_expr(expr)

    if args.shape:
        invoke_shape(args.shape)
    elif 'This_shape_will_be_drawn' in env.macros:
        env.call('This_shape_will_be_drawn', [])
    else:
        raise SystemExit('This_shape_will_be_drawn macro is not defined in the file. Supply --shape MACRO_NAME or MACRO(args).')

    npoints = int(env.get('npoints'))
    nfaces = int(env.get('nfaces'))
    points = env.get('points')[:npoints]
    faces = env.get('faces')[:nfaces]

    svg = build_svg(points, faces, args.width, args.height, text, env.get('rotation'),
                    edge_radius_scale=args.edge_scale,
                    point_radius_scale=args.vertex_scale,
                    tint_strength=args.tint_strength,
                    shade_strength=args.shade_strength,
                    brightness=args.brightness,
                    face_alpha_scale=args.face_alpha_scale)
    with open(args.output, 'w', encoding='utf-8') as f:
        f.write(svg)


if __name__ == '__main__':
    main()
